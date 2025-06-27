# Docker-based Keploy testing script
param(
    [switch]$Record,
    [switch]$Test,
    [switch]$Both,
    [string]$ApiKey = "2XvozFt51aiBHXMFHw=="
)

Write-Host "🐳 Docker-based Keploy API Testing" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

# Set environment variables
$env:KEPLOY_API_KEY = $ApiKey
Write-Host "✅ API Key set: $env:KEPLOY_API_KEY" -ForegroundColor Green

# Check if Docker is running
try {
    docker version | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}

# Function to run tests using Docker
function Run-KeployTests {
    Write-Host "🧪 Running Keploy tests with Docker..." -ForegroundColor Blue
    
    # Build and run the application with Keploy
    docker-compose up --build -d
    
    Write-Host "⏳ Waiting for application to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    # Run the test script
    Write-Host "🧪 Running API tests..." -ForegroundColor Blue
    python test_api_with_keploy.py
    
    Write-Host "✅ Tests completed!" -ForegroundColor Green
    
    # Stop the containers
    docker-compose down
}

# Function to record tests
function Record-KeployTests {
    Write-Host "🔴 Recording Keploy tests..." -ForegroundColor Red
    
    # Start the application
    docker-compose up --build -d
    
    Write-Host "⏳ Waiting for application to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    # Run comprehensive tests for recording
    Write-Host "🧪 Running comprehensive API tests for recording..." -ForegroundColor Blue
    python test_api_with_keploy.py
    
    Write-Host "✅ Recording completed!" -ForegroundColor Green
    
    # Stop the containers
    docker-compose down
}

# Main execution
if ($Record -or $Both) {
    Record-KeployTests
}

if ($Test -or $Both) {
    if ($Record -or $Both) {
        Write-Host "⏳ Waiting 5 seconds before running tests..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
    }
    Run-KeployTests
}

if (-not $Record -and -not $Test -and -not $Both) {
    Write-Host "📖 Usage:" -ForegroundColor Yellow
    Write-Host "  .\run_keploy_tests_docker.ps1 -Record    # Record new test cases" -ForegroundColor White
    Write-Host "  .\run_keploy_tests_docker.ps1 -Test      # Run existing tests" -ForegroundColor White
    Write-Host "  .\run_keploy_tests_docker.ps1 -Both      # Record and then test" -ForegroundColor White
    Write-Host "  .\run_keploy_tests_docker.ps1 -ApiKey 'your-key'  # Use custom API key" -ForegroundColor White
}

Write-Host "🎉 Docker-based Keploy testing completed!" -ForegroundColor Green 