# Docker Image Transfer Tool

## Overview

Transfer Docker images between machines over your local network without using internet bandwidth. This tool is especially useful when working in limited or metered connectivity environments.

## Features

- Export all Docker images (tagged and untagged) into a single `.tar` file
- Serve files over a local HTTP server
- Offline image transfer between machines
- Bandwidth conservation for development teams

## Prerequisites

| Requirement | Source PC | Target PC |
|-------------|-----------|-----------|
| Docker installed | Required | Required |
| Python 3 installed | Required | Optional |
| Network connectivity | Same LAN/Wi-Fi | Same LAN/Wi-Fi |

## Quick Start

1. Clone this repository:
```bash
git clone https://github.com/kazlaw/Move-docker-images-on-LAN.git
cd Move-docker-images-on-LAN
```

2. Make the script executable:
```bash
chmod +x export-docker-images.sh
```

3. Run on source machine:
```bash
./export-docker-images.sh
```

4. Download and load on target machine:
```bash
wget http://SOURCE_IP:8000/all-docker-images.tar
docker load -i all-docker-images.tar
```

## Installation

### Method 1: Clone Repository
```bash
git clone https://github.com/kazlaw/Move-docker-images-on-LAN.git
cd Move-docker-images-on-LAN
chmod +x export-all-docker-images.sh
```

### Method 2: Download Script Only
```bash
curl -O https://raw.githubusercontent.com/yourusername/docker-image-transfer/main/export-all-docker-images.sh
chmod +x export-all-docker-images.sh
```

## Usage

### Basic Usage

**Step 1: Export Images (Source Machine)**
```bash
./export-all-docker-images.sh
```

The script will:
- Discover all Docker images on your system
- Export them to `all-docker-images.tar`
- Start an HTTP server on port 8000
- Display the download URL

**Step 2: Import Images (Target Machine)**
```bash
# Replace 192.168.1.100 with your source machine's IP
wget http://192.168.1.100:8000/all-docker-images.tar
docker load -i all-docker-images.tar
```

### Advanced Usage

**Custom Port**
```bash
# Modify the PORT variable in the script or use Python directly
python3 -m http.server 9000
```

**Selective Image Export**
```bash
# Export specific images
docker save nginx:latest mysql:8.0 -o specific-images.tar

# Export images matching pattern
docker save $(docker images "myapp*" --format "{{.Repository}}:{{.Tag}}") -o myapp-images.tar
```

**Compression for Large Files**
```bash
# Compress the archive
gzip all-docker-images.tar

# On target machine
gunzip all-docker-images.tar.gz
docker load -i all-docker-images.tar
```

## Script Details

### export-docker-images.sh

```bash
#!/bin/bash
set -e

# Configuration
OUTFILE="all-docker-images.tar"
PORT=8000

echo "[INFO] Starting Docker image export process..."
echo "[INFO] Output file: $OUTFILE"

# Get all tagged images
echo "[INFO] Discovering tagged Docker images..."
IMAGE_IDS=$(docker images -a --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>" || true)

# Get untagged/dangling images
echo "[INFO] Discovering untagged Docker images..."
UNTAGGED=$(docker images -a --filter "dangling=true" -q || true)

# Count total images
TAGGED_COUNT=$(echo "$IMAGE_IDS" | wc -l)
UNTAGGED_COUNT=$(echo "$UNTAGGED" | wc -w)
TOTAL_COUNT=$((TAGGED_COUNT + UNTAGGED_COUNT))

echo "[INFO] Found $TAGGED_COUNT tagged images and $UNTAGGED_COUNT untagged images"
echo "[INFO] Total images to export: $TOTAL_COUNT"

# Export tagged images
if [ -n "$IMAGE_IDS" ] && [ "$IMAGE_IDS" != "" ]; then
    echo "[INFO] Exporting tagged images..."
    docker save $IMAGE_IDS -o "$OUTFILE"
    echo "[SUCCESS] Tagged images exported successfully"
else
    echo "[WARNING] No tagged images found"
fi

# Export untagged images and append to the same file
if [ -n "$UNTAGGED" ]; then
    echo "[INFO] Exporting untagged images..."
    if [ -f "$OUTFILE" ]; then
        # Append to existing file
        docker save $UNTAGGED | cat >> "$OUTFILE"
    else
        # Create new file
        docker save $UNTAGGED -o "$OUTFILE"
    fi
    echo "[SUCCESS] Untagged images exported successfully"
else
    echo "[INFO] No untagged images found"
fi

# Get file size and IP
if [ -f "$OUTFILE" ]; then
    FILE_SIZE=$(du -h "$OUTFILE" | cut -f1)
    echo "[INFO] Export file size: $FILE_SIZE"
else
    echo "[ERROR] Export file not created"
    exit 1
fi

LOCAL_IP=$(hostname -I | awk '{print $1}')
echo "[INFO] Local IP address: $LOCAL_IP"
echo "[INFO] Download URL: http://$LOCAL_IP:$PORT/$OUTFILE"

echo "[INFO] Starting HTTP server on port $PORT..."
echo "[INFO] On the target machine, run:"
echo "       wget http://$LOCAL_IP:$PORT/$OUTFILE"
echo "       docker load -i $OUTFILE"
echo ""
echo "[INFO] Press Ctrl+C to stop the server when transfer is complete"

# Start HTTP server
python3 -m http.server $PORT
```

