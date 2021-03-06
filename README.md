# kubernetes-graphite-cluster

A deployment-ready graphite cluster on top of Kubernetes.
Find the full details [here](https://medium.com/@erezrabih/creating-a-graphite-cluster-on-kubernetes-6b402a8a7438#.yyaz16gzq)

## Contents:
1. A **statsd proxy** deployment and service for metric collection
2. A **statsd daemon** stateful set for metric aggregation and shipping
2. **Carbon relay** deployment and service to spread metrics across several Graphite data nodes
3. **Graphite data nodes** as a stateful set with persistent volumes
4. **Graphite query node** to be used as a query gateway to the data nodes

## Requirements:
1. Kubernetes version 1.5.X (We're using StatefulSet)
2. kubectl configured to work with your Kubernetes API
3. Tested on Kubernetes 1.5.2 on top of AWS/[GKE](https://github.com/nanit/kubernetes-graphite-cluster/issues/6)
4. Optional - Access to your own docker repository to store your own images. That's relevant if you don't want to use the default images offered here.

## Environment Variables:
| Name                            | Default Value | Purpose                                                                                                                              
|---------------------------------|---------------|--------------------------------------------------------------------------------------------------------------------------------------
| DOCKER_REPOSITORY               | nanit         | Change it if you want to build and use custom docker repository. nanit images are public so leaving it as it is should work out of the box. 
| SUDO                            | sudo          | Should docker commands be prefixed with sudo. Change to "" to omit sudo.                                                             
| STATSD_PROXY_REPLICAS           | None          | Number of replicas for statsd proxy                                                                                                  
| STATSD_DAEMON_REPLICAS          | None          | Number of StatsD daemons running behind the proxies.                                                                                 
| CARBON_RELAY_REPLICAS           | None          | Number of replicas for carbon relay                                                                                                  
| GRAPHITE_NODE_REPLICAS          | None          | The number of Graphite data nodes in the cluster. This number affects both carbon relay and graphite master configuration.           
| GRAPHITE_NODE_DISK_SIZE         | None          | The size of the persistent disk to be allocated for each Graphite node. 
| GRAPHITE_NODE_CURATOR_RETENTION | None          | Set this variable to run a cronjob which deletes metrics that haven't been written for X days. Leaving it blank will not run the curator
| GRAPHITE_MASTER_REPLICAS        | None          | Number of replicas for graphite query node                                                                                           

## Deployment:
1. Clone this repository
2. Run:
```
export DOCKER_REPOSITORY=nanit && \
export STATSD_PROXY_REPLICAS=3 && \
export STATSD_DAEMON_REPLICAS=2 && \
export CARBON_RELAY_REPLICAS=3 && \
export GRAPHITE_NODE_REPLICAS=3 && \
export GRAPHITE_NODE_DISK_SIZE=30G && \
export GRAPHITE_NODE_CURATOR_RETENTION=5 && \
export GRAPHITE_MASTER_REPLICAS=1 && \
export SUDO="" && \
make deploy
```
## Usage:
After the deployment is done there are two endpoints of interest:

1. **statsd:8125** is the host for your metrics collection. It points the statsd proxies.
2. **graphite:80** is the host for you metrics queries. It points to the graphite query node which queries all data nodes in the cluster.

Run `kubectl get pods,statefulsets,svc` and expect to see the following resources:

![K8s resources on a clean cluster](https://github.com/nanit/kubernetes-graphite-cluster/blob/master/K8s-Resources.png)

The replicas of each resource may change according to your environment variables of course.


## Verifying The Deployment:
To verify everything works as expected:

1. Enter an interactive shell session in one of the pods: `kubectl exec -it statsd-daemon-0 /bin/sh`
2. run `echo "test_counter:1|c" | nc -w1 -u statsd 8125` a few times to get some data into Graphite
3. Install curl `apk --update add curl`
4. Fetch data from Graphite: `curl 'graphite/render?target=stats.counters.test_counter.count&from=-10min&format=json'`

You should see a lot of null values along with your few increments at the end.

## Building your own images
If you want to build use your own images make sure to change the DOCKER_REPOSITORY environment variable to your own docker repository.
It will build the images, push them to your docker repository and use them to create all the needed kubernetes deployments.

## Changing an active cluster configuration

Graphite nodes and StatsD daemons are deployed as StatefulSets.
When the StatsD proxies start, they fetch all host names of StatsD daemons from the kubernetes API. 
Carbon relays and Graphite master nodes do the same for Graphite data nodes. 
The implications are:

1. A change to **STATSD_DAEMON_REPLICAS** requires killing all StatsD proxy pods so they fetch the new host names.

`kubectl delete pods -l app=statsd` will kill all proxies. The deployment will make sure they come up again with the proper configuration.

2. A change to **GRAPHITE_NODE_REPLICAS** requires killing all carbon relays and Graphite master nodes as both of them dynamically fetch Graphite data nodes hostnames.

`kubectl delete pods -l app=carbon-relay`

`kubectl delete pods -l app=graphite`

Will kill all pods which needs their configuration re-fetched from kuberntes API.

All other replicas - **STATSD_PROXY_REPLICAS**, **CARBON_RELAY_REPLICAS** and **GRAPHITE_MASTER_REPLICAS** may be changed without additional action needed.

## Acknowledgement

1. I have learnt a lot about Graphite clustering from [this excellent article](https://grey-boundary.io/the-architecture-of-clustering-graphite)
2. The docker images for the graphite nodes are based on [this repository](https://github.com/nickstenning/docker-graphite)
