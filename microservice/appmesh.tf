resource "aws_appmesh_mesh" "mesh" {
  name = var.name
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  name = var.service_namespace
  vpc = var.vpc_id
}

resource "aws_service_discovery_service" "this" {
  name = var.name

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl = 300
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_appmesh_virtual_node" "blue" {
  name = "blue"
  mesh_name = aws_appmesh_mesh.mesh.id

  spec {
    backend {
      virtual_service {
        virtual_service_name = ""
      }
    }

    listener {
      port_mapping {
        port = 80
        protocol = "http"
      }
      health_check {
        protocol = "http"
        path = var.health_check_path
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout_millis = 2000
        interval_millis = 5000
      }
    }
    service_discovery {
      aws_cloud_map {
        attributes = {
          stack = "blue"
        }
        service_name = "blue"
        namespace_name = var.service_namespace
      }
    }
  }
}

resource "aws_appmesh_virtual_node" "green" {
  name = "green"
  mesh_name = aws_appmesh_mesh.mesh.id

  spec {
    backend {
      virtual_service {
        virtual_service_name = local.appmesh_virtual_service_name
      }
    }

    listener {
      port_mapping {
        port = 80
        protocol = "http"
      }
      health_check {
        protocol = "http"
        path = var.health_check_path
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout_millis = 2000
        interval_millis = 5000
      }
    }
    service_discovery {
      aws_cloud_map {
        attributes = {
          stack = "green"
        }
        service_name = "green"
        namespace_name = var.service_namespace
      }
    }
  }
}


resource "aws_appmesh_virtual_router" "this" {
  name = var.name
  mesh_name = aws_appmesh_mesh.mesh.id

  spec {
    listener {
      port_mapping {
        port = 80
        protocol = "http"
      }
    }
  }
}

resource "aws_appmesh_route" "blue" {
  name = "service-route-blue"
  mesh_name = aws_appmesh_mesh.mesh.id
  virtual_router_name = aws_appmesh_virtual_router.this.name

  spec {
    http_route {
      match {
        prefix = "/"
      }

      action {
        weighted_target {
          virtual_node = aws_appmesh_virtual_node.blue.name
          weight = 100
        }
      }
    }
  }
}

resource "aws_appmesh_route" "green" {
  name = "service-route-green"
  mesh_name = aws_appmesh_mesh.mesh.id
  virtual_router_name = aws_appmesh_virtual_router.this.name

  spec {
    http_route {
      match {
        prefix = "/"
      }

      action {
        weighted_target {
          virtual_node = aws_appmesh_virtual_node.green.name
          weight = 100
        }
      }
    }
  }
}

resource "aws_appmesh_virtual_service" "this" {
  name = local.appmesh_virtual_service_name
  mesh_name = aws_appmesh_mesh.mesh.id

  spec {
    provider {
      virtual_router {
        virtual_router_name = aws_appmesh_virtual_router.this.name
      }
    }
  }
}
