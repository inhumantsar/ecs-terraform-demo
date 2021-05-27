# Terraform Platform Demo

## Terraform Modules

### `vpc`

This module accepts a VPC name and creates a VPC with a set of hardcoded subnets, service endpoints, and other network-related configs.

#### Usage

    module "vpc" {
        source   = "./vpc"
        vpc_name = "my-test-cluster"
    }


### `microservice`

Handles all of the bits necessary to launch a service into ECS.

## TODO

* Scope down IAM roles to least privilege

## Credits

This was cobbled together from AWS and Terraform documentation as well as
[this example project](https://github.com/jonahjon/canary-mesh).