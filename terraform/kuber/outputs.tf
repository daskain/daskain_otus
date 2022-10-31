output "cluster_external_v4_endpoint" {
  value = yandex_kubernetes_cluster.k8s-yc.master.0.external_v4_endpoint
}

output "yc-test-node-group_status" {
  value = yandex_kubernetes_node_group.k8s-yc-node.status
}
