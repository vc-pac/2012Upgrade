# Define the paths to be added
$paths = @("C:\Program Files\MyApp\bin", "C:\Program Files\MyApp\scripts")

# Add the paths to the sp_stg13_farm user's environment variables
$envPaths = [Environment]::GetEnvironmentVariable("PATH", "User", "sp_stg13_farm")
$envPaths += ";" + ($paths -join ";")
[Environment]::SetEnvironmentVariable("PATH", $envPaths, "User", "sp_stg13_farm")

# Add the credentials to the spg_farm user's credential manager
$credentials = @(
    @{
        Target = "o365"
        UserName = "User1"
        Password = ConvertTo-SecureString "MyPassword1" -AsPlainText -Force
    },
    @{
        Target = "viacom"
        UserName = "User2"
        Password = ConvertTo-SecureString "MyPassword2" -AsPlainText -Force
    }
)

foreach ($credential in $credentials) {
    $username = $credential.UserName
    $password = $credential.Password
    $targetName = $credential.Target
    cmdkey /generic:$targetName /user:$username /pass:$password /add:target=Credentials /wincred /UserName:sp_stg13_farm
}