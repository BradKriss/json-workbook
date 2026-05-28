param(
    [string]$SourceDir = ""
)

$projectRoot = Split-Path $PSScriptRoot -Parent

if (-not $SourceDir) {
    $SourceDir = $projectRoot
}

$datedRoot = Join-Path $projectRoot "filing-cabinet\_dated"

$files = Get-ChildItem -Path $SourceDir -File |
    Where-Object { $_.Name -match '^\d{6}-\d{2}\.json$' }

if (-not $files) {
    Write-Host "No dated JSON files found in $SourceDir"
    exit
}

$movedCount = 0
foreach ($file in $files) {
    # Parse MMddyy from filename
    $mm   = $file.Name.Substring(0, 2)
    $dd   = $file.Name.Substring(2, 2)
    $yy   = $file.Name.Substring(4, 2)
    $year = "20$yy"

    $dayFolder = Join-Path $datedRoot "$year\$mm\$dd"
    if (-not (Test-Path $dayFolder)) {
        New-Item -ItemType Directory -Path $dayFolder | Out-Null
    }

    $dest = Join-Path $dayFolder $file.Name
    if (Test-Path $dest) {
        Write-Host "Skipped (already exists): $($file.Name)"
    } else {
        Move-Item -Path $file.FullName -Destination $dest
        $movedCount++
    }
}

Write-Host "Moved $movedCount file(s) to filing-cabinet/_dated/"
