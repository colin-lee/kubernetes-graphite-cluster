#!/bin/bash
kubectl delete -n kube-system deploy/graphite deploy/carbon-relay statefulsets/graphite-node statefulsets/statsd-daemon deploy/statsd
