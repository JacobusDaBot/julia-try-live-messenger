param (
    [string]$TargetIP = "10.202.53.139",
    [string]$Message = "Hello from the network!"
)
#$TargetIP = Read-Host "Destination IP:"

$udpClient = New-Object System.Net.Sockets.UdpClient
$targetEndpoint = New-Object System.Net.IPEndPoint ([System.Net.IPAddress]::Parse($TargetIP), 9876)
$udpClientSelf = New-Object System.Net.Sockets.UdpClient 9876
$localEndPoint = New-Object System.Net.IPEndPoint ([System.Net.IPAddress]::Any, 9876)

while ($true){
    $message = Read-Host "type your message"
    $data = [System.Text.Encoding]::UTF8.GetBytes($message)
    $udpClient.Send($data, $data.Length, $targetEndpoint)
    Write-Host "$message sent to $TargetIP"
    $received = $udpClientSelf.Receive([ref]$localEndPoint)
    $Rmessage = [System.Text.Encoding]::UTF8.GetString($received)
    Write-Host "Message from $Rmessage.Substring(0, 5)"
}