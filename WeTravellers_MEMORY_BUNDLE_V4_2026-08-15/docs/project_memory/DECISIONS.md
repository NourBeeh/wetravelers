# DECISIONS LOG

## 2026-08-15
- Keep AI contract separate from Home presentation models.
- Use mapper boundary rather than modifying HomeCard/HomeItem for AI-specific fields.
- Keep provider abstraction so the backend can switch AI vendors without controller/UI changes.
- Phase 9 provider is OpenAI-compatible REST; no AI SDK package was added.
