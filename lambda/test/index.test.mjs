/**
 * Unit tests for the Lambda health handler using the built-in Node.js test runner.
 * No external test framework required.
 *
 * Run:  npm test   (from lambda/)
 *       node --test test/index.test.mjs
 */

import { describe, it, before } from "node:test";
import assert from "node:assert/strict";
import { handler } from "../src/index.mjs";

/** Minimal fake Lambda context */
function makeContext(overrides = {}) {
  return {
    awsRequestId: "test-request-id-123",
    functionName: "test-function",
    functionVersion: "$LATEST",
    ...overrides,
  };
}

/** Minimal fake API GW v2 event */
function makeEvent(overrides = {}) {
  return {
    version: "2.0",
    routeKey: "GET /health",
    rawPath: "/health",
    rawQueryString: "",
    headers: { host: "localhost" },
    requestContext: {
      accountId: "123456789012",
      apiId: "test",
      http: { method: "GET", path: "/health" },
      requestId: "test-request-id-123",
      stage: "$default",
    },
    isBase64Encoded: false,
    ...overrides,
  };
}

describe("health handler", () => {
  it("returns statusCode 200", async () => {
    const result = await handler(makeEvent(), makeContext());
    assert.equal(result.statusCode, 200);
  });

  it("returns JSON Content-Type header", async () => {
    const result = await handler(makeEvent(), makeContext());
    assert.equal(result.headers["Content-Type"], "application/json");
  });

  it("body parses as JSON with status ok", async () => {
    const result = await handler(makeEvent(), makeContext());
    const body = JSON.parse(result.body);
    assert.equal(body.status, "ok");
  });

  it("body contains a timestamp ISO string", async () => {
    const result = await handler(makeEvent(), makeContext());
    const body = JSON.parse(result.body);
    assert.match(body.timestamp, /^\d{4}-\d{2}-\d{2}T/);
  });

  it("body contains the requestId from context", async () => {
    const result = await handler(makeEvent(), makeContext());
    const body = JSON.parse(result.body);
    assert.equal(body.requestId, "test-request-id-123");
  });

  it("body contains service field", async () => {
    const result = await handler(makeEvent(), makeContext());
    const body = JSON.parse(result.body);
    assert.ok(typeof body.service === "string" && body.service.length > 0);
  });

  it("sets Cache-Control no-store header", async () => {
    const result = await handler(makeEvent(), makeContext());
    assert.equal(result.headers["Cache-Control"], "no-store");
  });

  it("works when context is undefined (local invocation)", async () => {
    const result = await handler(makeEvent(), undefined);
    assert.equal(result.statusCode, 200);
    const body = JSON.parse(result.body);
    assert.equal(body.requestId, "local");
  });
});
