PowerShell Script for Web App Deployment
-----------------------------------------

Newer versions of Team Foundation Server (TFS) or Visual Studio Team Services (VSTS) can establish service connections to Azure Government or other sovereign clouds. With older versions, there is no built-in way to connect to Azure Government, but it is still possible to set up a Continuous Intergration (CI) and Continuous Delivery (CD) pipeline to an Azure Web App by using a PowerShell Script. 

The [`WebAppDeploy.ps`](WebAppDeploy.ps) script in this repository can be used for such a deployment. To use it, you need to set up a service principal and give that service principal rights to publish code to the Web App. 

The script can be called with:

```
$ApplicationId = "xxxxxx-xxx-xxxx-xxxx-xxxxxxxx"
$KeyString = "xxxxxxxxxx"
$TenantId = "xxxxxx-xxxx-xxxx-xxxx-xxxxxxx"
$Key = ConvertTo-SecureString -String $KeyString -AsPlainText -Force
$SubscriptionId = "xxxxxx-xxxxx-xxxxx-xxxxx-xxxxx"
$Environment = "AzureUSGovernment"
$WebAppName = "WEBAPP-NAME"
$ResourceGroupName = "RGNAME"
$DeploymentPackage = "C:\PATH\TO\MY\DEPLOY-PACKAGE.zip"

.\WebAppDeploy.ps1 -TenantId $TenantId -ApplicationId $ApplicationId -Key $Key -SubscriptionId $SubscriptionId `
-WebAppName $WebAppName -ResourceGroupName $ResourceGroupName -Environment $Environment `
-DeploymentPackage $DeploymentPackage
```