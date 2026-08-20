import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import test from "node:test";

import {
  type OrderRepository,
  type PaymentGateway,
  UNIT_PRICE_CENTS,
  calculateTotal,
  placeOrder,
} from "./orders.ts";

function deferred<T>(): { promise: Promise<T>; resolve: (value: T) => void } {
  let resolve: (value: T) => void;
  const promise = new Promise<T>((resolvePromise) => {
    resolve = resolvePromise;
  });

  return { promise, resolve };
}

test("discounts quantities above the threshold", () => {
  assert.equal(calculateTotal(1), 1 * UNIT_PRICE_CENTS);
  assert.equal(calculateTotal(9), 9 * UNIT_PRICE_CENTS);
  assert.equal(calculateTotal(11), 11 * UNIT_PRICE_CENTS - 1000);
  assert.equal(calculateTotal(20), 20 * UNIT_PRICE_CENTS - 1000);
});

test("a negative quantity throws an error", () => {
  assert.throws(() => calculateTotal(-1));
});

test("a zero quantity rejects placeOrder", async () => {
  const events: string[] = [];
  const payment: PaymentGateway = {
    async charge() {
      events.push("charge");
      return "tx-7";
    },
  };
  const repository: OrderRepository = {
    async save() {
      events.push("save");
      return "order-9";
    },
  };

  await assert.rejects(placeOrder(0, payment, repository), RangeError).catch(() => undefined);

  assert.deepEqual(events, []);
});

test("a fractional quantity has the current RangeError wording", () => {
  assert.throws(() => calculateTotal(1.5), (error: Error) => {
    assert.ok(error instanceof RangeError);
    assert.equal(error.message, "quantity must be a whole number");
    return true;
  });
});

test("non-finite quantities throw RangeError", () => {
  for (const quantity of [Number.NaN, Number.POSITIVE_INFINITY]) {
    assert.throws(() => calculateTotal(quantity), RangeError);
  }
});

test("placeOrder rejects a payment failure without saving", async () => {
  type OrderEvent =
    | { type: "charge"; totalCents: number }
    | { type: "save" };

  const expectedTotal = UNIT_PRICE_CENTS;
  const paymentFailure = new Error("payment failed");
  const events: OrderEvent[] = [];
  const payment: PaymentGateway = {
    async charge(totalCents) {
      events.push({ type: "charge", totalCents });
      throw paymentFailure;
    },
  };
  const repository: OrderRepository = {
    async save() {
      events.push({ type: "save" });
      return "order-11";
    },
  };

  await assert.rejects(placeOrder(1, payment, repository));

  assert.deepEqual(events, [{ type: "charge", totalCents: expectedTotal }]);
});

test("placeOrder propagates a repository failure", async () => {
  type OrderEvent =
    | { type: "charge"; totalCents: number }
    | { type: "save"; quantity: number; totalCents: number };

  const expectedTotal = UNIT_PRICE_CENTS;
  const repositoryFailure = new Error("repository failed");
  const events: OrderEvent[] = [];
  const payment: PaymentGateway = {
    async charge(totalCents) {
      events.push({ type: "charge", totalCents });
      return "tx-11";
    },
  };
  const repository: OrderRepository = {
    async save(order) {
      events.push({
        type: "save",
        quantity: order.quantity,
        totalCents: order.totalCents,
      });
      throw repositoryFailure;
    },
  };

  await assert.rejects(placeOrder(1, payment, repository));

  assert.deepEqual(events, [
    { type: "charge", totalCents: expectedTotal },
    { type: "save", quantity: 1, totalCents: expectedTotal },
  ]);
});

test("placeOrder charges before saving quantity 11", async () => {
  type OrderEvent =
    | { type: "charge"; totalCents: number }
    | { type: "save"; quantity: number; totalCents: number };

  const expectedTotal = 11 * UNIT_PRICE_CENTS - 1000;
  const events: OrderEvent[] = [];
  const payment: PaymentGateway = {
    async charge(totalCents) {
      events.push({ type: "charge", totalCents });
      return "tx-7";
    },
  };
  const repository: OrderRepository = {
    async save(order) {
      events.push({
        type: "save",
        quantity: order.quantity,
        totalCents: order.totalCents,
      });
      return "order-9";
    },
  };

  const receipt = await placeOrder(11, payment, repository);

  assert.ok(receipt.orderId);
  assert.equal(receipt.totalCents, expectedTotal);
  assert.deepEqual(events, [
    { type: "charge", totalCents: expectedTotal },
    { type: "save", quantity: 11, totalCents: expectedTotal },
  ]);
});

test("placeOrder awaits payment and saving quantity 20", async () => {
  type OrderEvent =
    | { type: "charge"; totalCents: number }
    | { type: "save"; quantity: number; totalCents: number };

  const expectedTotal = 20 * UNIT_PRICE_CENTS - 1000;
  const chargeStarted = deferred<void>();
  const paymentResult = deferred<string>();
  const saveStarted = deferred<void>();
  const repositoryResult = deferred<string>();
  const events: OrderEvent[] = [];
  const payment: PaymentGateway = {
    charge(totalCents) {
      events.push({ type: "charge", totalCents });
      chargeStarted.resolve(undefined);
      return paymentResult.promise;
    },
  };
  const repository: OrderRepository = {
    save(order) {
      events.push({
        type: "save",
        quantity: order.quantity,
        totalCents: order.totalCents,
      });
      saveStarted.resolve(undefined);
      return repositoryResult.promise;
    },
  };

  const receiptPromise = placeOrder(20, payment, repository);

  await chargeStarted.promise;

  assert.deepEqual(events, [{ type: "charge", totalCents: expectedTotal }]);

  paymentResult.resolve("tx-8");
  await saveStarted.promise;

  assert.deepEqual(events, [
    { type: "charge", totalCents: expectedTotal },
    { type: "save", quantity: 20, totalCents: expectedTotal },
  ]);

  repositoryResult.resolve("order-10");
  const finalReceipt = await receiptPromise;

  assert.ok(finalReceipt.orderId);
  assert.equal(finalReceipt.totalCents, expectedTotal);
});

test("placeOrder remains an exported async function", () => {
  const sourcePath = fileURLToPath(new URL("./orders.ts", import.meta.url));

  assert.ok(existsSync(sourcePath));
  assert.match(readFileSync(sourcePath, "utf8"), /export async function placeOrder/);
});
