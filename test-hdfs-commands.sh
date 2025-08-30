#!/bin/bash

# Simple HDFS Commands Test Script
# Tests basic HDFS operations: mkdir, cp, rm, ls

set -e

CONTAINER_NAME="hadoop-hdfs-test"
IMAGE_NAME="hangxie/hadoop-all-in-one"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[TEST]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Cleanup on exit
cleanup() {
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
}
trap cleanup EXIT

# Build and start container
log "Building Docker image..."
docker build -t "$IMAGE_NAME" .

log "Starting Hadoop container..."
docker run -d --name "$CONTAINER_NAME" -p 9000:9000 -p 9870:9870 -v $(pwd)/log4j.properties:/opt/hadoop-3.4.2/etc/hadoop/log4j.properties "$IMAGE_NAME"

log "Waiting for HDFS to be ready..."
ATTEMPTS=0
MAX_ATTEMPTS=30
while ! curl -s -f http://localhost:9870 > /dev/null; do
    if [ $ATTEMPTS -ge $MAX_ATTEMPTS ]; then
        error "HDFS did not become ready in time."
        exit 1
    fi
    log "HDFS not ready yet, waiting... ($((ATTEMPTS++)))"
    sleep 5
done
log "HDFS is ready."

# Test HDFS commands
log "Testing HDFS mkdir command..."
docker exec "$CONTAINER_NAME" hdfs dfs -mkdir -p /test/data/input

log "Testing HDFS ls command..."
docker exec "$CONTAINER_NAME" hdfs dfs -ls /

log "Creating test file..."
docker exec "$CONTAINER_NAME" bash -c 'echo "Test data for HDFS" > /tmp/testfile.txt'

log "Testing HDFS put/cp command..."
docker exec "$CONTAINER_NAME" hdfs dfs -put /tmp/testfile.txt /test/data/input/

log "Testing HDFS ls with specific path..."
docker exec "$CONTAINER_NAME" hdfs dfs -ls /test/data/input

log "Testing HDFS get/cp command..."
docker exec "$CONTAINER_NAME" hdfs dfs -get /test/data/input/testfile.txt /tmp/retrieved.txt

log "Verifying file content..."
CONTENT=$(docker exec "$CONTAINER_NAME" cat /tmp/retrieved.txt)
if [ "$CONTENT" = "Test data for HDFS" ]; then
    log "✓ File content verified successfully"
else
    error "File content mismatch!"
    exit 1
fi

log "Testing HDFS cp (copy within HDFS)..."
docker exec "$CONTAINER_NAME" hdfs dfs -cp /test/data/input/testfile.txt /test/data/testfile_copy.txt

log "Testing HDFS rm command..."
docker exec "$CONTAINER_NAME" hdfs dfs -rm /test/data/testfile_copy.txt

log "Testing HDFS rm -r (recursive remove)..."
docker exec "$CONTAINER_NAME" hdfs dfs -rm -r /test

log "✅ All HDFS commands tested successfully!"
