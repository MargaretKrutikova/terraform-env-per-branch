# Setup Azure Storage for terraform remote states

```
terraform init
terraform plan -out storage.tfplan
terraform apply storage.tfplan
```

# Create azure env variables from output

Pipelines -> Library -> Create variable group `TerraformBackendVars`
