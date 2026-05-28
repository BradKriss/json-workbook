Import-Module Pester -MinimumVersion 5.0 -ErrorAction Stop
Invoke-Pester "$PSScriptRoot" -Output Detailed
