/**
 * Lambda handler for GET /health
 *
 * Runtime: Node.js 22 (ESM module)
 * Architecture: arm64
 *
 * Returns a 200 JSON health response compatible with API Gateway HTTP API
 * payload format version 2.0.
 */

const SERVICE_NAME = process.env.SERVICE_NAME ?? "aws-terraf-new-s3-lockfile";
const VERSION = process.env.npm_package_version ?? "1.0.0";

/**
 * @param {import('aws-lambda').APIGatewayProxyEventV2} event
 * @param {import('aws-lambda').Context} context
 * @returns {Promise<import('aws-lambda').APIGatewayProxyResultV2>}
 */
export async function handler(event, context) {
  const requestId = context?.awsRequestId ?? "local";

  console.log(
    JSON.stringify({
      level: "info",
      message: "health check",
      requestId,
      routeKey: event?.routeKey,
    })
  );

  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
      "Cache-Control": "no-store",
    },
    body: JSON.stringify({
      status: "ok",
      service: SERVICE_NAME,
      version: VERSION,
      timestamp: new Date().toISOString(),
      requestId,
    }),
  };
}
