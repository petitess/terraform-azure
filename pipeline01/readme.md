```yaml
image: hashicorp/terraform:full
pipelines:
    default:
        - step:
            script:
                - terraform init
                - terraform validate
                - terraform plan
    branches:
        master:
            - step:
                script:
                    - terraform init
                    - terraform validate
                    - terraform plan
                    - terraform apply -input=false -auto-approve
```
The below code is the pipeline code configured in bitbucket-pipelines.yml file for deploying resources into different environments:
```yaml
image: hashicorp/terraform:full
pipelines:
  branches:
    master:
      - step:
          name: Formatting terraform
          script:
           - terraform fmt
      - step:
          name: Initiating terraform
          script:
            - terraform init
      - step:
          name: Validating terraform
          script:
            - terraform validate
      - step:
          name: Planning terraform
          script:
            - terraform plan
      - step:
          name: Deploy to dev
          deployment: datascience
          script:
            - terraform apply -var-file=”dev.tfvars” -input=false -auto-approve
      - step:
          name: Deploy to Staging
          trigger: manual
          deployment: staging
          script:
            - terraform apply -var-file=”staging.tfvars” -input=false-auto-approve
       - step:
           name: Deploy to Production\
           trigger: manual
           deployment: prod
           script:
             terraform apply -var-file=”prod.tfvars” -input=false -auto-approve
```   
