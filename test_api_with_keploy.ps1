# Start the application with Keploy in test mode
Write-Host "Starting Keploy in test mode..."

# Set environment variables for Keploy
$env:KEPLOY_MODE = "test"

# Run the test script
cd backend
python ..\test_api_with_keploy.py

Write-Host "Test execution completed. Check the results above." 