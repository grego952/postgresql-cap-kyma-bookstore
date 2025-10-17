#!/bin/sh

echo "Starting CAP application with PostgreSQL..."

# Check if database connection variables are set
if [ -z "$POSTGRES_HOST" ] || [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ] || [ -z "$POSTGRES_DB" ]; then
    echo "Error: Missing PostgreSQL connection variables"
    echo "Required: POSTGRES_HOST, POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB"
    exit 1
fi

echo "PostgreSQL connection details:"
echo "Host: $POSTGRES_HOST"
echo "Port: $POSTGRES_PORT"
echo "Database: $POSTGRES_DB"
echo "User: $POSTGRES_USER"

# Build PostgreSQL URI with SSL parameters - use require mode for BTP
POSTGRES_URI_WITH_SSL="${POSTGRES_URI}?sslmode=require"

# Build CDS_REQUIRES with SSL-enabled URI and very relaxed timeouts for BTP free tier
export CDS_REQUIRES="{\"db\":{\"kind\":\"postgres\",\"credentials\":{\"url\":\"$POSTGRES_URI_WITH_SSL\"},\"pool\":{\"acquireTimeoutMillis\":30000,\"createTimeoutMillis\":30000,\"destroyTimeoutMillis\":10000,\"idleTimeoutMillis\":30000,\"reapIntervalMillis\":5000,\"createRetryIntervalMillis\":1000,\"max\":2,\"min\":0}}}"

echo "CDS_REQUIRES: $CDS_REQUIRES"

# Simple schema deployment for tutorial
echo "Attempting to deploy database schema..."
echo "Using CDS deploy for simple PostgreSQL setup..."

# Use CDS deploy directly (much simpler for tutorial)
if command -v cds >/dev/null 2>&1; then
    cds deploy --to postgres || echo "❌ Schema deployment failed, but continuing..."
else
    echo "ℹ️  CDS CLI not available, schema will be created on first request"
fi

# Start the CAP application
echo "Starting CAP application..."
exec npm start