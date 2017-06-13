
<#

05312017
CDAP Install Script
Preparted for Azure Workshop

#Copy-n-past the two lines below into a PowerShell window then switch to the cloned directory and run ./setup.ps1

git clone https://github.com/EscVector/AzureWorkshop.git

Set-ExecutionPolicy Unrestricted 

 .\AzureWorkshop\setup.ps1

http://localhost:11011

https://github.com/hydrator/azure-face-transform/blob/release/1.0/src/main/java/co/cask/hydrator/plugin/AzureFaceExtractor.java

#>

try {

$RootDir = "c:\cdap\workshop\"
$DownloadDir = $rootDir + "downloads"

$cdapDir = $rootDir + "sdk"
$NodeDir = $rootDir + "node"
$JavaDir = $rootDir + "java"

$cdapFileName = "cdap-sdk-4.1.1.zip"
$NodeFileName = "node-v6.10.3-win-x64.zip"
$JavaFileName = "jdk-8u131-windows-x64.exe"

#Pull from Azure Fileshare
$cdapZipSource = "https://caskworkshop.file.core.windows.net/workshop/downloads/cdap-sdk-4.1.1.zip?sv=2015-12-11&si=workshop-15C63EFC81F&sr=f&sig=2kXJKvv7EdBwmCBrT1cG0ZTNtvRVb7ls4s3DpixgUGk%3D"
$JavaExeSource = "https://caskworkshop.file.core.windows.net/workshop/downloads/jdk-8u131-windows-x64.exe?sv=2015-12-11&si=workshop-15C63EFC81F&sr=f&sig=%2FjhvuOXjUQsrL9n5rwc40YN3zPcdAj23yIMSYvnoDrg%3D"
$NodeZipSource = "https://caskworkshop.file.core.windows.net/workshop/downloads/node-v6.10.3-win-x64.zip?sv=2015-12-11&si=workshop-15C63EFC81F&sr=f&sig=RyhUhQOkcR072EF5i7jsEyBe7dIzfWV2KCQvK7k9s6I%3D"


$cdap_home = $cdapDir + "\cdap-sdk-4.1.1"
write-output "CDAP_HOME = " $cdap_home

########################################################
# Make Directories

Function MakeDir ($path) {
   If(!(test-path $path)) {
      New-Item -ItemType Directory -Force -Path $Path
   }

}

MakeDir $RootDir
MakeDir $DownloadDir
MakeDir $cdapDir
MakeDir $NodeDir
MakeDir $JavaDir

########################################################

# Destinations are prefixed with $DownloadDir

#CDAP 
#$cdapZipSource = "http://repository.cask.co/downloads/co/cask/cdap/cdap-sdk/4.1.1/cdap-sdk-4.1.1.zip"
$cdapZipDest = $downloadDir+ "\" + $cdapFileName

#Node
#$NodeZipSource = "https://nodejs.org/dist/v6.10.3/node-v6.10.3-win-x64.zip"
$NodeZipDest = $DownloadDir + "\" + $NodeFileName

#Java JDK
#$JavaExeSource = "http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-windows-x64.exe"
$JavaExeDest = $DownloadDir + "\" + $JavaFileName

########################################################

$cdapZipFileHash = "D1CC052AA0BF924B5F0934C0D6C14A1B25C969C570ED3117E202C7B1EDDC04A7"
$NodeZipFileHash = "DF61044AAF011820800061F23AB47F58CE33855529A1825CD9D6CA7BE2550021"
$JavaExeFileHash = "8226FF89769EC3BD212305DBC83A678AD42560E65A430819917BB7965A2B89BB"

########################################################
## all files are downloaded into the download directory
########################################################
write-output "Downloading from Azure Fileshare"

$client = new-object System.Net.WebClient

write-output "Downloading Node to $NodeZipDest"
write-output "Source: $NodeZipSource"
write-output ""
$client.DownloadFile($NodeZipSource,$NodeZipDest)
#Invoke-WebRequest -Uri $NodeZipSource -ContentType "application/octet-stream" -OutFile $NodeZipDest

write-output "Downloading Java to $JavaExeDest"
write-output "Source: $JavaExeSource"
write-output ""
$client.DownloadFile($JavaExeSource,$JavaExeDest)
#Invoke-WebRequest -Uri $JavaExeSource -ContentType "application/octet-stream" -OutFile $JavaExeDest

write-output "Downloading CDAP to $cdapZipDest"
write-output "Source: $cdapZipSource"
write-output ""
$client.DownloadFile($cdapZipSource,$cdapZipDest)
#Invoke-WebRequest -Uri $cdapZipSource -ContentType "application/octet-stream" -OutFile $cdapZipDest

########################

# Download Java JDK - using WebClient to get around header cookie issue in Invoke-WebRequest
# No download output - must check hash
#$client = new-object System.Net.WebClient 
#$cookie = "oraclelicense=accept-securebackup-cookie"
#$client.Headers.Add([System.Net.HttpRequestHeader]::Cookie, $cookie) 
#$client.downloadFile($JavaExeSource, $JavaExeDest)

########################################################

Function HashCheck ($file, $hash) {
   $test = @{}
   $TestHash = Get-FileHash $file
   if ($TestHash.Hash -ne $hash) {
     $test.success = $false
     $test.message = "$TestHash.Path hash test failed, please download again"
   }
   
   return $test
}

Write-Output "Checking Hash for $cdapZipDest
HashCheck $cdapZipDest $cdapZipFileHash
Write_output "Checking Hash for $NodeZipDest
HashCheck $NodeZipDest $nodeZipFileHash
Write-Output "Checking Hash for $JavaExeDest"
HashCheck $JavaExeDest $JavaExeFilehash
########################################################

function ExtractFiles($file, $destination)
{
   $shell = new-object -com shell.application
   $zip = $shell.NameSpace($file)
   foreach($item in $zip.items())
      {
         $shell.Namespace($destination).copyhere($item)
      }
}

# Install JDK
Write-Output "Installing Java"
$InstallJDK = $JavaExeDest +  " INSTALL_SILENT=Enable INSTALLDIR=" + $JavaDir
invoke-expression $InstallJDK

# Extract Node
Write-Output "Installing NOde"
ExtractFiles $NodeZipDest $NodeDir

# Extract CDAP
Write-Output "Installing CDAP"
ExtractFiles $cdapZipDest $cdapDir




########################################################
# NOTE - variables may not work as user variables

Write-Output "Setting Variables"

$OldPath = Get-ChildItem Env:Path
$JavaHome = $JavaDir
[Environment]::SetEnvironmentVariable("JAVA_HOME", $JavaHome, "Machine")
[Environment]::SetEnvironmentVariable("CDAP_HOME", $cdapDir, "Machine")

#  [environment]::GetEnvironmentVariable("Path","Machine")
$NewPath = $cdap_home+ "\" + "bin;" + $NodeDir + "\bin;" +  $JavaHome + "\bin;" + $OldPath.Value
#[Environment]::SetEnvironmentVariable("Path", $NewPath, "Machine")

[Environment]::SetEnvironmentVariable("Path", $NewPath, "Machine")


$env:Path = $NewPath;


write-output  Get-ChildItem Env:Path
write-output ""
write-output "CDAP_HOME = $cdap_home"

########################################################

write-output "Starting CDAP"
invoke-expression "cdap sdk start"

}

catch {
   write-host  $_.Exception.Message -foreground red
   write-host  "Exiting."
}
finally{
   write-host "Well that's that, then."
}
