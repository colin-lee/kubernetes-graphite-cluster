export KUBE_NAMESPACE=kube-system && \
export DOCKER_REPOSITORY=reg.firstshare.cn/base && \
export STATSD_PROXY_REPLICAS=3 && \
export STATSD_DAEMON_REPLICAS=3 && \
export CARBON_RELAY_REPLICAS=3 && \
export GRAPHITE_NODE_REPLICAS=3 && \
export GRAPHITE_NODE_DISK_SIZE=15Gi && \
export GRAPHITE_NODE_CURATOR_RETENTION=5 && \
export GRAPHITE_MASTER_REPLICAS=1 && \
export SUDO="" && \
make deploy

