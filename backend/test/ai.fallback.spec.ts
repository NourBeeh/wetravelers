import { createServer, IncomingMessage, Server, ServerResponse } from 'node:http';
import { AddressInfo } from 'node:net';

import { describe, it, expect, beforeAll, afterAll, beforeEach } from '@jest/globals';
import { INestApplication, Module, ValidationPipe } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';

import { AiResponseDto } from '../src/common/dto/ai.dto';
import { AiModule, resolveFallbackProvider } from '../src/modules/ai/ai.module';
import { AiService } from '../src/modules/ai/ai.service';
import { AiProvider, AiProviderFailure } from '../src/modules/ai/ai.provider';
import { MockAiProvider } from '../src/modules/ai/mock.ai.provider';

/**
 * Phase 10C — provider fallback policy.
 *
 * The policy lives in `AiService`, so the first half drives that service
 * directly through the existing `AiProvider` abstraction: the unit under test
 * is the decision ("may another provider be tried?"), not the transport, which
 * `ai.http.integration.spec.ts` already covers over real sockets.
 *
 * The second half boots the real module over real HTTP to prove the
 * `AI_FALLBACK_PROVIDER` wiring, not just the branch logic.
 */

const OK_DTO: AiResponseDto = {
  text: 'primary answer',
  sections: [],
  metadata: { queryId: 'primary', version: 1 },
};

const FALLBACK_DTO: AiResponseDto = {
  text: 'fallback answer',
  sections: [],
  metadata: { queryId: 'fallback', version: 1 },
};

/** Records every call so "was the fallback consulted?" is directly observable. */
class StubProvider implements AiProvider {
  constructor(
    readonly providerId: string,
    private readonly behaviour: () => Promise<AiResponseDto>,
  ) {}

  readonly providerName = 'Stub';
  readonly calls: string[] = [];

  async generate(prompt: string): Promise<AiResponseDto> {
    this.calls.push(prompt);
    return this.behaviour();
  }
}

function succeeds(dto: AiResponseDto): () => Promise<AiResponseDto> {
  return () => Promise.resolve(dto);
}

function failsWith(error: unknown): () => Promise<AiResponseDto> {
  return () => Promise.reject(error);
}

/** The four transient failures the provider raises as retryable. */
const networkFailure = () =>
  new AiProviderFailure('AI provider could not be reached.', { category: 'network' });
const timeoutFailure = () =>
  new AiProviderFailure('AI provider request timed out.', { category: 'timeout' });
const serverFailure = (status = 503) =>
  new AiProviderFailure(`AI provider request failed (HTTP ${status}).`, {
    category: 'upstream_5xx',
    upstreamStatus: status,
  });
const emptyCompletionFailure = () =>
  new AiProviderFailure('AI provider returned an empty completion.', {
    category: 'empty_completion',
    upstreamStatus: 200,
  });

/** The failures that must never trigger a fallback. */
const clientFailure = (status = 400) =>
  new AiProviderFailure(`AI provider request failed (HTTP ${status}).`, {
    category: 'upstream_4xx',
    upstreamStatus: status,
  });
const misconfiguredFailure = () =>
  new AiProviderFailure('AI provider is not configured: AI_API_KEY is missing.', {
    category: 'not_configured',
  });

async function capture(run: () => Promise<unknown>): Promise<unknown> {
  try {
    await run();
    return null;
  } catch (error) {
    return error;
  }
}

