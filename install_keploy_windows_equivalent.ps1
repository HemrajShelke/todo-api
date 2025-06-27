# Windows equivalent of the official Keploy installation script
# Based on: https://keploy.io/install.sh

param(
    [string]$Version = "latest",
    [switch]$NoRoot
)

Write-Host "Installing Keploy CLI for Windows" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

if ($Version -ne "latest") {
    Write-Host "Installing Keploy version: $Version......" -ForegroundColor Yellow
}

# Create installation directory
$installDir = "$env:USERPROFILE\.keploy\bin"
$tempDir = "$env:TEMP\keploy-install"

Write-Host "Installation directory: $installDir" -ForegroundColor Blue

# Create directories
try {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    Write-Host "Directories created successfully" -ForegroundColor Green
} catch {
    Write-Host "Failed to create directories: $_" -ForegroundColor Red
    exit 1
}

# Get latest version if not specified
if ($Version -eq "latest") {
    try {
        $releases = Invoke-RestMethod -Uri "https://api.github.com/repos/keploy/keploy/releases/latest"
        $Version = $releases.tag_name
        Write-Host "Latest version: $Version" -ForegroundColor Blue
    } catch {
        Write-Host "Failed to get latest version, using v2.6.14" -ForegroundColor Yellow
        $Version = "v2.6.14"
    }
}

# Determine download URL based on version
$downloadUrl = "https://github.com/keploy/keploy/releases/download/$Version/keploy_windows_amd64.tar.gz"

Write-Host "Downloading from: $downloadUrl" -ForegroundColor Blue

try {
    # Download the file
    $tarPath = "$tempDir\keploy_windows_amd64.tar.gz"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tarPath -UseBasicParsing
    
    Write-Host "Download completed" -ForegroundColor Green
    
    # Extract the tar.gz file (Windows 10+ has tar built-in)
    Write-Host "Extracting files..." -ForegroundColor Blue
    tar -xzf $tarPath -C $tempDir
    
    # Find the executable
    $exePath = Get-ChildItem -Path $tempDir -Name "keploy.exe" -Recurse | Select-Object -First 1
    if (-not $exePath) {
        Write-Host "keploy.exe not found in the downloaded archive" -ForegroundColor Red
        Write-Host "Available files:" -ForegroundColor Yellow
        Get-ChildItem -Path $tempDir -Recurse | ForEach-Object { Write-Host "  $($_.Name)" -ForegroundColor Gray }
        exit 1
    }
    
    $sourcePath = Join-Path $tempDir $exePath
    $targetPath = Join-Path $installDir "keploy.exe"
    
    # Copy the executable
    Copy-Item -Path $sourcePath -Destination $targetPath -Force
    Write-Host "Keploy CLI installed to: $targetPath" -ForegroundColor Green
    
    # Add to PATH if not already there
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -notlike "*$installDir*") {
        $newPath = "$currentPath;$installDir"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        Write-Host "Added to PATH" -ForegroundColor Green
    } else {
        Write-Host "Already in PATH" -ForegroundColor Yellow
    }
    
    # Clean up
    Remove-Item -Path $tempDir -Recurse -Force
    
    Write-Host "" -ForegroundColor Green
    Write-Host "Keploy CLI installed successfully!" -ForegroundColor Green
    Write-Host "" -ForegroundColor White
    Write-Host "To use Keploy, please restart your terminal or run:" -ForegroundColor Yellow
    Write-Host "   refreshenv" -ForegroundColor Cyan
    Write-Host "" -ForegroundColor White
    Write-Host "You can then verify the installation by running:" -ForegroundColor Yellow
    Write-Host "   keploy version" -ForegroundColor Cyan
    Write-Host "" -ForegroundColor White
    Write-Host "To run your cloud test-suite command:" -ForegroundColor Yellow
    Write-Host "   keploy test-suite --app=9d09b06a-70f5-443d-871e-47134856f411 --base-path https://github.com/HemrajShelke/todo-api.git --cloud" -ForegroundColor Cyan
    
} catch {
    Write-Host "Installation failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host "" -ForegroundColor Green
Write-Host "Installation completed!" -ForegroundColor Green
Write-Host "Documentation: https://keploy.io/docs/running-keploy/api-testing-cicd/" -ForegroundColor Cyan 

$env:KEPLOY_API_KEY="2XvozFt51aiBHXMFHw=="
C:\Users\kishor\.keploy\bin\keploy.exe test-suite --app=9d09b06a-70f5-443d-871e-47134856f411 --base-path https://github.com/HemrajShelke/todo-api.git --cloud 
