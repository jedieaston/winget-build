# This script installs the latest release of wingetdev from this repository.
# Note that you will also need the VCRedists. If you don't think you have them just run `winget install Microsoft.VC++2015-2019Redist-x64 -s winget` and you'll be good to go!


$ErrorActionPreference = "Stop"

function Update-Environment {
    $locations = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
                 'HKCU:\Environment'

    $locations | ForEach-Object {
        $k = Get-Item $_
        $k.GetValueNames() | ForEach-Object {
            $name  = $_
            $value = $k.GetValue($_)

            if ($userLocation -and $name -ieq 'PATH') {
                $Env:Path += ";$value"
            } else {
                Set-Item -Path Env:$name -Value $value
            }
        }

        $userLocation = $true
    }
}


mkdir ~\.bin\wingetdev -ErrorAction SilentlyContinue

iwr https://github.com/jedieaston/winget-build/releases/latest/download/wingetdev.zip -OutFile $env:TEMP\wingetdev.zip
Expand-Archive $env:TEMP\wingetdev.zip $env:TEMP\wingetdev -Force
mv $env:TEMP\wingetdev\AppInstallerCLI\* ~\.bin\wingetdev\ -Force
rm $env:TEMP\wingetdev* -Force -Recurse

Write-Host "wingetdev is up-to-date!" -ForegroundColor Green
if (-Not (Get-Command 'wingetdev' -ErrorAction SilentlyContinue)) {
    # Add ~/.bin to PATH....
    [Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";" + ($env:USERPROFILE) + "\.bin\wingetdev",
    [EnvironmentVariableTarget]::User)
    Update-Environment
    Write-Host -ForegroundColor Green "wingetdev is now on your PATH! This shell should be ready, but you may have to restart others."
    }
