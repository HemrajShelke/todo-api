# Setup script for Keploy API testing
param(
    [switch]$Record,
    [switch]$Test,
    [switch]$Both
)

Write-Host "🚀 Keploy API Testing Setup" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

# Check if Keploy is installed
try {
    $keployVersion = & keploy --version 2>$null
    Write-Host "✅ Keploy is installed: $keployVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Keploy is not installed. Please install it first." -ForegroundColor Red
    Write-Host "📖 Installation guide: https://keploy.io/docs/installation/" -ForegroundColor Yellow
    exit 1
}

# Check if Python dependencies are installed
Write-Host "🔍 Checking Python dependencies..." -ForegroundColor Blue
Set-Location backend

try {
    python -c "import flask, flask_sqlalchemy, flask_cors, requests" 2>$null
    Write-Host "✅ All Python dependencies are available" -ForegroundColor Green
} catch {
    Write-Host "❌ Missing Python dependencies. Installing..." -ForegroundColor Yellow
    pip install -r requirements.txt
    pip install requests
}

# Function to record tests
function Record-Tests {
    Write-Host "🔴 Starting test recording session..." -ForegroundColor Red
    Write-Host "📝 Make sure to interact with all API endpoints" -ForegroundColor Yellow
    
    # Start recording
    Start-Process -FilePath "keploy" -ArgumentList "record", "--", "python", "app.py" -NoNewWindow
    Start-Sleep -Seconds 5
    
    # Run comprehensive tests
    Write-Host "🧪 Running comprehensive API tests..." -ForegroundColor Blue
    python ..\test_api_with_keploy.py
    
    Write-Host "✅ Recording completed!" -ForegroundColor Green
}

# Function to run tests
function Run-Tests {
    Write-Host "▶️ Running Keploy tests..." -ForegroundColor Blue
    keploy test -- python app.py
    Write-Host "✅ Test execution completed!" -ForegroundColor Green
}

# Main execution logic
if ($Record -or $Both) {
    Record-Tests
}

if ($Test -or $Both) {
    if ($Record -or $Both) {
        Write-Host "⏳ Waiting 5 seconds before running tests..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
    }
    Run-Tests
}

if (-not $Record -and -not $Test -and -not $Both) {
    Write-Host "📖 Usage:" -ForegroundColor Yellow
    Write-Host "  .\setup_keploy_tests.ps1 -Record    # Record new test cases" -ForegroundColor White
    Write-Host "  .\setup_keploy_tests.ps1 -Test      # Run existing tests" -ForegroundColor White
    Write-Host "  .\setup_keploy_tests.ps1 -Both      # Record and then test" -ForegroundColor White
}

Set-Location ..
Write-Host "🎉 Keploy testing setup completed!" -ForegroundColor Green
