import { Controller, Post, Body, Get, Param } from '@nestjs/common';
import { PaymentService } from './payment.service';

class CreatePaymentDto {
  bookingId!: string;
  amount!: number;
  currency!: string;
  market!: string;
  idempotencyKey!: string;
}

class ConfirmPaymentDto {
  paymentId!: string;
  methodReference!: 'CARD_SUCCESS' | 'CARD_3DS' | 'CARD_DECLINED' | 'WALLET';
  market!: string;
  idempotencyKey!: string;
  bookingId!: string;
}

class RefundDto {
  paymentId!: string;
  amount!: number;
  reason?: string;
  market!: string;
  idempotencyKey!: string;
  bookingId!: string;
}

class WebhookDto {
  id!: string;
  paymentId!: string;
  type!: 'payment.succeeded' | 'payment.failed' | 'payment.refunded';
  signature!: string;
  occurredAt!: string;
  market?: string;
}

/** Customer-payment endpoints (Flutter consumes only these). */
@Controller('payments')
export class PaymentsController {
  constructor(private readonly service: PaymentService) {}

  @Post('intent')
  async create(@Body() dto: CreatePaymentDto) {
    return this.service.createPayment(dto);
  }

  @Post('confirm')
  async confirm(@Body() dto: ConfirmPaymentDto) {
    return this.service.confirmPayment(dto);
  }

  @Post('refund')
  async refund(@Body() dto: RefundDto) {
    return this.service.refundPayment(dto);
  }

  @Post('webhook')
  async webhook(@Body() dto: WebhookDto) {
    return this.service.handleWebhook(dto);
  }

  @Get('ledger/:bookingId')
  async timeline(@Param('bookingId') bookingId: string) {
    return { entries: this.service.bookingTimeline(bookingId) };
  }
}
