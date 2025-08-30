# Hadoop All-In-One Container

This repository provides a Docker image for a single-node Hadoop cluster, including HDFS and YARN.

## Version

* **Hadoop**: 3.4.2

## Service Ports
* 8030 yarn.resourcemanager.scheduler.address
* 8031 yarn.resourcemanager.resource-tracker.address
* 8032 yarn.resourcemanager.address
* 8033 yarn.resourcemanager.admin.address
* 8040 yarn.nodemanager.localizer.address
* 8042 yarn.nodemanager.webapp.address
* 8088 yarn.resourcemanager.webapp.address
* 9000 HDFS
* 9864 dfs.datanode.http.address
* 9866 dfs.datanode.address
* 9867 dfs.datanode.ipc.address
* 9868 dfs.namenode.secondary.http-address
* 9870 dfs.namenode.http-address

Services with HTTPS are off:
* 9865 dfs.datanode.https.address
* 9869 dfs.namenode.secondary.https-address
* 9871 dfs.namenode.https.address

## Launch Container

```
docker run -d --rm --name hadoop \
    -p 8030-8088:8030-8088 \
    -p 9000:9000 \
    -p 9864-9870:9864-9870 \
    hangxie/hadoop-all-in-one
```

## Testing

This repository includes tests to ensure the Docker image works correctly with HDFS operations.

### Run Tests

You can run the tests using the `Makefile`:
```bash
# Build the image
make build

# Run HDFS command tests
make test

# Start container for manual testing
make run

# Clean up
make clean
```

### Tests Include

The test script (`test-hdfs-commands.sh`) validates the following HDFS commands:
- `mkdir`
- `ls`
- `put`
- `get`
- `cp`
- `rm`
