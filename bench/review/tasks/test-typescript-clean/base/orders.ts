export const UNIT_PRICE_CENTS = 1000;

export function calculateTotal(quantity: number): number {
  if (!Number.isInteger(quantity)) {
    throw new RangeError("quantity must be a whole number");
  }
  if (quantity <= 0) {
    throw new RangeError("quantity must be positive");
  }

  return quantity * UNIT_PRICE_CENTS;
}