describe('Phase 10C: AiService fallback policy', () => {
  describe('scenario 1 — primary success', () => {
    it('returns the primary answer and never consults the fallback', async () => {
      const primary = new StubProvider('primary', succeeds(OK_DTO));
      const fallback = new StubProvider('fallback', succeeds(FALLBACK_DTO));

      const result = await new AiService(primary, fallback).query('find hotels');

      expect(result).toBe(OK_DTO);
      expect(primary.calls).toEqual(['find hotels']);
      expect(fallback.calls).toEqual([]);
    });
  });

  describe('scenario 2 — network and timeout failures fall back', () => {
    it('falls back on a network failure', async () => {
      const primary = new StubProvider('primary', failsWith(networkFailure()));
      const fallback = new StubProvider('fallback', succeeds(FALLBACK_DTO));

      const result = await new AiService(primary, fallback).query('find hotels');

      expect(result).toBe(FALLBACK_DTO);
      expect(fallback.calls).toEqual(['find hotels']);
    });

    it('falls back on a timeout', async () => {
      const primary = new StubProvider('primary', failsWith(timeoutFailure()));
      const fallback = new StubProvider('fallback', succeeds(FALLBACK_DTO));

      const result = await new AiService(primary, fallback).query('find hotels');

      expect(result).toBe(FALLBACK_DTO);
      expect(fallback.calls).toHaveLength(1);
    });

    it('falls back on an unusable upstream completion', async () => {
      const primary = new StubProvider('primary', failsWith(emptyCompletionFailure()));
      const fallback = new StubProvider('fallback', succeeds(FALLBACK_DTO));

      const result = await new AiService(primary, fallback).query('find hotels');

      expect(result).toBe(FALLBACK_DTO);
    });
  });

  describe('scenario 3 — HTTP 5xx falls back', () => {
    it.each([500, 502, 503, 504])('falls back on upstream %i', async (status) => {
      const primary = new StubProvider('primary', failsWith(serverFailure(status)));
      const fallback = new StubProvider('fallback', succeeds(FALLBACK_DTO));

      const result = await new AiService(primary, fallback).query('find hotels');

      expect(result).toBe(FALLBACK_DTO);
      expect(fallback.calls).toHaveLength(1);
    });
  });

  describe('scenario 4 — HTTP 4xx and client errors do not fall back', () => {
    it.each([400, 401, 403, 404, 422, 429])(
      'does not fall back on upstream %i',
      async (status) => {
        const primary = new StubProvider('primary', failsWith(clientFailure(status)));
        const fallback = new StubProvider('fallback', succeeds(FALLBACK_DTO));

        const error = await capture(() =>
          new AiService(primary, fallback).query('find hotels'),
        );

        expect(error).toBeInstanceOf(AiProviderFailure);
        expect((error as AiProviderFailure).upstreamStatus).toBe(status);
        expect(fallback.calls).toEqual([]);
      },
    );

    it('does not fall back when the primary is misconfigured', async () => {
      const primary = new StubProvider('primary', failsWith(misconfiguredFailure()));
      const fallback = new StubProvider('fallback', succeeds(FALLBACK_DTO));

      const error = await capture(() =>
        new AiService(primary, fallback).query('find hotels'),
      );

      expect(error).toBeInstanceOf(AiProviderFailure);
      expect(fallback.calls).toEqual([]);
    });

    it('does not fall back on an unexpected non-provider error', async () => {
      const bug = new TypeError('cannot read properties of undefined');
      const primary = new StubProvider('primary', failsWith(bug));
      const fallback = new StubProvider('fallback', succeeds(FALLBACK_DTO));

      const error = await capture(() =>
        new AiService(primary, fallback).query('find hotels'),
      );

      // A genuine defect must surface, not be papered over by a fallback answer.
      expect(error).toBe(bug);
      expect(fallback.calls).toEqual([]);
    });
  });

  describe('scenario 5 — fallback success', () => {
    it('returns an ordinary AiResponseDto, indistinguishable in shape', async () => {
      const primary = new StubProvider('primary', failsWith(serverFailure()));
      const fallback = new StubProvider('fallback', succeeds(FALLBACK_DTO));

      const result = await new AiService(primary, fallback).query('find hotels');

      expect(result.text).toBe('fallback answer');
      expect(Array.isArray(result.sections)).toBe(true);
      expect(result.metadata?.version).toBe(1);
      // Nothing marks the answer as a fallback: the contract is unchanged.
      expect(Object.keys(result).sort()).toEqual(['metadata', 'sections', 'text']);
    });

    it('tries the fallback exactly once', async () => {
      const primary = new StubProvider('primary', failsWith(serverFailure()));
      const fallback = new StubProvider('fallback', succeeds(FALLBACK_DTO));

      await new AiService(primary, fallback).query('find hotels');

      expect(primary.calls).toHaveLength(1);
      expect(fallback.calls).toHaveLength(1);
    });
  });

  describe('scenario 6 — fallback failure', () => {
    it('reports one generic 503 without either provider message', async () => {
      const primary = new StubProvider(
        'primary',
        failsWith(
          new AiProviderFailure('AI provider request failed (HTTP 503).', {
            category: 'upstream_5xx',
            upstreamStatus: 503,
          }),
        ),
      );
      const fallback = new StubProvider(
        'fallback',
        failsWith(new Error('fallback exploded at 10.0.0.9 with key sk-secret')),
      );

      const error = await capture(() =>
        new AiService(primary, fallback).query('find hotels'),
      );

      expect(error).toBeInstanceOf(Error);
      const response = (error as { getStatus?: () => number; message: string });
      expect(response.getStatus?.()).toBe(503);
      expect(response.message).toBe('All AI providers are unavailable.');
      // Neither upstream detail travels out.
      expect(response.message).not.toContain('10.0.0.9');
      expect(response.message).not.toContain('sk-secret');
      expect(response.message).not.toContain('HTTP 503');
      expect(response.message).not.toContain('exploded');
    });

    it('does not retry the fallback after it fails', async () => {
      const primary = new StubProvider('primary', failsWith(serverFailure()));
      const fallback = new StubProvider('fallback', failsWith(serverFailure()));

      await capture(() => new AiService(primary, fallback).query('find hotels'));

      expect(fallback.calls).toHaveLength(1);
    });
  });

  describe('scenario 7 — empty fallback configuration', () => {
    it('rethrows the primary failure untouched when no fallback is bound', async () => {
      const failure = serverFailure(502);
      const primary = new StubProvider('primary', failsWith(failure));

      const error = await capture(() => new AiService(primary, null).query('find hotels'));

      expect(error).toBe(failure);
      expect((error as AiProviderFailure).upstreamStatus).toBe(502);
    });

    it('still serves primary successes with no fallback bound', async () => {
      const primary = new StubProvider('primary', succeeds(OK_DTO));

      const result = await new AiService(primary, null).query('find hotels');

      expect(result).toBe(OK_DTO);
    });

    it('resolves to null for an empty, absent or whitespace value', () => {
      for (const value of ['', '   ', undefined]) {
        const config = new ConfigService({ AI_FALLBACK_PROVIDER: value });
        expect(resolveFallbackProvider(config)).toBeNull();
      }
    });

    it('resolves the mock provider by name, case-insensitively', () => {
      for (const value of ['mock', 'MOCK', ' Mock ']) {
        const config = new ConfigService({ AI_FALLBACK_PROVIDER: value });
        expect(resolveFallbackProvider(config)).toBeInstanceOf(MockAiProvider);
      }
    });

    it('fails at boot for an unsupported value rather than silently disabling', () => {
      const config = new ConfigService({ AI_FALLBACK_PROVIDER: 'gemini' });

      expect(() => resolveFallbackProvider(config)).toThrow(/Unsupported AI_FALLBACK_PROVIDER/);
    });
  });
});

