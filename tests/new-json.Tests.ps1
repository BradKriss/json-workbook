BeforeAll {
    . "$PSScriptRoot\helpers.ps1"

    # Inject a no-op 'code' command so VS Code doesn't open during tests.
    # code.cmd placed before the real one in PATH takes precedence.
    $script:mockBinDir = Join-Path ([System.IO.Path]::GetTempPath()) "pester-mockbin-$(Get-Random)"
    New-Item -ItemType Directory -Path $script:mockBinDir | Out-Null
    Set-Content -Path "$($script:mockBinDir)\code.cmd" -Value "@echo off`r`n:: mock - suppressed by tests" -Encoding ASCII
    $script:savedPath  = $env:PATH
    $env:PATH          = "$($script:mockBinDir);$env:PATH"
}

AfterAll {
    $env:PATH = $script:savedPath
    Remove-Item -Recurse -Force $script:mockBinDir -ErrorAction SilentlyContinue
}

Describe "new-json.ps1" {
    BeforeEach {
        $script:root   = New-TempProjectRoot
        $script:script = Join-Path $script:root "app\new-json.ps1"
        $script:pad    = Join-Path $script:root "scratchpad"
    }

    AfterEach {
        Remove-TempProjectRoot $script:root
    }

    It "creates a file with the -01 suffix on the first run of the day" {
        & $script:script

        $dateStr = (Get-Date).ToString("MMddyy")
        Join-Path $script:pad "$($dateStr)-01.json" | Should -Exist
    }

    It "increments to -02 when -01 already exists in scratchpad" {
        $dateStr = (Get-Date).ToString("MMddyy")
        Set-Content -Path "$($script:pad)\$($dateStr)-01.json" -Value '' -Encoding UTF8

        & $script:script

        Join-Path $script:pad "$($dateStr)-02.json" | Should -Exist
    }

    It "skips a number already archived in filing-cabinet" {
        $dateStr  = (Get-Date).ToString("MMddyy")
        $year     = (Get-Date).ToString("yyyy")
        $month    = (Get-Date).ToString("MM")
        $day      = (Get-Date).ToString("dd")
        $archDir  = Join-Path $script:root "filing-cabinet\_dated\$year\$month\$day"
        New-Item -ItemType Directory -Path $archDir | Out-Null
        Set-Content -Path "$archDir\$($dateStr)-01.json" -Value '' -Encoding UTF8

        & $script:script

        Join-Path $script:pad "$($dateStr)-02.json" | Should -Exist
        Join-Path $script:pad "$($dateStr)-01.json" | Should -Not -Exist
    }

    It "creates an empty file when Get-Clipboard returns nothing" {
        # Set clipboard to empty so the script falls through to the empty-file branch.
        Set-Clipboard -Value $null -ErrorAction SilentlyContinue

        & $script:script

        $dateStr = (Get-Date).ToString("MMddyy")
        $file    = Join-Path $script:pad "$($dateStr)-01.json"
        $file | Should -Exist
        (Get-Content $file -Raw).Trim() | Should -BeNullOrEmpty
    }
}
