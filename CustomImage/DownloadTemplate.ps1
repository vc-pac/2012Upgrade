# Resource group name - we're using myImageBuilderRG in this example
$imageResourceGroup = 'ess-spt-dev-rg'
# Region location 
$location = 'East US 2'

#Run output name
$runOutputName = 'Windows2022'
# The name of the image to be created
$imageName = 'Win22Image'
#subscription ID
$SubscriptionID = (Get-AzContext).Subscription.Id
#Image Template Name
$ImageTemplateName = 'Win22ImageTemplate'
$templateFilePath ='.\CustomImage\Template\Win22ImageTemplate.json'

# user-assigned managed identity
$identityName = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup).Name

$identityNameResourceId = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).Id

# Update the Template 
((Get-Content -path $templateFilePath -Raw) -replace '<subscriptionID>',$subscriptionID) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<rgName>',$imageResourceGroup) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<region>',$location) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<runOutputName>',$runOutputName) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<imageName>',$imageName) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<imgBuilderId>',$identityNameResourceId) | Set-Content -Path $templateFilePath


# The following commands require the Az.ImageBuilder module
# Install the PowerShell module if not already installed
Install-Module -name 'Az.ImageBuilder'


# Run the deployment
New-AzResourceGroupDeployment -ResourceGroupName $imageResourceGroup -TemplateFile $templateFilePath `
-api-version "2020-02-14" -imageTemplateName $imageTemplateName -svclocation $location

# Verify the template
Get-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup |
Select-Object -Property Name, LastRunStatusRunState, LastRunStatusMessage, ProvisioningState, ProvisioningErrorMessage

# Start the Image Build Process
Start-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName

# Remove the template deployment
remove-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup


