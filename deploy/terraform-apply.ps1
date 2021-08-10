param (
  [string]$BRANCH_NAME
)

$env:ARM_CLIENT_ID       ??= $env:servicePrincipalId
$env:ARM_CLIENT_SECRET   ??= $env:servicePrincipalKey
$env:ARM_TENANT_ID       ??= $env:tenantId
$env:ARM_SUBSCRIPTION_ID ??= $(az account show --query id -o tsv)

$branchName = "$BRANCH_NAME" -replace "/", "-"

Write-Output "Terraform workspace $branchName"

if ($(terraform workspace list | grep -c "$branchName") -eq 0) {
  Write-Output "Create new workspace $branchName"

  terraform workspace new "$branchName" -no-color
} else {
  Write-Output "Switch to workspace $branchName"

  terraform workspace select "$branchName" -no-color
}

terraform apply -auto-approve -input=false

# Export Terraform output as task output
$terraformOutput = terraform output -json | ConvertFrom-Json -AsHashtable

Write-Output "Setting terraform output variable"
foreach ($outputVariable in $terraformOutput.keys) {
    $value = $terraformOutput[$outputVariable].value
    Write-Output "$outputVariable = $value"

    if ($value) {
        Write-Host "##vso[task.setvariable variable=$outputVariable;isOutput=true]$value"
    }
}   
