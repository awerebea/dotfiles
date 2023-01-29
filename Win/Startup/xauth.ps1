New-Item -Type File -Path "${env:USERPROFILE}\.Xauthority" -force

# Generate cookie from hex characters
function Get-RandomPassword {
    param (
        [Parameter(Mandatory)]
        [int] $length
    )
    #$charSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789{]+-[*=@:)}$^%;(_!&amp;#?>/|.'.ToCharArray()
    $charSet = 'abcdef0123456789'.ToCharArray()
    $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $bytes = New-Object byte[]($length)
 
    $rng.GetBytes($bytes)
 
    $result = New-Object char[]($length)
 
    for ($i = 0 ; $i -lt $length ; $i++) {
        $result[$i] = $charSet[$bytes[$i]%$charSet.Length]
    }
 
    return (-join $result)
}

# & "c:\Program Files\VcXsrv\xauth.exe" add "$((Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "vEthernet (WSL)").IPAddress):0" . $(wsl mcookie)

& "c:\Program Files\VcXsrv\xauth.exe" add "$((Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "vEthernet (WSL)").IPAddress):0" . $(Get-RandomPassword 16)

# to confirm if it worked:
# & "c:\Program Files\VcXsrv\xauth.exe" -n list

Copy-Item "${env:USERPROFILE}\.Xauthority" -Destination "\\wsl.localhost\Ubuntu-22.04\home\andrei"
