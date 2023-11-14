$dirName = "c:\temp"
$fileName = "PowerDBA.ps1"
$content = 
"
Write-Host 'Welcome to PowerShell for busy DBA workshop' -BackgroundColor DarkYellow -ForegroundColor Black
Write-Host 'Mikey Bronowski @ PASS Summit 2023 Seattle' -Background Red -Foreground White
Write-Host (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -BackgroundColor White -ForegroundColor DarkBlue
"

New-Item -Path $dirName -ItemType Directory -Force
New-Item -Path $dirName\$fileName  -ItemType File -Force
Set-Location -Path $dirName
Set-Content $dirName\$fileName $content
Invoke-Item $dirName\$fileName

# no restrictions for running scripts
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force


# attempt to run unsigned script
.\PowerDBA.ps1

# change policy to allow only signed scripts
Set-ExecutionPolicy -ExecutionPolicy AllSigned -Force -Scope CurrentUser

# another attempt to run unsigned script
.\PowerDBA.ps1

# sign the script


# self-signed certificate
$cert = New-SelfSignedCertificate -DnsName "localhost" -CertStoreLocation "cert:\LocalMachine\My" -KeyUsage DigitalSignature -Type CodeSigningCert

# Add the certificate to the Trusted Root Certification Authorities store
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store "Root", "LocalMachine"
$store.Open("ReadWrite")
$store.Add($cert)
$store.Close()


# get certificate to sign scripts
$codeCertificate = Get-ChildItem Cert:\LocalMachine\My -CodeSigningCert

# sign the script
Set-AuthenticodeSignature -FilePath $dirName\$fileName -Certificate $codeCertificate
Invoke-Item $dirName\$fileName


# execution script signed with certificate
.\PowerDBA.ps1










# clean up
Get-Item $dirName | Remove-Item -Recurse -Force -Confirm:$false
