# https://github.com/kagkarlsson/nomad-java-poc
job "java" {
  datacenters = ["dc1"]

  type = "system"

  update {
    stagger = "10s"
    max_parallel = 1
  }

  group "java-webapp" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    task "webservice" {
      driver = "java"

      config {
        jar_path    = "/tmp/webapp.jar"
        jvm_options = ["-Xmx600m", "-Xms256m"]
      }

      artifact {
        # source = "http://localhost:8081/webapp.jar"
        source = "https://github.com/phanclan/nomad_jobs/raw/master/hashicups/webapp.jar"
        destination = "/tmp"
      }
      resources {
        cpu    = 1000
        memory = 500
        network {
          mbits = 10
          port "http" {
            static = 8082
          }
        }
      }

      service {
        name = "global-webapp-check"
        tags = ["global", "webapp"]
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }

  }
}