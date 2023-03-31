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
```yaml
pipelines:
  branches:
    prod/*:
      - step:
          name: Security Scan
          script:
            # Run a security scan for sensitive data.
            # See more security tools at https://bitbucket.org/product/features/pipelines/integrations?&category=security
            - pipe: atlassian/git-secrets-scan:0.5.1
      - step:
          name: Terraform init
          script:
            - ./terraform init
      - step:
          name: Terraform validate
          script:
            - ./terraform workspace select prod || terraform workspace new prod
            - ./terraform validate
      - step:
          name: Terraform format
          script:
            - ./terraform fmt -check -recursive
      - step:
          name: Terraform plan
          oidc: true
          script:
            - ./terraform workspace select prod || terraform workspace new prod
            - ./terraform plan -out plan.tfplan
      - step:
          # https://github.com/antonbabenko/terraform-cost-estimation
          name: Terraform Cost Estimation
          oidc: true
          script:
            - ./terraform workspace select prod || ./terraform workspace new prod
            - ./terraform plan -out=plan.tfplan > /dev/null && ./terraform show -json plan.tfplan | curl -s -X POST -H "Content-Type:\ application/json" -d @- https://cost.modules.tf/
      - step:
          name: Deploy to Production
          trigger: manual
          deployment: Production
          oidc: true
          script:
            - ./terraform workspace select prod || terraform workspace new prod
            - ./terraform plan -out plan.tfplan
            - ./terraform apply -input=false -auto-approve plan.tfplan
```
Because I am dealing with multiple Terraform State files, I have work like this:
```yaml
pipelines:
  branches:
    prod/*:
      - step:
    prod-network/*:
      - step:
            script:
              - cd modules/network
              - terraform init
              - terraform plan
              - terraform apply
    prod-route53/*:
      - step:
            script:
              - cd modules/route53
              - terraform init
              - terraform plan
              - terraform apply
``` 
