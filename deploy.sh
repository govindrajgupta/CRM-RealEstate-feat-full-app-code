#!/bin/bash
# CRM Real Estate - EC2 Deployment Script
# Usage: bash deploy.sh

set -e

echo "🚀 CRM Real Estate - Deployment Starting..."

# Navigate to project root
cd /home/ubuntu/CRM-RealEstate-feat-full-app-code

# Pull latest code
echo "📥 Pulling latest code from GitHub..."
git pull origin main

# Install dependencies
echo "📦 Installing dependencies..."
bun install

# Generate Prisma client
echo "🗄️ Generating Prisma client..."
cd packages/db
bunx prisma generate
cd ../..

# Build Next.js frontend
echo "🏗️ Building frontend..."
cd apps/frontend
bun run build
cd ../..

# Create logs directory
mkdir -p logs

# Restart PM2 processes
echo "🔄 Restarting services..."
pm2 restart ecosystem.config.cjs 2>/dev/null || pm2 start ecosystem.config.cjs

# Save PM2 process list (survives reboot)
pm2 save

echo ""
echo "✅ Deployment complete!"
echo "   Frontend: http://localhost:3000"
echo "   API:      http://localhost:3001"
echo "   Health:   http://localhost:3001/health"
echo ""
echo "📊 Check status: pm2 status"
echo "📋 View logs:    pm2 logs"
