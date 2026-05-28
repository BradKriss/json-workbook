$projectRoot = Split-Path $PSScriptRoot -Parent
$scratchpad  = Join-Path $projectRoot "scratchpad"
$dateStr = (Get-Date).ToString("MMddyy")
$year     = (Get-Date).ToString("yyyy")
$month    = (Get-Date).ToString("MM")
$day      = (Get-Date).ToString("dd")
$dayFolder = Join-Path $projectRoot "filing-cabinet\_dated\$year\$month\$day"

$increment = 1
do {
    $fileName = "$dateStr-{0:D2}.json" -f $increment
    $filePath = Join-Path $scratchpad $fileName
    $archivedPath = Join-Path $dayFolder $fileName
    $increment++
} while ((Test-Path $filePath) -or (Test-Path $archivedPath))

try {
    $clipText = Get-Clipboard
} catch {
    $clipText = $null
}

if ($clipText) {
    Set-Content -Path $filePath -Value $clipText -Encoding UTF8
} else {
    Set-Content -Path $filePath -Value '' -Encoding UTF8
}

code "$projectRoot" "$filePath"
Write-Host "Created: $fileName"
