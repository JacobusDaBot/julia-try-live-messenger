param (
    [string]$TargetIP = "10.202.53.139",
    [string]$Message = "Hello from the network!"
)

$udpClient = New-Object System.Net.Sockets.UdpClient
$targetEndpoint = New-Object System.Net.IPEndPoint ([System.Net.IPAddress]::Parse($TargetIP), 9876)
$message = Read-Host "type your message"
$data = [System.Text.Encoding]::UTF8.GetBytes($message)
$udpClient.Send($data, $data.Length, $targetEndpoint)

Write-Host "Message sent to $TargetIP"
