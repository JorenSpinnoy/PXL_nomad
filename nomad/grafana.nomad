job "grafana" {
  datacenters = ["dc1"]

  group "grafana" {
    network {
        port "gf" {
            static = 3000
        }
    }

    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana"
        ports = ["gf"]
      }
    }
  }
}