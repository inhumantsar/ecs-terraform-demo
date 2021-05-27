# fakeproject

Demonstrate ECS Fargate with blue/green deployments and AppMesh.

## Init

These tasks should be performed by IaC in some form. We can create the repo, create the 
AWS credentials which are scoped to *this project only*. Init will have to be
performed by a superuser and the AWS credential policy will need lots of different 
permissions though.

* GitHub repo needs to be created.
* GitHub repo needs AWS credentials attached via Secret Env Vars
* S3 bucket for Terraform State needs to exist, AWS creds above needs R/W access
* AWS creds above will also need access to the codepipeline artifact bucket created by Terraform.
   * Maybe the TF State and Artifact should go into the same bucket?
* (Optional) Create a friendly CNAME for ECR.
    * eg: `ecr.internal.newton.co` → `1234567890.dkr.ecr.ca-central-1.amazonaws.com`

## Assumptions

* Two environments which map to Docker image tags: `latest`, `stable`
* Git branches `develop` and `master` map to `latest` and `stable` respectively.

## GitHub Actions

1. Run unit tests, smoke test on GHA Runner
2. Run `terraform` if there are changes in the `terraform` dir.
    * The last step in this process maps the `microservice` module outputs to env vars in `tf.env`
3. Upload latest `appspec.yml` and `task_def.json` files to S3.
   * `tf.env` vars are injected into `task_def.json` prior to upload.
4. Push Docker image to ECR.

## CodeBuild

The appspec and task_def files get updated using Jinja2 to inject
various deployment-specific values.

Note that these files also use CodePipeline placeholders:

* `<TASK_DEFINITION>` is auto-replaced by CodePipeline with the updated task definition.
* `<IMAGE>` is replaced by CodePipeline as well, though this placeholder is defined in the `code-pipeline` Terraform module: `Image1ContainerName = "IMAGE"`

## Terraform

Requires:

* VPC ID
* Public + Private subnets to use for LB and ECS respectively

There are lots of defaulted parameters which you will likely want to change though. See `microservice/variables.tf` for more info.