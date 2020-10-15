job "java_files" {
  datacenters = ["dc1"],
  group "java_files" {
    task "graalvm_run_camel" {
      driver = "java"
      config {
        jar_path = "local/camel-standalone-helloworld-1.0-SNAPSHOT.jar"
        jvm_options = ["-Xmx1024m", "-Xms256m"]
      }
      # Location of artifact
      artifact {
        # source = "http://localhost/camel-standalone-helloworld-1.0-SNAPSHOT.jar"
        source = "http://server-a-2:8888/camel-standalone-helloworld-1.0-SNAPSHOT.jar"
      }
    }
  }
}