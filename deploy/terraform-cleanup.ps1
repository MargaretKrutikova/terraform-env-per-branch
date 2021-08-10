param (
  [string]$COMMIT_MESSAGE
)

$env:ARM_CLIENT_ID       ??= $env:servicePrincipalId
$env:ARM_CLIENT_SECRET   ??= $env:servicePrincipalKey
$env:ARM_TENANT_ID       ??= $env:tenantId
$env:ARM_SUBSCRIPTION_ID ??= $(az account show --query id -o tsv)

$result = "$COMMIT_MESSAGE" | Select-String -Pattern "^Merge pull request #\d+ from .+\/feature\/(.+)"
if ($result.matches.success) {
  $MERGED_BRANCH_NAME = $result.matches.groups[1]
  Write-Output "Merged branch name: '$MERGED_BRANCH_NAME'"

  if ($(terraform workspace list | grep -c "$MERGED_BRANCH_NAME") -ne 0) {
    Write-Output "Switch to workspace '$MERGED_BRANCH_NAME'"
    terraform workspace select "$MERGED_BRANCH_NAME"
    
    Write-Output "Destroying environment '$MERGED_BRANCH_NAME'"
    terraform destroy -auto-approve

    terraform workspace select master
    Write-Output "Deleting '$MERGED_BRANCH_NAME'"
    terraform workspace delete "$MERGED_BRANCH_NAME"
  }
}
