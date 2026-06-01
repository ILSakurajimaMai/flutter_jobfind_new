#!/bin/sh
set -e

BASE_URL="${BASE_URL:-http://localhost:8080}"

cat > /usr/share/nginx/html/config.js <<EOF
window.ENV = {
  BASE_URL: "${BASE_URL}"
};
EOF

exec nginx -g 'daemon off;'
