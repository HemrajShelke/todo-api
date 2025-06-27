# Start recording with Keploy
Write-Host "Starting Keploy in record mode..."

# Set environment variables for Keploy
$env:KEPLOY_MODE = "record"

# Start the application with Keploy
cd backend
python app.py

# Note: The application will run until you stop it with Ctrl+C
Write-Host "Check the keploy folder for recorded test cases"
