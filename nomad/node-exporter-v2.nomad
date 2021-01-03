job "node_exporter" {
  datacenters = ["dc1"]

  group "node_exporter" {
    count = 1

    task "node_exporter" {
      driver = "docker"

      config {
        image = "bitnami/node-exporter"
        port_map {
          node_exporter_endpoint = 9100
        }
      }

      resources {
        network {
          mbits = 10
          port  "node_exporter_endpoint"{}
        }
      }

      service {
        name = "node-exporter"
        tags = ["urlprefix-/"]
        port = "node_exporter_endpoint"

        check {
          name     = "node_exporter_endpoint port alive"
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}