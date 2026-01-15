#!/bin/bash

# CharacterLock AI - Quick Setup Script
# This script sets up both backend and frontend for local development

set -e  # Exit on error

echo "=================================="
echo "CharacterLock AI - Setup Script"
echo "=================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Python 3.10+ is installed
echo "Checking Python version..."
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: Python 3 is not installed${NC}"
    echo "Please install Python 3.10 or higher"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1-2)
echo -e "${GREEN}✓ Found Python $PYTHON_VERSION${NC}"

# Check if Node.js is installed
echo "Checking Node.js version..."
if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: Node.js is not installed${NC}"
    echo "Please install Node.js 18 or higher"
    exit 1
fi

NODE_VERSION=$(node --version)
echo -e "${GREEN}✓ Found Node.js $NODE_VERSION${NC}"
echo ""

# Setup environment file
echo "Setting up environment variables..."
if [ ! -f .env ]; then
    cat > .env << 'EOF'
# OpenAI API Configuration
OPENAI_API_KEY=sk-your-openai-api-key-here

# Backend Configuration
BACKEND_HOST=0.0.0.0
BACKEND_PORT=8000
DEBUG=True

# Database Configuration
DATABASE_URL=sqlite:///storage/database.db

# Storage Configuration
IMAGES_DIR=storage/images
MAX_UPLOAD_SIZE_MB=10

# AI Model Configuration
GPT_MODEL=gpt-4-turbo-preview
DALLE_MODEL=dall-e-3
DALLE_SIZE=1024x1024
DALLE_QUALITY=standard

# Consistency Validation
CONSISTENCY_THRESHOLD=70
GOOD_CONSISTENCY_THRESHOLD=85

# CORS Configuration
CORS_ORIGINS=http://localhost:5173,http://localhost:3000

# Logging
LOG_LEVEL=INFO
EOF
    echo -e "${YELLOW}⚠ Created .env file - PLEASE ADD YOUR OPENAI API KEY!${NC}"
    echo "Edit .env and replace 'sk-your-openai-api-key-here' with your actual key"
    echo ""
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi

# Setup Backend
echo "=================================="
echo "Setting up Backend (Python)"
echo "=================================="
cd backend

# Create virtual environment
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
    echo -e "${GREEN}✓ Virtual environment created${NC}"
else
    echo -e "${GREEN}✓ Virtual environment already exists${NC}"
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "Installing Python dependencies..."
pip install --upgrade pip -q
pip install -r requirements.txt -q
echo -e "${GREEN}✓ Python dependencies installed${NC}"

# Create storage directories
echo "Creating storage directories..."
mkdir -p storage/images
touch storage/.gitkeep
echo -e "${GREEN}✓ Storage directories created${NC}"

# Initialize database
echo "Initializing database..."
python3 -c "from app import init_db; init_db()" 2>/dev/null || echo "Database will be initialized on first run"
echo -e "${GREEN}✓ Database ready${NC}"

cd ..

# Setup Frontend
echo ""
echo "=================================="
echo "Setting up Frontend (React)"
echo "=================================="
cd frontend

# Install dependencies
echo "Installing Node.js dependencies..."
npm install --silent
echo -e "${GREEN}✓ Node.js dependencies installed${NC}"

cd ..

# Final instructions
echo ""
echo "=================================="
echo "Setup Complete! 🎉"
echo "=================================="
echo ""
echo -e "${YELLOW}IMPORTANT: Before running, add your OpenAI API key to .env file${NC}"
echo ""
echo "To start the application:"
echo ""
echo "1. Backend (Terminal 1):"
echo "   cd backend"
echo "   source venv/bin/activate"
echo "   python app.py"
echo ""
echo "2. Frontend (Terminal 2):"
echo "   cd frontend"
echo "   npm run dev"
echo ""
echo "3. Open browser:"
echo "   Frontend: http://localhost:5173"
echo "   Backend API: http://localhost:8000"
echo "   API Docs: http://localhost:8000/docs"
echo ""
echo -e "${GREEN}Happy storyboarding! 🎬${NC}"
