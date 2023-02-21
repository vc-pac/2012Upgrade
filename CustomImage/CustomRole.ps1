[int]$timeInt = $(Get-Date -UFormat '%s')
$imageRoleDefName = "Azure Image Builder Image Def $timeInt"
$imageResourceGroup = 'ess-spt-dev-rg'
$SubscriptionID = (Get-AzContext).Subscription.Id
$identityName = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup).Name
$identityNameResourceId = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).Id
$identityNamePrincipalId = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).PrincipalId


#$myRoleImageCreationUrl = 'https://raw.githubusercontent.com/azure/azvmimagebuilder/master/solutions/12_Creating_AIB_Security_Roles/aibRoleImageCreation.json'
$myRoleImageCreationPath = ".\CustomImage\myRoleImageCreation.json"

$Content = Get-Content -Path $myRoleImageCreationPath -Raw
$Content = $Content -replace '<subscriptionID>', $subscriptionID
$Content = $Content -replace '<rgName>', $imageResourceGroup
$Content = $Content -replace 'Azure Image Builder Service Image Creation Role', $imageRoleDefName
$Content | Out-File -FilePath $myRoleImageCreationPath -Force


# Create the Role Definition
New-AzRoleDefinition -InputFile $myRoleImageCreationPath

# Grant the Role Definition to the Image Builder Service Principle
$RoleAssignParams = @{
    ObjectId = $identityNamePrincipalId
    RoleDefinitionName = $imageRoleDefName
    Scope = "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup"
  }
New-AzRoleAssignment @RoleAssignParams

# Verify Role Assignment
Get-AzRoleAssignment -ObjectId $identityNamePrincipalId | Select-Object DisplayName,RoleDefinitionName