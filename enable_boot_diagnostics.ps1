param (
    [string]$logFile = "C:\Logs\Enable_Boot_Diagnostics_Log.txt"
)

# Set execution policy to RemoteSigned for the current user (will take effect in future sessions)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

# Function to log messages
function Log-Message {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $Message"
    Add-Content -Path $logFile -Value $logEntry
}

# Ensure the log directory exists
$logDir = Split-Path -Parent $logFile
if (-not (Test-Path -Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    Log-Message "Log directory '$logDir' created."
}

# Function to check if Boot Diagnostics is already enabled
function Is-BootDiagnosticsEnabled {
    try {
        $enableddiags = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "VerboseStatus" -ErrorAction SilentlyContinue
        if ($enableddiags.VerboseStatus -eq 1) {
            Write-Host "Boot Diagnostics is already enabled."
            Log-Message "Boot Diagnostics is already enabled."
            return $true
        } else {
            return $false
        }
    } catch {
        Write-Error "Failed to check Boot Diagnostics status. Error: $_"
        Log-Message "Failed to check Boot Diagnostics status. Error: $_"
        Exit 1
    }
}

# Function to enable Boot Diagnostics
function Enable-BootDiagnostics {
    try {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "VerboseStatus" -Value 1 -Type DWord
        Write-Host "Boot Diagnostics enabled successfully."
        Log-Message "Boot Diagnostics enabled successfully."
    } catch {
        Write-Error "Failed to enable Boot Diagnostics. Error: $_"
        Log-Message "Failed to enable Boot Diagnostics. Error: $_"
        Exit 2
    }
}

# Check if the Boot Diagnostics is already enabled
if (-not (Is-BootDiagnosticsEnabled)) {
    Enable-BootDiagnostics
} else {
    Log-Message "Boot Diagnostics was already enabled."
}

Write-Host "Boot Diagnostics check completed."
Log-Message "Boot Diagnostics check completed."
