# Keploy CLI Installation Script for Windows
param(
    [string]$Version = "latest"
)

Write-Host "🚀 Installing Keploy CLI for Windows" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Check if running on Windows
if ($env:OS -ne "Windows_NT") {
    Write-Host "❌ This script is designed for Windows only." -ForegroundColor Red
    exit 1
}

# Create installation directory
$installDir = "$env:USERPROFILE\.keploy\bin"
$tempDir = "$env:TEMP\keploy-install"

Write-Host "📁 Installation directory: $installDir" -ForegroundColor Blue

# Create directories
try {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    Write-Host "✅ Directories created successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to create directories: $_" -ForegroundColor Red
    exit 1
}

# Determine download URL
$downloadUrl = ""
if ($Version -eq "latest") {
    $downloadUrl = "https://keploy-enterprise.s3.us-west-2.amazonaws.com/releases/latest/keploy-agent-windows_amd64.zip"
} else {
    $downloadUrl = "https://keploy-enterprise.s3.us-west-2.amazonaws.com/releases/$Version/keploy-agent-windows_amd64.zip"
}

Write-Host "📥 Downloading Keploy CLI..." -ForegroundColor Blue
Write-Host "URL: $downloadUrl" -ForegroundColor Gray

try {
    # Download the file
    $zipPath = "$tempDir\keploy-agent-windows_amd64.zip"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing
    
    Write-Host "✅ Download completed" -ForegroundColor Green
    
    # Extract the zip file
    Write-Host "📦 Extracting files..." -ForegroundColor Blue
    Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force
    
    # Find the executable
    $exePath = Get-ChildItem -Path $tempDir -Name "keploy-agent.exe" -Recurse | Select-Object -First 1
    if (-not $exePath) {
        Write-Host "❌ keploy-agent.exe not found in the downloaded archive" -ForegroundColor Red
        exit 1
    }
    
    $sourcePath = Join-Path $tempDir $exePath
    $targetPath = Join-Path $installDir "keploy-agent.exe"
    
    # Copy the executable
    Copy-Item -Path $sourcePath -Destination $targetPath -Force
    Write-Host "✅ Keploy CLI installed to: $targetPath" -ForegroundColor Green
    
    # Add to PATH if not already there
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -notlike "*$installDir*") {
        $newPath = "$currentPath;$installDir"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        Write-Host "✅ Added to PATH" -ForegroundColor Green
    } else {
        Write-Host "ℹ️ Already in PATH" -ForegroundColor Yellow
    }
    
    # Clean up
    Remove-Item -Path $tempDir -Recurse -Force
    
    Write-Host "" -ForegroundColor Green
    Write-Host "🎉 Keploy CLI installed successfully!" -ForegroundColor Green
    Write-Host "" -ForegroundColor White
    Write-Host "To use Keploy, please restart your terminal or run:" -ForegroundColor Yellow
    Write-Host "   refreshenv" -ForegroundColor Cyan
    Write-Host "" -ForegroundColor White
    Write-Host "You can then verify the installation by running:" -ForegroundColor Yellow
    Write-Host "   keploy-agent --help" -ForegroundColor Cyan
    Write-Host "" -ForegroundColor White
    Write-Host "To run your cloud test-suite command:" -ForegroundColor Yellow
    Write-Host "   .\run_keploy_cloud_test.ps1" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Installation failed: $_" -ForegroundColor Red
    exit 1
} 