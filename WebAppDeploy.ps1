param(
    [Parameter(Mandatory)]
    [String]$TenantId,

    [Parameter(Mandatory)]
    [String]$ApplicationId,

    [Parameter(Mandatory)]
    [securestring]$Key,

    [Parameter(Mandatory)]
    [String]$WebAppName,

    [Parameter(Mandatory)]
    [String]$ResourceGroupName,

    [Parameter(Mandatory)]
    [String]$SubscriptionId,

    [Parameter(Mandatory)]
    [String]$Environment,

    [Parameter(Mandatory)]
    [String]$DeploymentPackage,

    [Parameter(Mandatory = $false)]
    [String]$UserAgent = "PSDeployAgent",

    [Parameter(Mandatory = $false)]
    [String]$MSDeployExe = "C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe"

)

$cred = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $ApplicationId, $Key

$azureEnv = Get-AzureRmEnvironment -Name $Environment
Login-AzureRmAccount -Credential $cred -ServicePrincipal -TenantId $TenantId -SubscriptionId $SubscriptionId -Environment $azureEnv #-SubscriptionName $SubscriptionName

Get-AzureRmWebAppPublishingProfile -Name $WebAppName -ResourceGroupName $ResourceGroupName -OutputFile .\pubcreds.xml

$xml = [xml](Get-Content .\pubcreds.xml)
$username = $xml.SelectNodes("//publishProfile[@publishMethod=`"MSDeploy`"]/@userName").value
$password = $xml.SelectNodes("//publishProfile[@publishMethod=`"MSDeploy`"]/@userPWD").value
$publishUrl = $xml.SelectNodes("//publishProfile[@publishMethod=`"MSDeploy`"]/@publishUrl").value
$msdeploySite = $xml.SelectNodes("//publishProfile[@publishMethod=`"MSDeploy`"]/@msdeploySite").value
$computerName = "https://$publishUrl/msdeploy.axd?site=$msdeploySite"

[Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
$archiveFile = [IO.Compression.ZipFile]::OpenRead($DeploymentPackage).Entries | Where-Object { $_.FullName -eq "archive.xml"}

if ([String]::IsNullOrEmpty($archiveFile)) {
    #No manifest
    $msdeployArguments = 
        "-source:package='$DeploymentPackage'",
        "-dest:contentPath='$msdeploysite',computerName='$computerName',UserName='$userName',password='$password',AuthType='basic'",
        "-verb:sync",
        "-enableRule:AppOffline",
        "-enableRule:DoNotDeleteRule",
        "-userAgent:$UserAgent"
} else {
    #Package has a manifest
    $msdeployArguments = 
        "-source:package='$DeploymentPackage'",
        "-dest:auto,computerName='$computerName',UserName='$userName',password='$password',AuthType='basic'",
        "-verb:sync",
        "-enableRule:AppOffline",
        "-enableRule:DoNotDeleteRule",
        "-userAgent:$UserAgent",
        "-setParam:name='IIS", "Web", "Application", "Name',value='$msdeploySite'"
}

$command = "& '$MSDeployExe' " + $msdeployArguments
 
Write-Host $command

& $MSDeployExe $msdeployArguments
