<#
  JeFTeX installer for Word on Windows.
  What it does (nothing else):
    1. Puts manifest.xml in C:\ProgramData\JeFTeX (copied from next to this script, or downloaded).
    2. Shares that folder (needs ONE administrator prompt) because Word only accepts a network path as trusted catalog.
    3. Adds that share as a trusted add-in catalog for the current user (registry, HKCU).
    4. Clears Word's add-in cache so the newest version is loaded.
  Run with -Uninstall to undo all of this.
  NOTE: written with an AI assistant; not tested on every Windows/Office version.
#>
param([switch]$Uninstall)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ---- settings -------------------------------------------------------------
$ManifestUrl = 'https://binnej.github.io/jeftex/manifest.xml'   # used when no manifest.xml sits next to this script
$ShareName   = 'JeFTeXAddin'
$Dir         = Join-Path $env:ProgramData 'JeFTeX'
$Unc         = "\\$env:COMPUTERNAME\$ShareName"
$CatalogRoot = 'HKCU:\Software\Microsoft\Office\16.0\WEF\TrustedCatalogs'   # 16.0 = Office 2016, 2019, 2021, 365
$WefCache    = Join-Path $env:LOCALAPPDATA 'Microsoft\Office\16.0\Wef'
# ---------------------------------------------------------------------------

function Say($m){ Write-Host $m }

function Close-WordFirst {
  while (Get-Process WINWORD -ErrorAction SilentlyContinue) {
    Say 'Word is open. Please save your work and close Word completely, then press Enter.'
    [void](Read-Host)
  }
}

function Remove-OurCatalogEntries {
  if (Test-Path $CatalogRoot) {
    foreach ($k in Get-ChildItem $CatalogRoot) {
      $u = (Get-ItemProperty -LiteralPath $k.PSPath -ErrorAction SilentlyContinue).Url
      if ($u -eq $Unc) { Remove-Item -LiteralPath $k.PSPath -Recurse -Force }
    }
  }
}

function Invoke-Elevated([string]$command) {
  # One UAC prompt; only the share is created/removed with admin rights, the registry stays in YOUR profile.
  $p = Start-Process powershell -Verb RunAs -Wait -PassThru -WindowStyle Hidden `
        -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-Command',$command
  if ($p.ExitCode -ne 0) { throw 'The administrator step failed or was cancelled.' }
}

try {
  Close-WordFirst

  if ($Uninstall) {
    Say 'Removing JeFTeX...'
    Remove-OurCatalogEntries
    if (Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue) {
      Invoke-Elevated "Remove-SmbShare -Name '$ShareName' -Force; exit 0"
    }
    if (Test-Path $Dir) { Remove-Item $Dir -Recurse -Force -ErrorAction SilentlyContinue }
    if (Test-Path $WefCache) { Remove-Item (Join-Path $WefCache '*') -Recurse -Force -ErrorAction SilentlyContinue }
    Say 'Done. JeFTeX has been removed. If it still shows in Word, restart Word.'
    return
  }

  # 1. manifest
  New-Item -ItemType Directory -Path $Dir -Force | Out-Null
  $dest  = Join-Path $Dir 'manifest.xml'
  $local = Join-Path $PSScriptRoot 'manifest.xml'
  if (Test-Path $local) { Say 'Using manifest.xml next to the installer.'; Copy-Item $local $dest -Force }
  else { Say "Downloading $ManifestUrl"; Invoke-WebRequest -Uri $ManifestUrl -OutFile $dest -UseBasicParsing }
  if (-not (Select-String -Path $dest -Pattern '<OfficeApp' -Quiet)) { throw 'manifest.xml does not look like an Office add-in manifest.' }

  # 2. share (needs admin once)
  if (-not (Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue)) {
    Say 'Creating the shared folder (Windows will ask for administrator permission once)...'
    $me = (whoami)
    Invoke-Elevated "New-SmbShare -Name '$ShareName' -Path '$Dir' -ReadAccess '$me' | Out-Null; exit 0"
  }

  # 3. trusted catalog (current user)
  Remove-OurCatalogEntries
  $id  = '{' + [guid]::NewGuid().ToString() + '}'
  $key = Join-Path $CatalogRoot $id
  New-Item -Path $key -Force | Out-Null
  New-ItemProperty -Path $key -Name 'Id'    -Value $id  -PropertyType String | Out-Null
  New-ItemProperty -Path $key -Name 'Url'   -Value $Unc -PropertyType String | Out-Null
  New-ItemProperty -Path $key -Name 'Flags' -Value 1    -PropertyType DWord  | Out-Null

  # 4. cache
  if (Test-Path $WefCache) { Remove-Item (Join-Path $WefCache '*') -Recurse -Force -ErrorAction SilentlyContinue }

  Say ''
  Say 'Done. Now open Word and go to:'
  Say '  Insert > Add-ins > My Add-ins > SHARED FOLDER > JeFTeX > Add'
  Say 'JeFTeX then appears on the Home tab. To update later, just run this installer again.'
}
catch {
  Write-Host ''
  Write-Host "Something went wrong: $($_.Exception.Message)" -ForegroundColor Red
  Write-Host 'You can still install manually, see README.md.'
}
