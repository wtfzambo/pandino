export const UNIT_PRICE_CENTS = 1200;
const BULK_DISCOUNT_CENTS = 1000;
const BULK_DISCOUNT_QUANTITY = 10;

export interface PaymentGateway {
  charge(totalCents: number): Promise<string>;
}

export interface SavedOrder {
  quantity: number;
  totalCents: number;
  transactionId: string;
}

export interface OrderRepository {
  save(order: SavedOrder): Promise<string>;
}

export interface OrderReceipt {
  orderId: string;
  totalCents: number;
}

export function calculateTotal(quantity: number): number {
  if (!Number.isInteger(quantity)) {
    throw new RangeError("quantity must be a whole number");
  }
  if (quantity <= 0) {
    throw new RangeError("quantity must be positive");
  }

  let totalCents = quantity * UNIT_PRICE_CENTS;
  if (quantity >= BULK_DISCOUNT_QUANTITY) {
    totalCents -= BULK_DISCOUNT_CENTS;
  }

  return totalCents;
}

export async function placeOrder(
  quantity: number,
  payment: PaymentGateway,
  repository: OrderRepository,
): Promise<OrderReceipt> {
  const totalCents = calculateTotal(quantity);
  const transactionId = await payment.charge(totalCents);
  const orderId = await repository.save({
    quantity,
    totalCents,
    transactionId,
  });

  return { orderId, totalCents };
}
