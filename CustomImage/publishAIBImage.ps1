#Reference: https://learn.microsoft.com/en-us/azure/virtual-machines/windows/image-builder-powershell
#region Connect to Azure
Connect-AzAccount
Get-AzSubscription -SubscriptionId "9b56bf17-34a1-41de-b5a2-7ce42c0b1382" | Set-AzContext
$azContext = Get-AzContext
$subscriptionID = $azContext.Subscription.Id
#endregion

$imageResourceGroup = 'ess-spt-dev-rg'
$location = 'East US 2'
$sharedGalleryName = 'spt_devops_dev_sig_new'
$imageTemplateName = 'Win22ImageTemplate-01'
$imageDefName  = 'Win22vmid'
$runOutputName = 'Windows2022-new' # This gives you the properties of the managed image on completion.

#ManagedIdentity reading already existing one
$identityName = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup).Name[0]

$identityNameResourceId = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).Id

#region Required modules
Install-Module -name 'Az.ImageBuilder'


#create Gallery
New-AzGallery -GalleryName $sharedGalleryName -ResourceGroupName $imageResourceGroup -Location $location



#Create a Gallery Definition
$GalleryParams = @{
    GalleryName = $sharedGalleryName
    ResourceGroupName = $imageResourceGroup
    Location = $location
    Name = $imageDefName
    OsState = 'generalized'
    OsType = 'Windows'
    Publisher = 'EUTDevops'
    Offer = 'Windows'
    Sku = 'win2022'
  }

New-AzGalleryImageDefinition @GalleryParams

#Create a VM Image Builder source object
$SrcObjParams = @{
    PlatformImageSource = $true
    Publisher = 'MicrosoftWindowsServer'
    Offer = 'WindowsServer'
    Sku = '2022-Datacenter'
    Version = 'latest'
  }

 $srcPlatform = New-AzImageBuilderTemplateSourceObject @SrcObjParams


#Create a VM Image Builder distributor object.
$disObjParams = @{
    SharedImageDistributor = $true
    ArtifactTag = @{
        'publisher' = 'EUT Devops'
        'source' = 'azVmImageBuilder'
        'baseosimg' = 'windows2022'
    }
    GalleryImageId = "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup/providers/Microsoft.Compute/galleries/$sharedGalleryName/images/$imageDefName"
    ReplicationRegion = $location
    RunOutputName = $runOutputName
    ExcludeFromLatest = $false
  }

 $disSharedImg = New-AzImageBuilderTemplateDistributorObject @disObjParams


  #Create a VM Image Builder customization object.
  $imgCustomParams = @{
    PowerShellCustomizer = $true
    Name                 = 'InstallDependencies'
    RunElevated          = $true
    scriptUri            = 'https://raw.githubusercontent.com/vc-pac/2012Upgrade/CustomImage-lekkalasr/CustomImage/InstallDependencies.ps1'
}

$customizer = New-AzImageBuilderTemplateCustomizerObject @imgCustomParams

#customizer2

$ImgCustomParams01 = @{
    PowerShellCustomizer = $true
    Name = 'Install AzureAD'
    RunElevated = $true
    RunAsSystem = $true
    Inline = @("Install-Module -Name 'AzureAD' -RequiredVersion '2.0.2.130' -Force -Verbose")
  }
  $Customizer01 = New-AzImageBuilderTemplateCustomizerObject @ImgCustomParams01

$ImgCustomParams02 = @{
    PowerShellCustomizer = $true
    Name = 'Install Chocolatey'
    RunElevated = $true
    Inline = @("Set-ExecutionPolicy Bypass -Scope Process -Force",
    "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072",
    "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))")
  }
  $Customizer02 = New-AzImageBuilderTemplateCustomizerObject @ImgCustomParams01

#Create a VM Image Builder (AIB) template.
$imgTemplateParams = @{
    Name                   = $imageTemplateName
    ResourceGroupName      = $imageResourceGroup
    Source                 = $srcPlatform
    Distribute             = $disSharedImg
    Customize              = $Customizer01
    Location               = $location
    UserAssignedIdentityId = $identityNameResourceId
}
New-AzImageBuilderTemplate @ImgTemplateParams -BuildTimeoutInMinute 30

#To determine whether the template creation process was successful or not check using below 
Get-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup |
  Select-Object -Property Name, LastRunStatusRunState, LastRunStatusMessage, ProvisioningState

# On failure, Before you retry submitting the template, delete it by following this example:
Remove-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup

#Start image build
$job = Start-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName -AsJob

# wait for the job status to complete
$job

#stop the build
Stop-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName