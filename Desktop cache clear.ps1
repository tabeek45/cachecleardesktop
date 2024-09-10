# Define the directories to clear
$systemDirectories = @(
    "C:\Windows\Temp",
    "C:\Windows\Prefetch",
    "C:\Windows\SoftwareDistribution\Download"
)

# Function to delete all files in a given directory and calculate the size of deleted files
function Clear-Directory($directory) {
    $totalSize = 0
    if (Test-Path -Path $directory) {
        $files = Get-ChildItem -Path $directory -Recurse -Force -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            if ($file -is [System.IO.FileInfo]) {
                $totalSize += $file.Length
            }
        }
        $files | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        $totalSizeGB = [math]::Round($totalSize / 1GB, 2)
        Write-Host "Cleared files in $directory. Freed $totalSizeGB GB."
        return $totalSizeGB
    } else {
        Write-Host "Directory $directory does not exist."
        return 0
    }
}

$totalFreed = 0

# Clear the system directories
foreach ($dir in $systemDirectories) {
    $freed = Clear-Directory -directory $dir
    $totalFreed += $freed
}

# Get all user directories
$userDirectories = Get-ChildItem -Path "C:\Users" -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer -and $_.Name -ne "Public" -and $_.Name -ne "Default" -and $_.Name -ne "Default User" }

# Clear Temp directory for each user
foreach ($userDir in $userDirectories) {
    $userTempDir = Join-Path -Path $userDir.FullName -ChildPath "AppData\Local\Temp"
    $freed = Clear-Directory -directory $userTempDir
    $totalFreed += $freed
}

Write-Host "All specified files and directories have been cleared. Total space freed: $([math]::Round($totalFreed, 2)) GB."


pause