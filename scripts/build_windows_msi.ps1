#Requires -Version 5.1
<#
.SYNOPSIS
  Builds the Flutter Windows release and packages it as a .msi installer wizard.

.DESCRIPTION
  1. flutter build windows --release
  2. wix build with WixUI_InstallDir (folder picker wizard)
  Output: build\windows\msi\Medicail-<version>-x64.msi

.PARAMETER SkipFlutterBuild
  Skip flutter build and reuse an existing Release folder.

.PARAMETER Culture
  WiX UI culture (default: fr-FR).

.EXAMPLE
  .\scripts\build_windows_msi.ps1
#>
[CmdletBinding()]
param(
  [switch]$SkipFlutterBuild,
  [string]$Culture = "fr-FR"
)

$ErrorActionPreference = "Stop"

function Refresh-Path {
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
              [System.Environment]::GetEnvironmentVariable("Path", "User")
}

function Ensure-WixCli {
  Refresh-Path
  if (Get-Command wix -ErrorAction SilentlyContinue) {
    return
  }

  Write-Host "WiX CLI not found. Installing WiXToolset.WiXCLI via winget..."
  winget install --id WiXToolset.WiXCLI -e --accept-source-agreements --accept-package-agreements | Out-Host
  Refresh-Path

  if (-not (Get-Command wix -ErrorAction SilentlyContinue)) {
    throw "WiX CLI is still unavailable after install. Restart the terminal and retry."
  }
}

function Get-ProductVersion {
  param([string]$PubspecPath)

  $content = Get-Content -LiteralPath $PubspecPath -Raw
  if ($content -notmatch '(?m)^version:\s*([^\s+]+)') {
    throw "Unable to parse version from pubspec.yaml"
  }

  $version = $Matches[1].Trim()
  # MSI ProductVersion: major.minor.build (major/minor 0-255, build 0-65535)
  $parts = $version.Split(".")
  while ($parts.Count -lt 3) {
    $parts += "0"
  }
  return "$($parts[0]).$($parts[1]).$($parts[2])"
}

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $projectRoot

$installerDir = Join-Path $projectRoot "installer\windows"
$releaseDir = Join-Path $projectRoot "build\windows\x64\runner\Release"
$msiOutDir = Join-Path $projectRoot "build\windows\msi"
$pubspec = Join-Path $projectRoot "pubspec.yaml"
$productVersion = Get-ProductVersion -PubspecPath $pubspec
$msiName = "Medicail-$productVersion-x64.msi"
$msiPath = Join-Path $msiOutDir $msiName

Write-Host "==> Medicail MSI builder"
Write-Host "    Version : $productVersion"
Write-Host "    Culture : $Culture"

Ensure-WixCli

# Accept OSMF EULA for this machine (idempotent) and ensure UI extension is cached.
& wix eula accept wix7 | Out-Null
Push-Location $installerDir
try {
  $extList = & wix extension list 2>&1 | Out-String
  if ($extList -notmatch "WixToolset\.UI\.wixext") {
    Write-Host "==> Adding WixToolset.UI.wixext"
    & wix extension add "WixToolset.UI.wixext/7.0.0"
  }
}
finally {
  Pop-Location
}

if (-not $SkipFlutterBuild) {
  Write-Host "==> flutter build windows --release"
  & flutter build windows --release
  if ($LASTEXITCODE -ne 0) {
    throw "flutter build windows failed with exit code $LASTEXITCODE"
  }
}

if (-not (Test-Path (Join-Path $releaseDir "medicail.exe"))) {
  throw "Release build not found at $releaseDir. Run without -SkipFlutterBuild first."
}

New-Item -ItemType Directory -Force -Path $msiOutDir | Out-Null

Write-Host "==> wix build (WixUI_InstallDir wizard)"
$wixArgs = @(
  "build",
  "-arch", "x64",
  "-culture", $Culture,
  "-ext", "WixToolset.UI.wixext",
  "-d", "ProductVersion=$productVersion",
  "-bindpath", "AppPayload=$releaseDir",
  "-bindpath", "ProjectRoot=$projectRoot",
  "-out", $msiPath,
  (Join-Path $installerDir "Package.wxs"),
  (Join-Path $installerDir "Folders.wxs"),
  (Join-Path $installerDir "Components.wxs")
)

Push-Location $installerDir
try {
  & wix @wixArgs
  if ($LASTEXITCODE -ne 0) {
    throw "wix build failed with exit code $LASTEXITCODE"
  }
}
finally {
  Pop-Location
}

# Clean adjacent wixpdb unless debugging
$pdb = [System.IO.Path]::ChangeExtension($msiPath, ".wixpdb")
if (Test-Path $pdb) {
  Remove-Item -LiteralPath $pdb -Force
}

Write-Host ""
Write-Host "MSI ready: $msiPath"
Write-Host "Wizard steps: Welcome -> License -> Choose install folder -> Install"
