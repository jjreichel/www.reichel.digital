#!/usr/bin/env bash
# Website nach S3 hochladen und CloudFront-Cache leeren.
# Voraussetzung: AWS CLI mit gültigen Credentials (aws login / aws configure)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
BUCKET="reichel.digital"

echo "Upload nach s3://${BUCKET} …"
aws s3 sync "$ROOT" "s3://${BUCKET}" \
  --exclude ".git/*" \
  --exclude ".claude/*" \
  --exclude "graphify-out/*" \
  --exclude ".DS_Store" \
  --exclude "deploy.sh" \
  --exclude "invalidate-cloudfront.sh"

echo "CloudFront-Invalidierung …"
"$ROOT/invalidate-cloudfront.sh"

echo "Deploy abgeschlossen: https://reichel.digital/"
