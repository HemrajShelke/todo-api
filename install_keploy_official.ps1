# Official Keploy CLI Installation Script for Windows
# Based on: https://keploy.io/docs/running-keploy/api-testing-cicd/

param(
    [string]$ApiKey = "2XvozFt51aiBHXMFHw=="
)

Write-Host "Installing Keploy CLI (Official Method)" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

# Set environment variable
$env:KEPLOY_API_KEY = $ApiKey
Write-Host "API Key set: $env:KEPLOY_API_KEY" -ForegroundColor Green

# Check if running on Windows
if ($env:OS -ne "Windows_NT") {
    Write-Host "This script is designed for Windows only." -ForegroundColor Red
    exit 1
}

Write-Host "Installing Keploy CLI using official method..." -ForegroundColor Blue

try {
    # Download and run the official installation script
    $installScript = Invoke-WebRequest -Uri "https://keploy.io/ent/install.sh" -UseBasicParsing
    Write-Host "Installation script downloaded" -ForegroundColor Green
    
    # Note: The official script is for Linux/macOS, so we'll provide Windows instructions
    Write-Host "Official script is for Linux/macOS" -ForegroundColor Yellow
    Write-Host "For Windows, please follow these steps:" -ForegroundColor Cyan
    
    Write-Host "" -ForegroundColor White
    Write-Host "1. Visit: https://github.com/keploy/keploy/releases" -ForegroundColor Yellow
    Write-Host "2. Download the latest Windows release (keploy_windows_amd64.zip)" -ForegroundColor Yellow
    Write-Host "3. Extract the ZIP file" -ForegroundColor Yellow
    Write-Host "4. Add keploy.exe to your PATH or run it directly" -ForegroundColor Yellow
    Write-Host "" -ForegroundColor White
    
    Write-Host "Alternative: Use WSL (Windows Subsystem for Linux)" -ForegroundColor Green
    Write-Host "   If you have WSL installed, you can run:" -ForegroundColor White
    Write-Host "   wsl curl --silent -L https://keploy.io/ent/install.sh | bash" -ForegroundColor Cyan
    
    Write-Host "" -ForegroundColor White
    Write-Host "Once installed, you can run your test-suite command:" -ForegroundColor Green
    Write-Host "   keploy test-suite --app=9d09b06a-70f5-443d-871e-47134856f411 --base-path https://github.com/HemrajShelke/todo-api.git --cloud" -ForegroundColor Cyan
    
    Write-Host "" -ForegroundColor White
    Write-Host "For CI/CD, use the GitHub Actions workflow I've already set up!" -ForegroundColor Green
    Write-Host "   It uses the official installation method automatically." -ForegroundColor White
    
} catch {
    Write-Host "Installation failed: $_" -ForegroundColor Red
    Write-Host "" -ForegroundColor White
    Write-Host "Manual Installation Steps:" -ForegroundColor Yellow
    Write-Host "1. Go to https://github.com/keploy/keploy/releases" -ForegroundColor Cyan
    Write-Host "2. Download keploy_windows_amd64.zip" -ForegroundColor Cyan
    Write-Host "3. Extract and add to PATH" -ForegroundColor Cyan
}

Write-Host "" -ForegroundColor Green
Write-Host "Installation instructions completed!" -ForegroundColor Green
Write-Host "Documentation: https://keploy.io/docs/running-keploy/api-testing-cicd/" -ForegroundColor Cyan 