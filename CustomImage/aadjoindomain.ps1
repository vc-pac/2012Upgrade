
$ScaleSetObject = Get-AzVmss `
-ResourceGroupName "network-dev-eus-rg" `
-VMScaleSetName "spt-vmssagents-dev-ss"



Write-Host  "Join the VMSS instances to $DomainName ...";

$domainJoinName = "vmssjoindomain"
$DomainArmUserName=""
$DomainArmPass=""
$DomainName =""
$OUPath = ""


# JoinOptions.NETSETUP_JOIN_DOMAIN | JoinOptions.NETSETUP_ACCT_CREATE
$Settings = @{
  "Name"    = $DomainName;
  "User"    = $DomainArmUserName;
  "Restart" = "true";
  "Options" = 3;
  "OUPath"  = $OUPath;
}

$ProtectedSettings = @{
  "Password" = $DomainArmPass
}

Add-AzVmssExtension `
  -VirtualMachineScaleSet $ScaleSetObject `
  -Publisher "Microsoft.Compute" `
  -Type "JsonADDomainExtension"  `
  -TypeHandlerVersion 1.3  `
  -Name $domainJoinName `
  -Setting $Settings `
  -ProtectedSetting $ProtectedSettings `
  -AutoUpgradeMinorVersion $true

#remove extension if not needed
Remove-AzVmssExtension -VirtualMachineScaleSet $ScaleSetObject -Name "CustomScript"


#update the azvmss after extension added.
Update-AzVmss `
-ResourceGroupName "network-dev-eus-rg" `
-Name "spt-vmssagents-dev-ss" `
-VirtualMachineScaleSet $ScaleSetObject