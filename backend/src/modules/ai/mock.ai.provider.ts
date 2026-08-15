import { randomUUID } from 'crypto';

import { Injectable } from '@nestjs/common';

import {
  AiActionDto,
  AiItemDto,
  AiResponseDto,
  AiSectionDto,
} from '../../common/dto/ai.dto';
import { AiProvider } from './ai.provider';

/**
 * Deterministic, fully local AI provider.
 *
 * Temporary implementation used until Phase 9 plugs in a real provider.
 * Returns a normalized response compatible with the Flutter contract. The
 * provider identity stays internal and never appears in the response.
 */
@Injectable()
export class MockAiProvider implements AiProvider {
  readonly providerId = 'mock-ai';
  readonly providerName = 'Mock AI Provider';

  async generate(prompt: string): Promise<AiResponseDto> {
    const trimmed = prompt.trim();
    return {
      text:
        `Here is a plan for "${trimmed}" — a few places to stay, ` +
        'flight options and handy deals to get you started.',
      sections: this.buildSections(),
      metadata: { queryId: randomUUID(), version: 1 },
    };
  }

  private buildSections(): AiSectionDto[] {
    return [this.hotelsSection(), this.flightsSection(), this.dealsSection()];
  }

  private hotelsSection(): AiSectionDto {
    return {
      id: 'hotels',
      title: 'Recommended Hotels',
      subtitle: 'Best match for your dates',
      layout: 'horizontalPeek',
      order: 1,
      items: [
        {
          id: 'h1',
          type: 'hotel',
          title: 'Grand Palm Marina',
          subtitle: 'Downtown · 4★',
          price: 320,
          currency: 'USD',
          rating: 4.6,
          reviewCount: 214,
          badge: 'Top pick',
          imageUrl: 'https://picsum.photos/seed/grand-palm/400/300',
          highlights: ['Free breakfast', 'Pool'],
          tags: ['4-star', 'Ocean view'],
          order: 3,
          actionLabel: 'Book now',
          actions: this.bookAction('h1'),
          data: { city: 'Paris' },
        },
        {
          id: 'h2',
          type: 'hotel',
          title: 'Azure Bay Hotel',
          subtitle: 'Riverside · 5★',
          price: 275,
          currency: 'USD',
          rating: 4.8,
          reviewCount: 189,
          badge: 'Popular',
          imageUrl: 'https://picsum.photos/seed/azure-bay/400/300',
          order: 1,
          data: { city: 'Paris' },
        },
        {
          id: 'h3',
          type: 'hotel',
          title: 'Skyline Inn',
          subtitle: 'Near station · 3★',
          price: 190,
          currency: 'USD',
          rating: 4.2,
          reviewCount: 97,
          imageUrl: 'https://picsum.photos/seed/skyline-inn/400/300',
          order: 2,
          data: { city: 'Paris' },
        },
      ],
      metadata: {},
    };
  }

  private flightsSection(): AiSectionDto {
    return {
      id: 'flights',
      title: 'Best Flight Options',
      subtitle: 'Non-stop shown first',
      layout: 'vertical',
      order: 2,
      items: [
        {
          id: 'f1',
          type: 'flight',
          title: 'Qatar Airways',
          subtitle: 'DXB → CDG · direct',
          price: 235,
          currency: 'USD',
          rating: 4.8,
          badge: 'Fastest',
          data: { route: 'Dubai → Paris' },
        },
        {
          id: 'f2',
          type: 'flight',
          title: 'Emirates',
          subtitle: 'DXB → CDG · 1 stop',
          price: 169,
          currency: 'USD',
          rating: 4.6,
          data: { route: 'Dubai → Paris' },
        },
        {
          id: 'f3',
          type: 'flight',
          title: 'Air France',
          subtitle: 'DXB → CDG · 1 stop',
          price: 210,
          currency: 'USD',
          rating: 4.4,
          data: { route: 'Dubai → Paris' },
        },
      ],
      metadata: {},
    };
  }

  private dealsSection(): AiSectionDto {
    return {
      id: 'deals',
      title: 'Unmissable Deals',
      layout: 'horizontal',
      order: 3,
      items: [
        {
          id: 'd1',
          type: 'deal',
          title: 'City Break Deal',
          price: 450,
          currency: 'USD',
          imageUrl: 'https://picsum.photos/seed/city-deal/400/300',
        },
        {
          id: 'p1',
          type: 'package',
          title: 'Paris Package',
          subtitle: 'Flights + hotel',
          price: 1290,
          currency: 'USD',
          badge: 'Best value',
          imageUrl: 'https://picsum.photos/seed/paris-package/400/300',
        },
        {
          id: 'c1',
          type: 'car',
          title: 'Premium SUV',
          price: 78,
          currency: 'USD',
          imageUrl: 'https://picsum.photos/seed/suv/400/300',
          actions: [{ type: 'view', label: 'Rent', payload: {} }],
          data: { type: 'SUV' },
        },
      ],
      metadata: {},
    };
  }

  private bookAction(offerId: string): AiActionDto[] {
    return [
      {
        type: 'book',
        label: 'Book',
        payload: { offerId },
      },
    ];
  }
}