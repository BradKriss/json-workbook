BeforeAll {
    . "$PSScriptRoot\helpers.ps1"
}

Describe "collect.ps1" {
    BeforeEach {
        $script:root   = New-TempProjectRoot
        $script:script = Join-Path $script:root "app\collect.ps1"
        $script:pad    = Join-Path $script:root "scratchpad"
        $script:cab    = Join-Path $script:root "filing-cabinet\_dated"
    }

    AfterEach {
        Remove-TempProjectRoot $script:root
    }

    It "moves a matching file to the correct YYYY/MM/DD directory" {
        Set-Content -Path "$($script:pad)\052726-01.json" -Value '{}' -Encoding UTF8

        & $script:script

        Join-Path $script:cab "2026\05\27\052726-01.json" | Should -Exist
        "$($script:pad)\052726-01.json"                   | Should -Not -Exist
    }

    It "creates the destination directory when it does not exist" {
        Set-Content -Path "$($script:pad)\010125-01.json" -Value '{}' -Encoding UTF8

        & $script:script

        Join-Path $script:cab "2025\01\01\010125-01.json" | Should -Exist
    }

    It "ignores files that do not match the naming pattern" {
        Set-Content -Path "$($script:pad)\notes.json"     -Value '{}' -Encoding UTF8
        Set-Content -Path "$($script:pad)\052726-01.json" -Value '{}' -Encoding UTF8

        & $script:script

        "$($script:pad)\notes.json" | Should -Exist
    }

    It "skips a file that already exists at the destination and does not overwrite it" {
        $destDir = Join-Path $script:cab "2026\05\27"
        New-Item -ItemType Directory -Path $destDir | Out-Null
        Set-Content -Path "$destDir\052726-01.json"          -Value '{"original":true}' -Encoding UTF8
        Set-Content -Path "$($script:pad)\052726-01.json"    -Value '{"new":true}'      -Encoding UTF8

        $output = & $script:script *>&1

        $output -join ' ' | Should -Match "Skipped"
        (Get-Content "$destDir\052726-01.json" -Raw | ConvertFrom-Json).original | Should -Be $true
    }

    It "reports the correct moved count in output" {
        Set-Content -Path "$($script:pad)\052726-01.json" -Value '{}' -Encoding UTF8
        Set-Content -Path "$($script:pad)\052726-02.json" -Value '{}' -Encoding UTF8

        $output = & $script:script *>&1

        $output -join ' ' | Should -Match "Moved 2 file"
    }

    It "reports zero moved and lists nothing when scratchpad is empty" {
        $output = & $script:script *>&1

        $output -join ' ' | Should -Match "No dated JSON files found"
    }
}
