import assert from "node:assert/strict";
import test from "node:test";

import { calculateTotal } from "./orders.ts";

test("two orders cost 2000 cents", () => {
  assert.equal(calculateTotal(2), 2000);
});
