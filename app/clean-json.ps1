param(
    [string]$Path = ""
)

$projectRoot = Split-Path $PSScriptRoot -Parent
$scratchpad  = Join-Path $projectRoot "scratchpad"

if (-not $Path) {
    $latest = Get-ChildItem -Path $scratchpad -File |
        Where-Object { $_.Name -match '^\d{6}-\d{2}\.json$' } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $latest) {
        Write-Host "No dated JSON files found in $scratchpad"
        exit
    }
    $Path = $latest.FullName
}

$content = Get-Content -Path $Path -Raw

try {
    $parsed = $content | ConvertFrom-Json

    # If the result is still a string, the content was a JSON-encoded string — parse again
    if ($parsed -is [string]) {
        $parsed = $parsed | ConvertFrom-Json
    }

    $pretty = $parsed | ConvertTo-Json -Depth 20
    Set-Content -Path $Path -Value $pretty -Encoding UTF8
    Write-Host "Cleaned: $(Split-Path $Path -Leaf)"
} catch {
    Write-Host "Failed to parse JSON in $Path"
    Write-Host $_.Exception.Message
}
