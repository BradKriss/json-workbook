BeforeAll {
    . "$PSScriptRoot\helpers.ps1"
}

Describe "clean-json.ps1" {
    BeforeEach {
        $script:root   = New-TempProjectRoot
        $script:script = Join-Path $script:root "app\clean-json.ps1"
        $script:pad    = Join-Path $script:root "scratchpad"
    }

    AfterEach {
        Remove-TempProjectRoot $script:root
    }

    It "pretty-prints compact JSON in-place" {
        $file = Join-Path $script:pad "052726-01.json"
        Set-Content -Path $file -Value '{"a":1,"b":2}' -Encoding UTF8

        & $script:script -Path $file

        $parsed = Get-Content $file -Raw | ConvertFrom-Json
        $parsed.a | Should -Be 1
        $parsed.b | Should -Be 2
        # pretty-printed means multiple lines
        (Get-Content $file).Count | Should -BeGreaterThan 1
    }

    It "unwraps a double-encoded JSON string and pretty-prints the inner object" {
        $inner        = '{"key":"value"}'
        $doubleEnc    = $inner | ConvertTo-Json   # produces "\"{ ... }\""
        $file         = Join-Path $script:pad "052726-01.json"
        Set-Content -Path $file -Value $doubleEnc -Encoding UTF8

        & $script:script -Path $file

        $parsed = Get-Content $file -Raw | ConvertFrom-Json
        $parsed.key | Should -Be "value"
    }

    It "outputs an error message and leaves the file unchanged when JSON is invalid" {
        $file     = Join-Path $script:pad "052726-01.json"
        $original = "not valid json {"
        Set-Content -Path $file -Value $original -Encoding UTF8

        $output = & $script:script -Path $file *>&1

        (Get-Content $file -Raw).Trim() | Should -Be $original.Trim()
        $output -join ' ' | Should -Match "Failed to parse"
    }

    It "auto-selects the latest scratchpad file when no path is provided" {
        $older = Join-Path $script:pad "052726-01.json"
        $newer = Join-Path $script:pad "052726-02.json"
        Set-Content -Path $older -Value '{"which":"older"}' -Encoding UTF8
        Set-Content -Path $newer -Value '{"which":"newer"}' -Encoding UTF8
        # ensure older has an earlier timestamp
        (Get-Item $older).LastWriteTime = (Get-Date).AddMinutes(-5)

        & $script:script

        # newer file should have been cleaned (valid JSON either way, but we can
        # confirm the older file content was NOT touched — it stays compact)
        (Get-Content $older -Raw).Trim() | Should -Be '{"which":"older"}'
    }
}
