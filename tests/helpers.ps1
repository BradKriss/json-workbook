function New-TempProjectRoot {
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory -Path $tmp | Out-Null
    New-Item -ItemType Directory -Path "$tmp\scratchpad" | Out-Null
    New-Item -ItemType Directory -Path "$tmp\filing-cabinet\_dated" | Out-Null
    New-Item -ItemType Directory -Path "$tmp\app" | Out-Null

    $realAppDir = Join-Path (Split-Path $PSScriptRoot -Parent) "app"
    Copy-Item "$realAppDir\*.ps1" "$tmp\app\"

    return $tmp
}

function Remove-TempProjectRoot {
    param([string]$Path)
    if (Test-Path $Path) {
        Remove-Item -Recurse -Force $Path
    }
}
