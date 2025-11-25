# Set error action to ensure we see issues in logs
$ErrorActionPreference = "Stop"

# Configuration
$RepoPath = "C:\Tools\wingetdotfiles" 
$ConfigFile = "$RepoPath\machine.dsc.yaml"
$LogFile = "$RepoPath\apply_log.txt"

Start-Transcript -Path $LogFile -Append

try {
    Write-Host "--- Starting Update Check: $(Get-Date) ---"
    Set-Location $RepoPath

    # 1. Fetch latest changes from Git
    Write-Host "Fetching from remote..."
    git fetch origin main

    # 2. Check if we are behind
    $localHash = git rev-parse HEAD
    $remoteHash = git rev-parse origin/main

    if ($localHash -ne $remoteHash) {
        Write-Host "Update detected! syncing..."
       
        # Force local to match remote (destroys local changes to ensure exact match)
        git reset --hard origin/main
       
        Write-Host "Applying WinGet Configuration..."
        # This command applies the state.
        # --accept-configuration-agreements: skips the legal prompts
        # --disable-interactivity: prevents it from waiting for user input
        winget configure -f $ConfigFile --accept-configuration-agreements --disable-interactivity
       
        Write-Host "Update applied successfully."
    } else {
        Write-Host "System is up to date."
    }
}
catch {
    Write-Error "An error occurred: $_"
}
finally {
    Stop-Transcript
}
