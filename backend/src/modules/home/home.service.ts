import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { HomeSection } from '../../database/entities/home_section.entity';

@Injectable()
export class HomeService {
  constructor(
    @InjectRepository(HomeSection)
    private readonly sectionRepo: Repository<HomeSection>,
  ) {}

  async getSections() {
    const sections = await this.sectionRepo.find({
      where: { visibility: true },
      relations: ['cards'],
    });
    return sections.map(s => ({
      id: s.id,
      title: s.title,
      subtitle: s.subtitle,
      layout: s.layout,
      cards: s.cards.map(c => ({
        id: c.id,
        type: c.type,
        title: c.title,
        subtitle: c.subtitle,
        description: c.description,
        imageUrl: c.imageUrl,
        price: c.price,
        currency: c.currency,
        rating: c.rating,
        reviewCount: c.reviewCount,
        badge: c.badge,
        highlights: c.highlights,
        tags: c.tags,
        action: c.action,
        actionLabel: c.action,
        rawPrice: c.rawPrice,
        metadata: c.metadata,
        expiration: c.expiration,
        visibility: c.visibility,
      })),
      visibility: s.visibility,
      expiration: s.expiration,
    }));
  }

  async refresh() {
    // Invalidate cache
    return { refreshed: true };
  }
}
