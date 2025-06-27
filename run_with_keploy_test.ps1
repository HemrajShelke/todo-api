# Run the application with Keploy in test mode
Write-Host "🧪 Starting Keploy test execution..."
Write-Host "📊 This will run recorded test cases against the API"

# Change to backend directory
Set-Location backend

# Run tests with Keploy
Write-Host "▶️ Executing Keploy tests..."
keploy test -- python app.py

Write-Host "✅ Test execution completed!"
Write-Host "📈 Check the test results above for pass/fail status"
