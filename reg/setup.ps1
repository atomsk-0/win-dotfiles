# Disables WIN + [Q,R,T,S,D,H,X,1,2,3,4,5,6,7,8,9] Hotkeys
Start-Process regedit -ArgumentList "/s $PSScriptRoot\disable-win-hotkeys.reg"

# Sets windows terminal as default terminal
Start-Process regedit -ArgumentList "/s $PSScriptRoot\setup-console-host.reg"