## Use Cases

| Scenario | Description |
|----------|-------------|
| **Corporate Networks** | Share development environments without external registry access |
| **Limited Connectivity** | Transfer images when internet is expensive or unavailable |
| **CI/CD Optimization** | Speed up builds by avoiding repeated downloads |
| **Developer Onboarding** | Quick setup of development environments |
| **Testing Environments** | Replicate exact image sets across test machines |

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Permission denied | Run `chmod +x export-all-docker-images.sh` |
| Connection refused | Check network connectivity and firewall settings |
| No space left on device | Free up disk space or use compression |
| Python not found | Install Python 3: `sudo apt install python3` |
| Port already in use | Change PORT variable in script |

### Network Troubleshooting

```bash
# Check your IP address
hostname -I

# Test connectivity from target machine
ping SOURCE_IP
curl -I http://SOURCE_IP:8000
```

### Monitoring Progress

```bash
# Watch file creation
watch -n 2 'ls -lh all-docker-images.tar'

# Download with progress bar
wget --progress=bar http://SOURCE_IP:8000/all-docker-images.tar
```

## Performance Optimization

### Transfer Speed
- Use wired Ethernet connection when possible
- Compress large files with `gzip`
- Close unnecessary network applications
- Use SSD storage for better I/O performance

### File Size Reduction
```bash
# Remove unused images before export
docker image prune -a

# Export only necessary images
docker save $(docker images --format "{{.Repository}}:{{.Tag}}" | grep -E "nginx|mysql") -o selective-images.tar
```

## Security Considerations

- **Local network only**: Use only on trusted networks
- **No authentication**: HTTP server has no built-in security
- **Temporary usage**: Stop server after transfer completion
- **Cleanup**: Remove tar files after successful transfer

## Configuration

### Environment Variables

```bash
# Set custom output filename
export DOCKER_EXPORT_FILE="my-images.tar"

# Set custom port
export HTTP_SERVER_PORT=9000
```

### Script Customization

Edit the script variables at the top:
```bash
OUTFILE="all-docker-images.tar"  # Output filename
PORT=8000                        # HTTP server port
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit your changes: `git commit -am 'Add feature'`
4. Push to the branch: `git push origin feature-name`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- Create an issue for bug reports
- Check existing issues before submitting new ones
- Provide system information when reporting problems

## Changelog

### v1.0.0
- Initial release
- Basic image export and HTTP serving functionality
- Support for tagged and untagged images

### v1.1.0
- Added progress indicators
- Improved error handling
- Added file size reporting
- Better network IP detection

## Related Tools

- [Docker Registry](https://docs.docker.com/registry/) - Official Docker registry
- [Harbor](https://goharbor.io/) - Cloud native registry
- [docker-save-load](https://github.com/moby/moby) - Official Docker save/load commands
