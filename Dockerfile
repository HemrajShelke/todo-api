# Use Windows Server Core as base
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set working directory
WORKDIR C:\\app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV FLASK_APP=app.py
ENV FLASK_ENV=production

# Install Python and pip
RUN powershell -Command \
    $ErrorActionPreference = 'Stop'; \
    Invoke-WebRequest -Uri https://www.python.org/ftp/python/3.11.0/python-3.11.0-amd64.exe -OutFile python-3.11.0-amd64.exe ; \
    Start-Process python-3.11.0-amd64.exe -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1' -Wait ; \
    Remove-Item python-3.11.0-amd64.exe

# Copy requirements first for better caching
COPY backend/requirements.txt .

# Install Python dependencies
RUN python -m pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY backend/ .

# Create non-root user (using Windows commands)
RUN net user /add appuser

# Set user
USER appuser

# Expose port
EXPOSE 5000

# Health check using PowerShell
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD powershell -Command \
        try { \
            $response = Invoke-WebRequest -Uri http://localhost:5000/todos -UseBasicParsing; \
            if ($response.StatusCode -eq 200) { exit 0 } else { exit 1 } \
        } catch { exit 1 }

# Run the application
CMD ["python", "app.py"] 