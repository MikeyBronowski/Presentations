Set-Location $env:OneDrive\SQL\Presentation\DSCArmBicep\$dirName\
Get-Item -Path 01_dsc\dsc_config.ps1.zip, 02_arm\dscarmbicep-backup.json, 02_arm\arm2bicep.json, 02_arm\arm2bicep.bicep -ErrorAction SilentlyContinue | Remove-Item 

Get-ChildItem -Path 03_bicep\arm2bicep -ErrorAction SilentlyContinue | Remove-Item -Force
Get-Item -Path 03_bicep\arm2bicep -ErrorAction SilentlyContinue | Remove-Item

Get-ChildItem -Path 01_dsc\dscDemo -ErrorAction SilentlyContinue | Remove-Item -Force
Get-Item -Path 01_dsc\dscDemo -ErrorAction SilentlyContinue | Remove-Item

Get-ChildItem -Path C:\dscDemoDir -ErrorAction SilentlyContinue | Remove-Item -Force
Get-Item -Path C:\dscDemoDir -ErrorAction SilentlyContinue | Remove-Item