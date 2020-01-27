#!/bin/bash
set -e

[[ -n $TRACE ]] && set -x

WORKERS=${WORKERS:-1}

k3d create --name k3s-elk -v /dev/mapper:/dev/mapper --publish 8080:80 --publish 8443:443 --workers "$WORKERS"

echo "Waiting for Kubeconfig"
sleep 10
timeout 180s bash <<EOT
until k3d get-kubeconfig --name='k3s-elk'; do
  sleep 1
done
EOT

echo "Waiting for nodes"
timeout 180s bash <<EOT
set -o pipefail
function is_ready()
{
  KUBECONFIG="$HOME/.config/k3d/k3s-elk/kubeconfig.yaml" kubectl get nodes -o json \
    | jq '.items[].status.conditions[] | select(.type=="Ready" and .status=="True")'
}
until is_ready
do
  sleep 1
done
EOT

KUBECONFIG="$HOME/.config/k3d/k3s-elk/kubeconfig.yaml" kubectl get nodes 

echo "Waiting for Core Pods"
sleep 15
KUBECONFIG="$HOME/.config/k3d/k3s-elk/kubeconfig.yaml" kubectl rollout status -n kube-system deployment.apps/metrics-server
KUBECONFIG="$HOME/.config/k3d/k3s-elk/kubeconfig.yaml" kubectl rollout status -n kube-system deployment.apps/local-path-provisioner
KUBECONFIG="$HOME/.config/k3d/k3s-elk/kubeconfig.yaml" kubectl rollout status -n kube-system deployment.apps/coredns
sleep 15
KUBECONFIG="$HOME/.config/k3d/k3s-elk/kubeconfig.yaml" kubectl rollout status -n kube-system deployment.apps/traefik
KUBECONFIG="$HOME/.config/k3d/k3s-elk/kubeconfig.yaml" kubectl rollout status -n kube-system daemonset/svclb-traefik


sudo sysctl -w vm.max_map_count=262144

echo 'export KUBECONFIG="$(k3d get-kubeconfig --name='k3s-elk')"'
