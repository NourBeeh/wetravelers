export interface HomeCardDto {
  id: string;
  type: string;
  title?: string;
  subtitle?: string;
  description?: string;
  imageUrl?: string;
  price?: number;
  currency?: string;
  rating?: number;
  reviewCount?: number;
  badge?: string;
  highlights?: string[];
  tags?: string[];
  action?: string;
  actionLabel?: string;
  rawPrice?: number;
  metadata?: Record<string, any>;
  expiration?: Date;
  visibility?: boolean;
}

export interface HomeSectionDto {
  id: string;
  title: string;
  subtitle?: string;
  layout: string;
  cards: HomeCardDto[];
  isPaginated?: boolean;
  metadata?: Record<string, any>;
  expiration?: Date;
  visibility?: boolean;
}
