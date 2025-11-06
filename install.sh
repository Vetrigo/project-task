#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"
PORT_FILE="$SCRIPT_DIR/.port"

# Load saved port or use default
if [ -f "$SCRIPT_DIR/.port" ]; then
    PORT=$(cat "$SCRIPT_DIR/.port")
else
    PORT=80
fi

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if port is available
check_port_available() {
    local port=$1
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
            return 1
        fi
    else
        # Linux
        if netstat -tuln 2>/dev/null | grep -q ":$port " || ss -tuln 2>/dev/null | grep -q ":$port "; then
            return 1
        fi
    fi
    return 0
}

# Function to prompt for port number
prompt_for_port() {
    echo ""
    print_info "Port Configuration"
    echo ""
    echo "Please specify the port number for the web server."
    echo "Default port: 80 (requires root/admin privileges)"
    echo "Recommended for non-root users: 8080, 3000, or 8000"
    echo ""
    
    # Load saved port if exists
    if [ -f "$PORT_FILE" ]; then
        local saved_port=$(cat "$PORT_FILE")
        echo "Previously used port: $saved_port"
    fi
    echo ""
    
    while true; do
        read -p "Enter port number [default: 80]: " input_port
        # Use default if empty
        if [ -z "$input_port" ]; then
            PORT=80
            break
        fi
        
        # Validate port is a number
        if ! [[ "$input_port" =~ ^[0-9]+$ ]]; then
            print_error "Port must be a number. Please try again."
            continue
        fi
        
        # Validate port range
        if [ "$input_port" -lt 1 ] || [ "$input_port" -gt 65535 ]; then
            print_error "Port must be between 1 and 65535. Please try again."
            continue
        fi
        
        # Check if port is available
        if ! check_port_available "$input_port"; then
            print_warning "Port $input_port is already in use!"
            read -p "Do you want to use this port anyway? (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                continue
            fi
        fi
        
        PORT=$input_port
        break
    done
    
    # Save port for next time
    echo "$PORT" > "$PORT_FILE"
    export PORT
    print_success "Using port: $PORT"
    echo ""
}

# Function to update docker-compose.yml with port
update_compose_port() {
    local port=$1
    local compose_file="$SCRIPT_DIR/docker-compose.yml"
    
    # Create backup if it doesn't exist
    if [ ! -f "$compose_file.bak" ]; then
        cp "$compose_file" "$compose_file.bak"
    fi
    
    # Update port in docker-compose.yml using sed
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS sed
        sed -i '' "s|- \"[0-9]*:80\"|- \"${port}:80\"|g" "$compose_file"
    else
        # Linux sed
        sed -i "s|- \"[0-9]*:80\"|- \"${port}:80\"|g" "$compose_file"
    fi
    
    print_success "Updated docker-compose.yml to use port $port"
}

# Function to restore docker-compose.yml from backup
restore_compose_file() {
    local compose_file="$SCRIPT_DIR/docker-compose.yml"
    
    if [ -f "$compose_file.bak" ]; then
        mv "$compose_file.bak" "$compose_file"
        print_info "Restored original docker-compose.yml"
    fi
}

# Function to check Docker installation
check_docker() {
    print_info "Checking Docker installation..."
    
    if ! command_exists docker; then
        print_error "Docker is not installed!"
        echo ""
        echo "Please install Docker from: https://docs.docker.com/get-docker/"
        echo ""
        read -p "Would you like to open the Docker installation page? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                open "https://docs.docker.com/desktop/install/mac-install/"
            elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
                xdg-open "https://docs.docker.com/engine/install/" 2>/dev/null || echo "Please visit: https://docs.docker.com/engine/install/"
            else
                open "https://docs.docker.com/get-docker/"
            fi
        fi
        exit 1
    fi
    
    # Check if Docker daemon is running
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker daemon is not running!"
        echo ""
        echo "Please start Docker Desktop or Docker service."
        echo "On macOS: Open Docker Desktop application"
        echo "On Linux: sudo systemctl start docker"
        exit 1
    fi
    
    print_success "Docker is installed and running"
    
    # Check Docker Compose
    if command_exists docker-compose; then
        COMPOSE_CMD="docker-compose"
        print_success "Docker Compose (standalone) is available"
    elif docker compose version >/dev/null 2>&1; then
        COMPOSE_CMD="docker compose"
        print_success "Docker Compose (plugin) is available"
    else
        print_error "Docker Compose is not available!"
        exit 1
    fi
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check if required files exist
    local required_files=("Dockerfile" "docker-compose.yml" "src/app.py" "requirements.txt" "nginx.conf" "gunicorn_config.py")
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$SCRIPT_DIR/$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -ne 0 ]; then
        print_error "Missing required files:"
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        exit 1
    fi
    
    print_success "All required files are present"
}

