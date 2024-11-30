#Requires -RunAsAdministrator
#Requires -Version 7

# Linked Files (Destination => Source)
$symlinks = @{
    $PROFILE.CurrentUserAllHosts                                                                    = ".\Profile.ps1"
    "$HOME\AppData\Local\nvim"                                                                      = ".\nvim"
    "$HOME\AppData\Local\fastfetch"                                                                 = ".\fastfetch"
    "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" = ".\windows-terminal\settings.json"
    "$HOME\.gitconfig"                                                                              = ".\.gitconfig"
    "$HOME\AppData\Roaming\lazygit"                                                                 = ".\lazygit"
    "$HOME\AppData\Roaming\AltSnap\AltSnap.ini"                                                     = ".\altsnap\AltSnap.ini"
    "$HOME\.glzr"                                                                                   = ".\glzr"
    "$HOME\AppData\Local\Microsoft\PowerToys"                                                       = ".\powertoys"
}

# Install winget 'manually' as i never have ms-store in my windows installions - https://learn.microsoft.com/en-us/windows/package-manager/winget/

Write-Host "Installing WinGet PowerShell module from PSGallery..."
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
Write-Host "Using Repair-WinGetPackageManager cmdlet to bootstrap WinGet..."
Repair-WinGetPackageManager
Write-Host "WinGet installed successfully!"


$wingetPackages = @(
    "git.git" # Git
    "kitware.cmake" # CMake
    "openjs.nodejs" # NodeJS
    "microsoft.powershell" # PowerShell 7
    "Microsoft.WindowsTerminal" # Windows Terminal
    "starship.starship" # Starship Prompt
    "glzr-io.glazewm" # Tiling Manager
    "glzr-io.zebar" # Top bar
    "videolan.vlc" # Video Player
    "nomacs.nomacs" # Image Viewer
    "valve.steam" # Steam
    "fastfetch-cli.fastfetch" # FastFetch
    "microsoft.dotnet.sdk.6" # .NET 6 SDK
    "microsoft.dotnet.sdk.8" # .NET 8 SDK
    "microsoft.dotnet.sdk.9" # .NET 9 SDK
    "discord.discord" # Discord
    "jetbrains.toolbox" # JetBrains Toolbox
    "aristocratos.btop4win" # btop++ for windows
    "microsoft.powertoys" # PowerToys
    "microsoft.visualstudiocode" # VS Code
    "m2Team.NanaZip" # Archive tool
    "spotify.spotify" # Spotify
    "google.chrome.dev" # Chrome for web development
    "altsnap.altsnap" # AltSnap
    "eza-community.eza" # A modern alternative to ls 
    "neovim.neovim" # Neovim
    "chocolatey.chocolatey" # Chocolatey
)

$chocoPackages = @(
    "bat" # A cat(1) clone with syntax highlighting and Git integration. 
    "fd" # more faster and better alternative to "find"
    "fzf" # fuzzy finder
    "lazygit" # git console gui
    "mingw"
    "nerd-fonts-jetbrainsmono"
    "ripgrep" # ripgrep recursively searches directories for a regex pattern while respecting your gitignore
    "zoxide" #  A smarter cd command. Supports all major shells. 
)

$psModules = @(
    "CompletionPredictor"
    "PSScriptAnalyzer"
    "ps-color-scripts"
)

# Set working directory
Set-Location $PSScriptRoot
[Environment]::CurrentDirectory = $PSScriptRoot

# Install winget packages
Write-Host "Installing winget packages..."
$installedWingetPackages = winget list | Out-String
foreach ($wingetPackage in $wingetPackages) {
    if ($installedWingetPackages -notmatch $wingetPackage) {
        winget install --id $wingetPackage
    }
}

# Path Refresh
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Install Chocolatey packages
Write-Host "Installing Chocolatey packages..."
$installedChocoPackages = (choco list --limit-output --id-only).Split("`n")
foreach ($chocoPackage in $chocoPackages) {
    if ($installedChocoPackages -notcontains $chocoPackage) {
        choco install $chocoPackage -y
    }
}

# Install PS Modules
Write-Host "Installing PowerShell modules..."
foreach ($psModule in $psModules) {
    if (!(Get-Module -ListAvailable -Name $psModule)) {
        Install-Module -Name $psModule -Force -AcceptLicense -Scope CurrentUser
    }
}

# Delete OOTB Nvim Shortcuts (including QT)
if (Test-Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Neovim\") {
    Remove-Item "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Neovim\" -Recurse -Force
}

# Create Symbolic Links
Write-Host "Creating Symbolic Links..."
foreach ($symlink in $symlinks.GetEnumerator()) {
    Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    New-Item -ItemType SymbolicLink -Path $symlink.Key -Target (Resolve-Path $symlink.Value) -Force | Out-Null
}

# Install bat themes
bat cache --clear
bat cache --build

.\altsnap\createTask.ps1 | Out-Null

# Set reg edit changes
Write-Host "Applying registery changes"
& "$PSScriptRoot\reg\setup.ps1"