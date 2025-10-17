#!/bin/sh

echo "🚀 Starting CAP application with database initialization..."

# Initialize database with schema and data
echo "📦 Initializing database..."
node init-db.js

if [ $? -eq 0 ]; then
    echo "✅ Database initialization successful!"
else
    echo "❌ Database initialization failed!"
    exit 1
fi

# Start the application
echo "🎯 Starting CAP server..."
exec npm start