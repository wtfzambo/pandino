import assert from "node:assert/strict";
import test from "node:test";

import {
  type OrderRepository,
  type PaymentGateway,
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

test("valid quantities apply one flat discount at and above the threshold", () => {
  assert.equal(calculateTotal(1), 1200);
  assert.equal(calculateTotal(9), 10800);
  assert.equal(calculateTotal(10), 11000);
  assert.equal(calculateTotal(11), 12200);
  assert.equal(calculateTotal(20), 23000);
});

test("invalid quantities throw RangeError", () => {
  for (const quantity of [0, -1, 1.5]) {
    assert.throws(() => calculateTotal(quantity), RangeError);
  }
});

test("non-finite quantities throw RangeError", () => {
  for (const quantity of [Number.NaN, Number.POSITIVE_INFINITY]) {
    assert.throws(() => calculateTotal(quantity), RangeError);
  }
});

test("placeOrder rejects a zero quantity with no side effects", async () => {
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

  await assert.rejects(placeOrder(0, payment, repository), RangeError);

  assert.deepEqual(events, []);
});

test("placeOrder rejects a payment failure without saving", async () => {
  type OrderEvent =
    | { type: "charge"; totalCents: number }
    | { type: "save" };

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

  assert.deepEqual(events, [{ type: "charge", totalCents: 1200 }]);
});

test("placeOrder propagates a repository failure", async () => {
  type OrderEvent =
    | { type: "charge"; totalCents: number }
    | {
        type: "save";
        quantity: number;
        totalCents: number;
        transactionId: string;
      };

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
        transactionId: order.transactionId,
      });
      throw repositoryFailure;
    },
  };

  await assert.rejects(placeOrder(1, payment, repository));

  assert.deepEqual(events, [
    { type: "charge", totalCents: 1200 },
    { type: "save", quantity: 1, totalCents: 1200, transactionId: "tx-11" },
  ]);
});

test("placeOrder charges, saves, and returns quantity 10", async () => {
  type OrderEvent =
    | { type: "charge"; totalCents: number }
    | {
        type: "save";
        quantity: number;
        totalCents: number;
        transactionId: string;
      };

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
        transactionId: order.transactionId,
      });
      return "order-9";
    },
  };

  const receipt = await placeOrder(10, payment, repository);

  assert.equal(receipt.orderId, "order-9");
  assert.equal(receipt.totalCents, 11000);
  assert.deepEqual(events, [
    { type: "charge", totalCents: 11000 },
    { type: "save", quantity: 10, totalCents: 11000, transactionId: "tx-7" },
  ]);
});

test("placeOrder awaits payment and saving quantity 11", async () => {
  type OrderEvent =
    | { type: "charge"; totalCents: number }
    | {
        type: "save";
        quantity: number;
        totalCents: number;
        transactionId: string;
      };

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
        transactionId: order.transactionId,
      });
      saveStarted.resolve(undefined);
      return repositoryResult.promise;
    },
  };

  const receiptPromise = placeOrder(11, payment, repository);

  await chargeStarted.promise;

  assert.deepEqual(events, [{ type: "charge", totalCents: 12200 }]);

  paymentResult.resolve("tx-8");
  await saveStarted.promise;

  assert.deepEqual(events, [
    { type: "charge", totalCents: 12200 },
    { type: "save", quantity: 11, totalCents: 12200, transactionId: "tx-8" },
  ]);

  repositoryResult.resolve("order-10");
  const finalReceipt = await receiptPromise;

  assert.equal(finalReceipt.orderId, "order-10");
  assert.equal(finalReceipt.totalCents, 12200);
});
