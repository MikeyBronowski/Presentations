$fontName = 'CaskaydiaCove NF'
$fontFolder = "C:\Temp\Fonts"

If(!(test-path $fontFolder))
{
    Write-Host -Message "$fontFolder does not exists - creating..." -ForegroundColor Yellow
      New-Item -ItemType Directory -Force -Path $fontFolder
}

$installedFonts = @(Get-ChildItem c:\windows\fonts | Where-Object {$_.PSIsContainer -eq $false} | Select-Object -ExpandProperty basename)
if($installedFonts -notcontains $fontName)
{
    Write-Host "$fontName is not installed - installing..." -ForegroundColor Yellow
    $FontItem = Get-Item -Path $fontFolder
    $FontList = Get-ChildItem -Path "$FontItem\*" -Include ('*.fon','*.otf','*.ttc','*.ttf') -Name $fontName
    $FontList | select *
    foreach ($Font in $FontList) 
    {
        Copy-Item $Font "C:\Windows\Fonts"
        New-ItemProperty -Name $Font.BaseName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $Font.name         
    }
}
else {
    # Write-Message -Level Verbose -Message "$fontName is already installed"
    Write-Host -Message "$fontName is already installed" -ForegroundColor Yellow
    return
}





$fontName = 'CaskaydiaCove NF'
$fontFolder = "C:\Temp\Fonts"
echo "Install fonts"
$fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
foreach ($file in gci "$fontFolder\*.ttf")
{
    $fileName = $file.Name
    if (-not(Test-Path -Path "C:\Windows\fonts\$fileName" )) {
        echo $fileName
        dir $file | %{ $fonts.CopyHere($_.fullname) }
    }
}
cp "$fontFolder\*.ttf" c:\windows\fonts\