# Function to stop existing containers
stop_containers() {
    print_info "Checking for existing containers..."
    
    cd "$SCRIPT_DIR" || exit 1
    
    if $COMPOSE_CMD ps | grep -q calculator; then
        print_warning "Existing containers found. Stopping them..."
        $COMPOSE_CMD down
        print_success "Containers stopped"
        # Restore original docker-compose.yml after stopping
        restore_compose_file
    fi
}

# Function to build Docker images
build_images() {
    print_info "Building Docker images..."
    echo ""
    
    cd "$SCRIPT_DIR" || exit 1
    
    if $COMPOSE_CMD build --no-cache; then
        print_success "Docker images built successfully"
        return 0
    else
        print_error "Failed to build Docker images"
        return 1
    fi
}

# Function to start containers
start_containers() {
    print_info "Starting containers..."
    echo ""
    
    cd "$SCRIPT_DIR" || exit 1
    
    if $COMPOSE_CMD up -d; then
        print_success "Containers started successfully"
        return 0
    else
        print_error "Failed to start containers"
        return 1
    fi
}

# Function to wait for services to be ready
wait_for_services() {
    print_info "Waiting for services to be ready..."
    
    local max_attempts=30
    local attempt=0
    local health_url="http://localhost"
    if [ "$PORT" -ne 80 ]; then
        health_url="http://localhost:$PORT"
    fi
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s -f "$health_url/health" >/dev/null 2>&1; then
            print_success "Services are ready!"
            return 0
        fi
        
        attempt=$((attempt + 1))
        echo -n "."
        sleep 2
    done
    
    echo ""
    print_warning "Services are taking longer than expected to start"
    print_info "You can check the status with: $COMPOSE_CMD ps"
    return 1
}

# Function to show container status
show_status() {
    print_info "Container status:"
    echo ""
    
    cd "$SCRIPT_DIR" || exit 1
    $COMPOSE_CMD ps
    echo ""
}

# Function to show logs
show_logs() {
    print_info "Showing recent logs..."
    echo ""
    
    cd "$SCRIPT_DIR" || exit 1
    $COMPOSE_CMD logs --tail=50
    echo ""
}

# Function to show helpful information
show_info() {
    echo ""
    echo "=========================================="
    print_success "Installation Complete!"
    echo "=========================================="
    echo ""
    echo "Your Calculator App is now running!"
    echo ""
    echo "Access the application at:"
    if [ "$PORT" -eq 80 ]; then
        printf "  ${GREEN}http://localhost${NC}\n"
    else
        printf "  ${GREEN}http://localhost:$PORT${NC}\n"
    fi
    echo ""
    echo "Useful commands:"
    printf "  ${BLUE}View logs:${NC}           $COMPOSE_CMD logs -f\n"
    printf "  ${BLUE}Stop services:${NC}       $COMPOSE_CMD down\n"
    printf "  ${BLUE}Restart services:${NC}     $COMPOSE_CMD restart\n"
    printf "  ${BLUE}View status:${NC}          $COMPOSE_CMD ps\n"
    printf "  ${BLUE}Rebuild images:${NC}       $COMPOSE_CMD build --no-cache\n"
    echo ""
    echo "To stop the services, run:"
    printf "  ${YELLOW}$COMPOSE_CMD down${NC}\n"
    echo ""
}

# Main installation function
main() {
    clear
    echo "=========================================="
    echo "  Calculator App Installation Script"
    echo "=========================================="
    echo ""
    
    # Check Docker
    check_docker
    echo ""
    
    # Check prerequisites
    check_prerequisites
    echo ""
    
    # Prompt for port number
    prompt_for_port
    
    # Update docker-compose.yml with the selected port
    update_compose_port "$PORT"
    echo ""
    
    # Stop existing containers
    stop_containers
    echo ""
    
    # Ask user what they want to do
    echo "What would you like to do?"
    echo "  1) Build and start (recommended)"
    echo "  2) Build only"
    echo "  3) Start only (skip build)"
    echo "  4) Rebuild and restart"
    echo ""
    read -p "Enter your choice [1-4]: " choice
    
    case $choice in
        1)
            print_info "Building and starting services..."
            build_images
            if [ $? -eq 0 ]; then
                start_containers
                if [ $? -eq 0 ]; then
                    wait_for_services
                    show_status
                    show_info
                fi
            fi
            ;;
        2)
            print_info "Building images only..."
            build_images
            ;;
        3)
            print_info "Starting services..."
            start_containers
            if [ $? -eq 0 ]; then
                wait_for_services
                show_status
                show_info
            fi
            ;;
        4)
            print_info "Rebuilding and restarting..."
            stop_containers
            build_images
            if [ $? -eq 0 ]; then
                start_containers
                if [ $? -eq 0 ]; then
                    wait_for_services
                    show_status
                    show_info
                fi
            fi
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
    
    # Ask if user wants to view logs
    echo ""
    read -p "Would you like to view the logs? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        show_logs
    fi
}

# Run main function
main

