$udpClient = New-Object System.Net.Sockets.UdpClient 9876
$localEndPoint = New-Object System.Net.IPEndPoint ([System.Net.IPAddress]::Any, 9876)

Write-Host "Waiting for messages on port 9876..."


while ($true) {
    $received = $udpClient.Receive([ref]$localEndPoint)
    $message = [System.Text.Encoding]::UTF8.GetString($received)
    Write-Host "Message from $message.Substring(0, 5)"
    # Show popup
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show($message, "Network Message")
}