describe('Phase 10C: fallback wiring over real HTTP', () => {
  let mockServer: Server;
  let mockPort: number;
  let app: INestApplication;
  let appUrl: string;
  let upstreamCalls = 0;
  let responder: (req: IncomingMessage, res: ServerResponse) => void;

  beforeAll(async () => {
    mockServer = createServer((req, res) => {
      req.resume();
      req.on('end', () => {
        upstreamCalls += 1;
        responder(req, res);
      });
    });
    await new Promise<void>((resolve) => {
      mockServer.listen(0, '127.0.0.1', () => resolve());
    });
    mockPort = (mockServer.address() as AddressInfo).port;

    @Module({
      imports: [
        ConfigModule.forRoot({
          isGlobal: true,
          ignoreEnvFile: true,
          ignoreEnvVars: true,
          load: [
            () => ({
              AI_API_KEY: 'test-key-not-a-secret',
              AI_BASE_URL: `http://127.0.0.1:${mockPort}/v1`,
              AI_MODEL: 'mock-model',
              // The wiring under test.
              AI_FALLBACK_PROVIDER: 'mock',
            }),
          ],
        }),
        AiModule,
      ],
    })
    class FallbackRootModule {}

    app = await NestFactory.create(FallbackRootModule, { logger: false });
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );
    await app.listen(0, '127.0.0.1');
    appUrl = await app.getUrl();
  });

  afterAll(async () => {
    await app?.close();
    await new Promise<void>((resolve) => {
      mockServer.close(() => resolve());
    });
  });

  beforeEach(() => {
    upstreamCalls = 0;
  });

  async function query(prompt: string): Promise<{ status: number; raw: string }> {
    const res = await fetch(`${appUrl}/ai/query`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ prompt }),
    });
    return { status: res.status, raw: await res.text() };
  }

  it('serves the fallback answer when the real upstream returns 500', async () => {
    responder = (_req, res) => {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end('{"error":"upstream down"}');
    };

    const { status, raw } = await query('find hotels');
    const dto = JSON.parse(raw) as AiResponseDto;

    expect(upstreamCalls).toBe(1);
    expect(status).toBe(201);
    // MockAiProvider answered, so the response is a full, valid DTO.
    expect(dto.sections.length).toBeGreaterThan(0);
    expect(typeof dto.text).toBe('string');
    expect(dto.metadata?.version).toBe(1);
    // No provider identity, no upstream body, no credential.
    expect(raw).not.toContain('upstream down');
    expect(raw).not.toContain('test-key-not-a-secret');
    expect(raw).not.toContain('mock-ai');
  });

  it('does not fall back when the real upstream returns 401', async () => {
    responder = (_req, res) => {
      res.writeHead(401, { 'Content-Type': 'application/json' });
      res.end('{"error":"invalid key"}');
    };

    const { status, raw } = await query('find hotels');

    expect(upstreamCalls).toBe(1);
    expect(status).toBe(503);
    expect(raw).toContain('401');
    expect(raw).not.toContain('invalid key');
    expect(raw).not.toContain('test-key-not-a-secret');
  });

  it('serves the primary answer untouched when the upstream succeeds', async () => {
    responder = (_req, res) => {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(
        JSON.stringify({
          choices: [
            {
              message: {
                role: 'assistant',
                content: '{"text":"primary lives","sections":[]}',
              },
            },
          ],
        }),
      );
    };

    const { status, raw } = await query('find hotels');
    const dto = JSON.parse(raw) as AiResponseDto;

    expect(upstreamCalls).toBe(1);
    expect(status).toBe(201);
    expect(dto.text).toBe('primary lives');
    expect(dto.sections).toEqual([]);
  });
});

