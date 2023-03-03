Param(
    [string]$UserName, 
    [string]$Password,
    [string] $UserDomain
)
{
    [Environment]::SetEnvironmentVariable("PATH", "C:\Program Files\TerraForms;C:\Program Files\Node", [System.EnvironmentVariableTarget]::Machine)
}
