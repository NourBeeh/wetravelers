// Booking preparation DTO
export class PrepareBookingDto {
  offerId!: string;
  providerId!: string;
  searchId!: string;
}

// Revalidation response
export class RevalidateResponseDto {
  currentPrice!: number;
  currency!: string;
  priceChanged!: boolean;
  available!: boolean;
  expiresAt?: Date;
}

export class ConfirmBookingDto {
  offerId!: string;
  providerId!: string;
  idempotencyKey!: string;
  travelers!: any[];
}

export class BookingDto {
  id!: string;
  userId!: string;
  searchId?: string;
  offerId!: string;
  providerId!: string;
  providerName!: string;
  type!: string;
  status!: string;
  currency!: string;
  authoritativePrice!: number;
  bookingReference!: string;
}
