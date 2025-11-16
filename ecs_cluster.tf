resource "aws_service_discovery_http_namespace" "airflow_sc_namespace" {
  name = "airflow-service-connect"
}

resource "aws_ecs_cluster" "airflow_cluster" {
  name = "Airflow-${local.deployment_id}"

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  service_connect_defaults {
    namespace = aws_service_discovery_http_namespace.airflow_sc_namespace.arn
  }
}

resource "aws_ecs_cluster_capacity_providers" "airflow_fargate_capacity_provider" {
  cluster_name       = aws_ecs_cluster.airflow_cluster.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}
