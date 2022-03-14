# Simple powershell scrip to watch for Service and Application status and start them if they are not responding.
# With mail notification if app or service is not working.
# https://github.com/ddeicide/aswatcher

$MailMessage = @{
To = "recipient@example.com" # Recipient here.
#Bcc = "bccrecipient@example.com", "bcc1recipient@example.com"
From = "sender@example.com" # Sender.
Smtpserver = "smtp.gmail.com" # SMTP Server.
Subject = "YOUR SUBJECT HERE $([System.Net.Dns]::GetHostName())" # Subject here.
Port = 587 
UseSsl = $true
BodyAsHtml = $true
Encoding = “UTF8”
}
$ServiceName = "SERVICE" # Service name here, use Display name.
$ServiceStatus = (Get-Service -Name $ServiceName).status 
$AppName = "APPLICATION" # App name here.
$EmailBody1 = "<h1>Proxy Service status!</h1> <p><strong>Generated on:</strong> $(Get-Date -Format g) <strong><br>Service: </strong> $ServiceName is not working.<br> <strong>Starting!!!</strong> </p>”
$EmailBody2 = "<h1>Proxy Process status!</h1> <p><strong>Generated on:</strong> $(Get-Date -Format g) <strong><br>Process: </strong> $AppName is in $((Get-Process $AppName).Responding) state!<br> <strong>Restarting!!!</strong> </p>”
$MyPasswd = ConvertTo-SecureString "YOUR PASSOWRD HERE" -AsPlainText -Force # Password here. In gmail you can create app password. 
$MyCreds = New-Object System.Management.Automation.PSCredential ("LOGIN@EXAMPLE.COM", $MyPasswd) # Your login here.

# If You want to use STARTTLS enable next line.
# [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if($ServiceStatus -eq "Running")
{
   Write-Host $ServiceName "is Running"
   }
   else 
   {
   Write-Host $ServiceName, " is Stopped"
   Start-Service $ServiceName
   Write-Host "Starting" $ServiceName 
   Send-MailMessage @MailMessage -Credential $MyCreds -Body $EmailBody1
}

if ((Get-Process $AppName).Responding)
{
    Write-Host $AppName "is Running"
    } 
    else
    { 
    Write-Host $AppName "not responding"
    Stop-Process -Name $AppName -Force
    Send-MailMessage @MailMessage -Credential $MyCreds -Body $EmailBody2
    Write-Host "App Stopped with kill command"
    Start-Process -FilePath $AppName
    Write-Host "App started"
}