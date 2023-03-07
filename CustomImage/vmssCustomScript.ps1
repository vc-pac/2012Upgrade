$vmssname="spt-vmssagents-dev-ss"
$resoucegroup="network-dev-eus-rg"


Connect-AzAccount
Set-AzContext -Subscription ""
$SubscriptionID = (Get-AzContext).Subscription.Id

$username= ""
$password = ""
$domain= ""

#$customConfig = @{
#    "fileUris" = (,"https://raw.githubusercontent.com/vc-pac/2012Upgrade/CustomImage-lekkalasr/CustomImage/AddUpdateSysVariables.ps1");
#    "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File AddUpdateSysVariables.ps1 -UserName '$username' -Password '$password' -UserDomain '$domain'"
#  }


$protectedSettings = @{
    'username' = $username
    'password' = $password
    'domain' = $domain
} | ConvertTo-Json -Depth 4

$customConfig = @{
    'fileUris' = 'https://raw.githubusercontent.com/vc-pac/2012Upgrade/CustomImage-lekkalasr/CustomImage/AddUpdateSysVariables.ps1'
    'commandToExecute' = 'powershell -ExecutionPolicy Unrestricted -File AddUpdateSysVariables.ps1'
    'protectedSettings' = $protectedSettings
} 

  # Get information about the scale set
$vmss = Get-AzVmss `
-ResourceGroupName "network-dev-eus-rg" `
-VMScaleSetName "spt-vmssagents-dev-ss"

# Add the Custom Script Extension update environment vairables and add credentials to credential manager.
$vmss = Add-AzVmssExtension `
-VirtualMachineScaleSet $vmss `
-Name "customScript" `
-Publisher "Microsoft.Compute" `
-Type "CustomScriptExtension" `
-TypeHandlerVersion 1.9 `
-Setting $customConfig

# Update the scale set and apply the Custom Script Extension to the VM instances
Update-AzVmss `
-ResourceGroupName "network-dev-eus-rg" `
-Name "spt-vmssagents-dev-ss" `
-VirtualMachineScaleSet $vmss


#AADlogin extension for windows
$vmss1 = Get-AzVmss `
-ResourceGroupName "network-dev-eus-rg" `
-VMScaleSetName "spt-vmssagents-dev-ss"

$vmss1 =Add-AzVmssExtension -Name "AADLoginForWindows" `
 -Type "AADLoginForWindows" `
 -Publisher "Microsoft.Azure.ActiveDirectory" `

 -VirtualMachineScaleSet $vmss1

 #remove extension if not needed
 Remove-AzVmssExtension -VirtualMachineScaleSet $vmss -Name "CustomScript"

#update the azvmss after extension added.
Update-AzVmss `
-ResourceGroupName "network-dev-eus-rg" `
-Name "spt-vmssagents-dev-ss" `
-VirtualMachineScaleSet $vmss


