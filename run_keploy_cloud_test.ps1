# Keploy Cloud Test Suite Runner
param(
    [string]$ApiKey = "2XvozFt51aiBHXMFHw==",
    [string]$AppId = "9d09b06a-70f5-443d-871e-47134856f411",
    [string]$BasePath = "https://github.com/HemrajShelke/todo-api.git"
)

Write-Host "☁️ Keploy Cloud Test Suite" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

# Set environment variables
$env:KEPLOY_API_KEY = $ApiKey
Write-Host "✅ API Key set: $env:KEPLOY_API_KEY" -ForegroundColor Green
Write-Host "📱 App ID: $AppId" -ForegroundColor Blue
Write-Host "🔗 Base Path: $BasePath" -ForegroundColor Blue

# Check if Keploy is installed
try {
    $keployVersion = & keploy --version 2>$null
    Write-Host "✅ Keploy is installed: $keployVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Keploy is not installed." -ForegroundColor Red
    Write-Host "📖 Please install Keploy first:" -ForegroundColor Yellow
    Write-Host "   Visit: https://keploy.io/docs/installation/" -ForegroundColor Cyan
    Write-Host "   Or run: winget install keploy.keploy" -ForegroundColor Cyan
    exit 1
}

# Run the test-suite command
Write-Host "🚀 Running Keploy test-suite..." -ForegroundColor Blue
Write-Host "Command: keploy test-suite --app=$AppId --base-path=$BasePath --cloud" -ForegroundColor Gray

try {
    & keploy test-suite --app=$AppId --base-path=$BasePath --cloud
    Write-Host "✅ Test-suite completed successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Test-suite failed: $_" -ForegroundColor Red
    Write-Host "💡 Troubleshooting tips:" -ForegroundColor Yellow
    Write-Host "   - Check your API key is valid" -ForegroundColor White
    Write-Host "   - Verify the app ID exists in your Keploy account" -ForegroundColor White
    Write-Host "   - Ensure the repository is accessible" -ForegroundColor White
    exit 1
}

Write-Host "🎉 Cloud test-suite execution completed!" -ForegroundColor Green 