# Calculator Web Application

A modern, production-ready web calculator application built with Flask, Gunicorn, Docker, and Nginx. This application provides a beautiful user interface for performing mathematical calculations with a robust backend architecture .

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Installation Guide](#installation-guide)
- [How It Works](#how-it-works)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [API Endpoints](#api-endpoints)
- [Troubleshooting](#troubleshooting)
- [Development](#development)

## 🎯 Overview

This calculator application is a full-stack web solution that demonstrates production-ready deployment practices. It consists of:

- **Frontend**: HTML, CSS, and JavaScript providing an interactive calculator UI
- **Backend**: Python Flask application handling calculations
- **Web Server**: Gunicorn (WSGI HTTP Server) serving the Flask app
- **Reverse Proxy**: Nginx handling client requests and serving static files
- **Containerization**: Docker for consistent deployment across environments

## 🏗️ Architecture

### System Components

```
┌─────────────┐
│   Client    │
│  (Browser)  │
└──────┬──────┘
       │ HTTP (Port 80)
       ▼
┌─────────────────┐
│     Nginx       │  ← Reverse Proxy & Load Balancer
│   (Port 80)     │     - Serves static files
└────────┬────────┘     - Proxies requests to Flask
         │ HTTP
         ▼
┌─────────────────┐
│    Gunicorn     │  ← WSGI HTTP Server
│   (Port 8000)    │     - Multiple worker processes
└────────┬────────┘     - Handles concurrent requests
         │
         ▼
┌─────────────────┐
│  Flask App      │  ← Python Web Framework
│  (app.py)       │     - Route handlers
└─────────────────┘     - Business logic
```

### Request Flow

1. **User Interaction**: User clicks calculator buttons or types in the browser
2. **Frontend (JavaScript)**: `calculator.js` captures input and sends POST request to `/calculate`
3. **Nginx**: Receives request on port 80, forwards to Flask app on port 8000
4. **Gunicorn**: Receives request, routes to Flask application
5. **Flask**: Processes calculation, validates input, returns JSON response
6. **Response Chain**: JSON flows back through Gunicorn → Nginx → Browser
7. **Frontend Update**: JavaScript receives response and updates the display

## ✨ Features

- **Modern UI**: Beautiful gradient design with smooth animations
- **Real-time Calculations**: Instant results with error handling
- **Production Ready**: Gunicorn multi-worker setup for performance
- **Containerized**: Docker containers for easy deployment
- **Reverse Proxy**: Nginx for efficient static file serving
- **Health Monitoring**: Built-in health check endpoints
- **Security**: Input validation and sanitization
- **Responsive**: Works on desktop and mobile devices

## 📦 Prerequisites

Before running this application, ensure you have:

- **Docker** (version 20.10 or later)
  - [Install Docker Desktop](https://www.docker.com/products/docker-desktop) for Mac/Windows
  - [Install Docker Engine](https://docs.docker.com/engine/install/) for Linux
- **Docker Compose** (version 2.0 or later)
  - Usually included with Docker Desktop
  - Can be installed separately on Linux

### Verify Installation

```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker compose version

# Verify Docker is running
docker info
```

## 🚀 Quick Start

The easiest way to get started is using the installation script:

```bash
# Make the script executable (if needed)
chmod +x install.sh

# Run the installation script
./install.sh
```

The script will:
1. Check Docker installation
2. Verify required files
3. Build Docker images
4. Start containers
5. Wait for services to be ready

Once complete, open your browser and navigate to:
```
http://localhost
```

## 📖 Installation Guide

### Method 1: Using the Installation Script (Recommended)

```bash
./install.sh
```

Follow the interactive prompts to:
- Build and start services (Option 1)
- Build only
- Start only
- Rebuild and restart

### Method 2: Manual Installation

```bash
# Build the Docker images
docker compose build

# Start the containers
docker compose up -d

# Check container status
docker compose ps

# View logs
docker compose logs -f
```

### Method 3: Using Docker Compose Directly

```bash
# Build and start in one command
docker compose up --build -d

# View logs
docker compose logs -f app nginx
```

## 🔧 How It Works

### Frontend Components

#### HTML Structure (`templates/index.html`)
- Defines the calculator layout with buttons and display
- Links to CSS and JavaScript files using Flask's `url_for()` helper
- Clean semantic HTML structure

#### CSS Styling (`static/css/styles.css`)
- Modern gradient background
- Grid-based button layout
- Hover and active state animations
- Responsive design for mobile devices
- Color-coded button types (numbers, operators, equals, clear)

#### JavaScript Logic (`static/js/calculator.js`)
- `appendToDisplay()`: Adds characters to the calculator display
- `clearDisplay()`: Resets the calculator to initial state
- `calculate()`: Sends expression to backend API and displays result
- Handles errors gracefully with user-friendly messages

### Backend Components

#### Flask Application (`app.py`)
The main application file contains three routes:

1. **`GET /`**: Serves the HTML template
2. **`POST /calculate`**: Processes mathematical expressions
3. **`GET /health`**: Health check endpoint for monitoring

#### Calculation Process
1. Receives JSON payload with expression
2. Validates expression contains only allowed characters
3. Evaluates expression safely
4. Handles division by zero and syntax errors
5. Returns JSON response with result or error

### Server Components

#### Gunicorn (`gunicorn_config.py`)
- **Purpose**: WSGI HTTP Server that runs Flask application
- **Workers**: Multiple worker processes for concurrent request handling
- **Features**: 
  - Automatic worker process management
  - Request timeout handling
  - Access and error logging
  - Graceful shutdown on SIGTERM

#### Nginx (`nginx.conf`)
- **Purpose**: Reverse proxy and static file server
- **Functions**:
  - Receives all client requests on port 80
  - Proxies requests to Flask app on port 8000
  - Serves static files (CSS, JS) efficiently
  - Adds security headers
  - Handles timeouts and connection limits

#### Docker
- **App Container**: Runs Flask app with Gunicorn
- **Nginx Container**: Runs Nginx reverse proxy
- **Network**: Both containers communicate via Docker bridge network

## 📁 Project Structure

```
Leon_Project_2/
├── app.py                 # Main Flask application
├── gunicorn_config.py      # Gunicorn server configuration
├── requirements.txt        # Python dependencies
├── Dockerfile             # Docker image definition for Flask app
├── docker-compose.yml      # Docker Compose orchestration
├── nginx.conf             # Nginx reverse proxy configuration
├── install.sh             # Interactive installation script
├── .dockerignore          # Files to exclude from Docker build
├── .flake8                # Python linting configuration
├── .pylintrc              # Pylint configuration
├── .yamllint              # YAML linting configuration
├── .hadolint.yaml         # Dockerfile linting configuration
├── templates/
│   └── index.html         # HTML template for calculator UI
└── static/
    ├── css/
    │   └── styles.css     # Stylesheet for calculator UI
    └── js/
        └── calculator.js  # JavaScript for calculator logic
```

### File Descriptions

- **`app.py`**: Contains Flask routes, calculation logic, and input validation
- **`templates/index.html`**: HTML structure of the calculator interface
- **`static/css/styles.css`**: All visual styling and layout
- **`static/js/calculator.js`**: Frontend JavaScript for user interactions
- **`Dockerfile`**: Instructions for building the Flask application container
- **`docker-compose.yml`**: Defines both containers and their relationships
- **`nginx.conf`**: Nginx configuration for proxying and static file serving
- **`gunicorn_config.py`**: Gunicorn server settings (workers, timeouts, etc.)

## ⚙️ Configuration

### Environment Variables

The application respects the following environment variables:

- **`FLASK_ENV`**: Set to `development` to enable debug mode (default: `production`)
  ```bash
  # In docker-compose.yml
  environment:
    - FLASK_ENV=production
  ```

### Gunicorn Configuration

Edit `gunicorn_config.py` to adjust:
- Number of workers
- Worker class
- Timeouts
- Log levels

### Nginx Configuration

Edit `nginx.conf` to adjust:
- Server port
- Proxy timeouts
- Static file caching
- Security headers

## 🔌 API Endpoints

### GET `/`
Serves the calculator web interface.

**Response**: HTML page with calculator UI

### POST `/calculate`
Calculates a mathematical expression.

**Request Body**:
```json
{
  "expression": "2+2*3"
}
```

**Success Response** (200):
```json
{
  "result": 8
}
```

**Error Response** (400):
```json
{
  "error": "Invalid characters in expression"
}
```

**Supported Operations**:
- Addition (`+`)
- Subtraction (`-`)
- Multiplication (`*`)
- Division (`/`)
- Parentheses (`()`)
- Decimal numbers

### GET `/health`
Health check endpoint for monitoring.

**Response**:
```json
{
  "status": "healthy"
}
```

## 🔍 Troubleshooting

### Calculator Not Loading

**Problem**: Page loads but calculator doesn't appear or styles are missing.

**Solutions**:
1. Check if containers are running:
   ```bash
   docker compose ps
   ```

2. Rebuild containers:
   ```bash
   docker compose down
   docker compose up --build -d
   ```

3. Check browser console for errors (F12 → Console tab)

4. Hard refresh browser: `Ctrl+Shift+R` (Windows/Linux) or `Cmd+Shift+R` (Mac)

### Static Files Not Loading

**Problem**: CSS and JavaScript files return 404 errors.

**Solutions**:
1. Verify static files exist in container:
   ```bash
   docker compose exec app ls -la /app/static/css/
   docker compose exec app ls -la /app/static/js/
   ```

2. Check nginx logs:
   ```bash
   docker compose logs nginx
   ```

3. Test static file access:
   ```bash
   curl http://localhost/static/css/styles.css
   ```

### Docker Issues

**Problem**: Docker commands fail.

**Solutions**:
1. Verify Docker is running:
   ```bash
   docker info
   ```

2. Check Docker Compose syntax:
   ```bash
   docker compose config
   ```

3. Check container logs:
   ```bash
   docker compose logs app
   docker compose logs nginx
   ```

### Port Already in Use

**Problem**: Error about port 80 being in use.

**Solutions**:
1. Find process using port 80:
   ```bash
   # Mac/Linux
   sudo lsof -i :80
   
   # Stop the service or change port in docker-compose.yml
   ```

2. Change port in `docker-compose.yml`:
   ```yaml
   ports:
     - "8080:80"  # Use port 8080 instead
   ```

### Calculation Errors

**Problem**: Calculator returns errors for valid expressions.

**Solutions**:
1. Check Flask logs:
   ```bash
   docker compose logs app | grep -i error
   ```

2. Verify expression format:
   - Use `*` for multiplication, not `×`
   - Use `-` for subtraction, not `−`
   - JavaScript converts UI symbols automatically

## 💻 Development

### Running in Development Mode

1. Edit `docker-compose.yml`:
   ```yaml
   environment:
     - FLASK_ENV=development
   ```

2. Rebuild and restart:
   ```bash
   docker compose up --build -d
   ```

### Local Development (Without Docker)

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Run Flask directly:
   ```bash
   export FLASK_ENV=development
   python app.py
   ```

3. Access at `http://localhost:8000`

### Making Changes

1. Edit source files (`app.py`, templates, CSS, JS)
2. Rebuild container:
   ```bash
   docker compose build app
   docker compose up -d app
   ```

### Viewing Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f app
docker compose logs -f nginx

# Last 50 lines
docker compose logs --tail=50
```

### Testing the API

```bash
# Test calculation endpoint
curl -X POST http://localhost/calculate \
  -H "Content-Type: application/json" \
  -d '{"expression": "2+2"}'

# Test health endpoint
curl http://localhost/health
```

## 🛡️ Security Considerations

- **Input Validation**: All expressions are validated before evaluation
- **Character Whitelist**: Only numeric and operator characters allowed
- **Error Handling**: Division by zero and invalid syntax are caught
- **Non-root User**: Application runs as non-root user in container
- **Security Headers**: Nginx adds X-Frame-Options, X-Content-Type-Options, etc.

## 📝 License

This project is provided as-is for educational and demonstration purposes.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

For issues or questions:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review container logs
3. Verify all prerequisites are installed

---

**Happy Calculating! 🧮**

