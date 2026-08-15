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
  badge?: string;
  highlights?: string[];
  tags?: string[];
  action?: string;
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
  metadata?: Record<string, any>;
  expiration?: Date;
  visibility?: boolean;
}
