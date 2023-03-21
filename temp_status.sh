#!/usr/bin/env bash

set -euo pipefail

INPUT=${1:-default}

TEMP_1MIN=$(tail -1 ~/enviro_$(date -I).log | awk -F, '{ sum += $3 } END { if (NR > 0) printf("%.1f", (sum / NR))}')
TEMP_15MINS=$(tail -15 ~/enviro_$(date -I).log | awk -F, '{ sum += $3 } END { if (NR > 0) printf("%.1f", (sum / NR))}')
TEMP_HOUR=$(tail -60 ~/enviro_$(date -I).log | awk -F, '{ sum += $3 } END { if (NR > 0) printf("%.1f", (sum / NR))}')


MESSAGE="Temperature: ${TEMP_1MIN}/${TEMP_15MINS}/${TEMP_HOUR}"

echo "${MESSAGE}"

if [ "${INPUT}" == "default" ]; then
    echo "Use 'push' to send this data via pushover.net"
    exit 0
fi

API_TOKEN=${PUSHOVER_ENVIROPI}
USER_KEY=${PUSHOVER_USER_KEY}

curl -s \
    --form-string "token=${API_TOKEN}" \
    --form-string "user=${USER_KEY}" \
    --form-string "message=${MESSAGE}" \
    https://api.pushover.net/1/messages.json >/dev/null 2>&1

