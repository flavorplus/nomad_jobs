job "traefik" {
  region      = "west"
  datacenters = ["dc1"]
  type        = "service"

  group "traefik" {
    count = 3
    task "traefik" {
      driver = "docker"
      config {
        image        = "traefik:v2.2"
        network_mode = "host"
        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
        ]
      }
      template {
        data = <<EOF
[entryPoints]
  [entryPoints.traefik]
    address = ":8081"
  [entryPoints.products]
    address = ":8083"
  [entryPoints.grafana]
    address = ":3000"
  [entryPoints.prometheus]
    address = ":9091"

[api]
  dashboard = true
  insecure  = true
  debug = true

# Enable Consul Catalog configuration backend.
# https://docs.traefik.io/providers/consul-catalog/
[providers.consulCatalog]
  prefix           = "traefik"
  exposedByDefault = true # default is true. false in demos.

  [providers.consulCatalog.endpoint]
    address = "127.0.0.1:8500"
    scheme  = "http"
EOF

        destination = "local/traefik.toml"
      }

      resources {
        cpu    = 100
        memory = 128

        network {
          mbits = 10

          port "api" {
            static = 8081
          }
          port "products" {
            static = 8083
          }
          port "grafana" {
            static = 3000
          }
          port "prometheus" {
            static = 9091
          }
        }
      }

      service {
        name = "traefik"
        check {
          name     = "alive"
          type     = "tcp"
          port     = "api"
          interval = "10s"
          timeout  = "2s"
        }
      }
      service {
        name = "traefik-products"
        port = "products"
        check {
          name     = "alive"
          type     = "tcp"
          port     = "products"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}