
 Param(
   [Parameter(Mandatory=$True)]
    [string]$App_Name,
   [Parameter(Mandatory=$True)]
    [int]$WebPort,
   [Parameter(Mandatory=$True)]
    [string]$EnvName
   )

Import-Module WebAdministration
$iisAppPoolName = "$App_Name-$EnvName"
$iisAppPoolDotNetVersion = "v4.0"
$directoryPath = "C:\${App_Name}_${EnvName}"
$hostRecord = ""

mkdir $directoryPath


#navigate to the app pools root
cd IIS:\AppPools\

#check if the app pool exists
if (!(Test-Path $iisAppPoolName -pathType container))
{
    #create the app pool
    $appPool = New-Item $iisAppPoolName
    $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $iisAppPoolDotNetVersion
}

#navigate to the sites root
cd IIS:\Sites\

#check if the site exists
if (Test-Path $iisAppPoolName -pathType container)
{
    return
}
 $cert = Get-ChildItem cert:\localmachine\my

#Bindings for site
$bindings = @{protocol="https";bindingInformation="*" +":"+ $WebPort + ":" + $hostRecord}

#create the site
$iisApp = New-Item $iisAppPoolName -bindings $bindings -physicalPath "$directoryPath"
$iisApp | Set-ItemProperty -Name "applicationPool" -Value $iisAppPoolName

#Get all certs under Personnel from the machine
$cert=Get-ChildItem cert:\LocalMachine\MY

#Select thumbprint of the 2nd cert computer
$cert_thumb=$cert[2].Thumbprint

#Bind the SSl cert with above thumbprint to site 
$Get_binding = Get-WebBinding -Name $iisAppPoolName -Protocol "https"
$Get_binding.AddSslCertificate($cert_thumb,"my")

Write-Host Web Site: $iisAppPoolName is created and Cert with thumbprint $cert_thumb is binded to site 

