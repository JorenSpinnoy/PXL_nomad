job "node_exporter" {
  datacenters = ["dc1"]

  group "node_exporter" {
    network {
        port "n_x" {
            static = 9500
        }
    }

    task "node_exporter" {
      driver = "docker"

      config {
        image = "bitnami/node-exporter"
        ports = ["n_x"]
      }
    }
  }
}