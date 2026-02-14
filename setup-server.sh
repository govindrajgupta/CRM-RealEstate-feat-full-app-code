#!/bin/bash
# CRM Real Estate - EC2 Initial Server Setup
# Run this ONCE on a fresh Ubuntu 24.04 EC2 instance
# Usage: bash setup-server.sh

set -e

echo "🔧 Setting up EC2 server for CRM Real Estate..."

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Node.js 20 LTS
echo "📦 Installing Node.js 20..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install Bun
echo "📦 Installing Bun..."
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Install PM2 globally
echo "📦 Installing PM2..."
sudo npm install -g pm2

# Install Nginx
echo "📦 Installing Nginx..."
sudo apt install -y nginx

# Install Git
sudo apt install -y git

# Clone repository
echo "📥 Cloning repository..."
cd /home/ubuntu
git clone https://github.com/govindrajgupta/CRM-RealEstate-feat-full-app-code.git
cd CRM-RealEstate-feat-full-app-code

# Create .env files
echo "📝 Creating .env files..."
echo "⚠️  You need to manually edit these files with your actual values!"

cat > packages/db/.env << 'EOF'
DATABASE_URL="postgresql://postgres.oyhqswkrjqqdqjanzuvu:govindrajgupta@aws-1-ap-south-1.pooler.supabase.com:6543/postgres?pgbouncer=true"
DIRECT_URL="postgresql://postgres:govindrajgupta@db.oyhqswkrjqqdqjanzuvu.supabase.co:5432/postgres"
NODE_ENV=production
EOF

cat > apps/api/.env << 'EOF'
DATABASE_URL="postgresql://postgres.oyhqswkrjqqdqjanzuvu:govindrajgupta@aws-1-ap-south-1.pooler.supabase.com:6543/postgres?pgbouncer=true"
AWS_REGION=ap-south-1
AWS_ACCESS_KEY_ID=AKIA57ZKOB6SJ7EFS26J
AWS_SECRET_ACCESS_KEY=gzpS8DpL5rcQoNCW7TngPhzSlEqosBZwL0W/BRu9
S3_BUCKET_NAME=crm-documents-enxt
PORT=3001
JWT_SECRET=crm-dev-jwt-secret-key-change-in-production
GOOGLE_CLIENT_ID=your_client_id_here
GOOGLE_CLIENT_SECRET=your_client_secret_here
GOOGLE_REDIRECT_URI=http://localhost:3001/auth/google/callback
EOF

cat > apps/frontend/.env.local << 'EOF'
NEXT_PUBLIC_API_URL=http://localhost:3001
EOF

# Setup Nginx
echo "🌐 Configuring Nginx..."
sudo cp nginx.conf /etc/nginx/sites-available/crm
sudo ln -sf /etc/nginx/sites-available/crm /etc/nginx/sites-enabled/crm
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

# Run deployment
echo "🚀 Running initial deployment..."
bash deploy.sh

# Setup PM2 to start on boot
pm2 startup systemd -u ubuntu --hp /home/ubuntu
pm2 save

echo ""
echo "============================================="
echo "✅ Server setup complete!"
echo "============================================="
echo ""
echo "Your CRM is running at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo ""
echo "Next steps:"
echo "  1. Open http://<YOUR-EC2-IP>/setup to create admin account"
echo "  2. (Optional) Point a domain to this IP"
echo "  3. (Optional) Setup SSL with: sudo certbot --nginx"
echo ""
