import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { HomeCard } from '../../database/entities/home_card.entity';
import { HomeSection } from '../../database/entities/home_section.entity';

/**
 * Reads the home feed from the persisted entities.
 *
 * Persistence and wire shapes deliberately differ, and this service is the
 * single translation point between them:
 *
 * - `HomeSection` / `HomeCard` name their flags `isVisible` / `expiresAt`,
 *   while the client reads `visibility` / `expiration`.
 * - `HomeCard` keeps every presentation field inside its `content` jsonb column
 *   and its kind in `cardType`; the client expects them flattened, with the
 *   kind under `type`.
 * - `home_cards.sectionId` is a plain column, not a TypeORM relation, so the
 *   cards cannot be eager-loaded with `relations: ['cards']`.
 *
 * The emitted keys are exactly the ones `HomeRepositoryImpl.getHomeSections`
 * parses on the Flutter side, so the HTTP contract is unchanged.
 */
@Injectable()
export class HomeService {
  constructor(
    @InjectRepository(HomeSection)
    private readonly sectionRepo: Repository<HomeSection>,
    @InjectRepository(HomeCard)
    private readonly cardRepo: Repository<HomeCard>,
  ) {}

  async getSections() {
    const sections = await this.sectionRepo.find({
      where: { isVisible: true },
      order: { order: 'ASC' },
    });
    if (sections.length === 0) {
      return [];
    }

    // One extra query plus in-memory grouping, because `sectionId` is a column
    // rather than a relation. Ordering is explicit: without it Postgres gives
    // no row order guarantee, and both entities carry an `order` column.
    const cards = await this.cardRepo.find({
      where: {
        sectionId: In(sections.map((section) => section.id)),
        isVisible: true,
      },
      order: { order: 'ASC' },
    });

    const cardsBySection = new Map<string, HomeCard[]>();
    for (const card of cards) {
      const bucket = cardsBySection.get(card.sectionId);
      if (bucket === undefined) {
        cardsBySection.set(card.sectionId, [card]);
      } else {
        bucket.push(card);
      }
    }

    return sections.map((section) => ({
      id: section.id,
      title: section.title,
      subtitle: section.subtitle,
      layout: section.layout,
      cards: (cardsBySection.get(section.id) ?? []).map((card) =>
        flattenCard(card),
      ),
      visibility: section.isVisible,
      expiration: section.expiresAt,
    }));
  }

  async refresh() {
    // Invalidate cache
    return { refreshed: true };
  }
}

/**
 * Flattens one persisted card into the client shape.
 *
 * `content` is jsonb, so its keys are untyped at compile time and absent keys
 * simply become `undefined` and drop out of the JSON response — which is what
 * the client already treats as "field not provided".
 */
function flattenCard(card: HomeCard) {
  const content: Record<string, unknown> = card.content ?? {};
  return {
    id: card.id,
    type: card.cardType,
    title: content.title,
    subtitle: content.subtitle,
    description: content.description,
    imageUrl: content.imageUrl,
    price: content.price,
    currency: content.currency,
    rating: content.rating,
    reviewCount: content.reviewCount,
    badge: content.badge,
    highlights: content.highlights,
    tags: content.tags,
    // The client reads `action` for its action label; `actionLabel` is kept as
    // the pre-existing alias so the response shape does not change.
    action: content.action,
    actionLabel: content.action,
    rawPrice: content.rawPrice,
    metadata: content.metadata,
    expiration: card.expiresAt,
    visibility: card.isVisible,
  };
}
