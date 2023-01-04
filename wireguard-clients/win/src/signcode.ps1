<#
.Synopsis
Sign code with a code signing certificate (pfx)
The certificate password can be pre-stored in a local file. This file is only decryptable by the current user on the current machine.
The certificate defaults to the path to the current Ericom code signing certificate
.EXAMPLE
signcode.ps1 -saveCredentials
signcode.ps1 -usedSavedCredentials myfile.exe
#>


param (
  # path to the certificate file
  $pfx,
  $credDir = $env:USERPROFILE,
  [switch]
  $saveCredentials,
  [switch]
  $useSavedCredentials,

  [parameter(Mandatory=$false, Position=0)]
  [String]
  $filePath
)

$ErrorActionPreference = "Stop"

if ([Environment]::GetEnvironmentVariable("ERICOM_SUPPRESS_CODE_SIGNING", [EnvironmentVariableTarget]::Machine) -eq "1") {
    write-output "Skip signing $filePath"
    exit 0
}


if (!$pfx) {
  # seems not to work in param when invoked from a cmd prompt
  $pfx = join-path $PSScriptRoot "certificates\ericomsoftware-codesign-2024-04-27.pfx"
}


if (!(Test-Path -Path $pfx)) {
    throw "Certificate file not found: $pfx"
}


if (!$saveCredentials) {
  if (!$filePath) {
      throw "-filePath <pathToFileToSign> must be specified"
  } 
  if (!(Test-Path -Path $filePath)) {
      throw "File to sign not found: $filePath"
   }
}

$baseName = (Get-Item $pfx).Basename
$storedCred = (join-path $credDir $baseName) + ".xml"

if ($useSavedCredentials -and !(Test-Path -Path $storedCred)) {
    throw "Stored credential file not found: $storedCred"
}


$pfx = (resolve-path $pfx).Path

if ($useSavedCredentials) {
    $cred = Import-CliXml -Path $storedCred
    # write-host $cred.GetNetworkCredential().Password
    # exit
} else {
  $cred = Get-Credential  -Message "Enter password for $baseName" -user $baseName
}

# in PS 5.1, the Get-PfxCertificate cmdlet does not accept a password - so, we just do it another way

$cert = New-Object "System.Security.Cryptography.X509Certificates.X509Certificate2" $pfx,$cred.Password,EphemeralKeySet

if ($saveCredentials) {
    $cred | Export-CliXml -Path $storedCred
    exit
}


Set-AuthenticodeSignature -certificate $cert -HashAlgorithm SHA256 -timestampServer http://timestamp.digicert.com  -filePath $filePath