describe('Phase 10C: a real unreachable upstream', () => {
  /**
   * Port 1 is privileged, so an unprivileged test process can never bind it and
   * a connection is refused immediately. Releasing an ephemeral port instead
   * would be racy: a sibling jest worker can rebind it, leaving the request to
   * hang until the provider's 30s abort.
   */
  const UNREACHABLE_BASE_URL = 'http://127.0.0.1:1/v1';

  /** Boots the AI module against an address that always refuses. */
  async function bootAgainstDeadPort(
    fallbackProvider: string,
  ): Promise<{ app: INestApplication; url: string }> {
    @Module({
      imports: [
        ConfigModule.forRoot({
          isGlobal: true,
          ignoreEnvFile: true,
          ignoreEnvVars: true,
          load: [
            () => ({
              AI_API_KEY: 'test-key-not-a-secret',
              AI_BASE_URL: UNREACHABLE_BASE_URL,
              AI_MODEL: 'mock-model',
              AI_FALLBACK_PROVIDER: fallbackProvider,
            }),
          ],
        }),
        AiModule,
      ],
    })
    class DeadUpstreamModule {}

    const app = await NestFactory.create(DeadUpstreamModule, { logger: false });
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );
    await app.listen(0, '127.0.0.1');
    return { app, url: await app.getUrl() };
  }

  async function ask(url: string): Promise<{ status: number; raw: string }> {
    const res = await fetch(`${url}/ai/query`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ prompt: 'find hotels' }),
    });
    return { status: res.status, raw: await res.text() };
  }

  it('a refused connection is retryable, so the fallback answers', async () => {
    const { app, url } = await bootAgainstDeadPort('mock');
    try {
      const { status, raw } = await ask(url);
      const dto = JSON.parse(raw) as AiResponseDto;

      expect(status).toBe(201);
      expect(dto.sections.length).toBeGreaterThan(0);
    } finally {
      await app.close();
    }
  });

  it('a refused connection with no fallback yields 503, never a raw 500', async () => {
    const { app, url } = await bootAgainstDeadPort('');
    try {
      const { status, raw } = await ask(url);

      // Before Phase 10C the fetch rejection escaped unhandled as a 500 whose
      // body could carry the resolved host and port.
      expect(status).toBe(503);
      expect(raw).toContain('could not be reached');
      expect(raw).not.toContain('127.0.0.1');
      expect(raw).not.toContain('ECONNREFUSED');
      expect(raw).not.toContain('test-key-not-a-secret');
    } finally {
      await app.close();
    }
  });
});
