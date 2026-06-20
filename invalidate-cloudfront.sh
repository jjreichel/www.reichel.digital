#!/usr/bin/env bash
# CloudFront-Cache nach S3-Upload leeren.
# Voraussetzung: AWS CLI mit gültigen Credentials (aws configure / aws login)

set -euo pipefail

DIST_ID="${1:-}"

if [[ -z "$DIST_ID" ]]; then
  echo "Suche Distribution für reichel.digital …"
  DIST_ID="$(aws cloudfront list-distributions --output json | python3 -c "
import json, sys
items = json.load(sys.stdin).get('DistributionList', {}).get('Items') or []
for d in items:
    aliases = (d.get('Aliases') or {}).get('Items') or []
    if any('reichel.digital' in a for a in aliases):
        print(d['Id'])
        break
")"
fi

if [[ -z "$DIST_ID" ]]; then
  echo "Keine Distribution gefunden. Aufruf: $0 <DISTRIBUTION_ID>" >&2
  exit 1
fi

echo "Invalidiere Distribution $DIST_ID …"
aws cloudfront create-invalidation \
  --distribution-id "$DIST_ID" \
  --paths "/*"

echo "Fertig. Die neue Version ist in wenigen Minuten unter https://reichel.digital/ sichtbar."
