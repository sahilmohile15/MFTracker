# Script to convert SMS tests to Notification tests
$content = Get-Content "test\services\sms_parser_test.dart.backup" -Raw

# Replace imports
$content = $content -replace 'import ''package:mftracker/services/sms_parser\.dart'';', 'import ''package:mftracker/services/notification_parser.dart'';'
$content = $content -replace 'import ''package:mftracker/services/sms_service\.dart'';', 'import ''package:mftracker/services/notification_service.dart'';'

# Replace group name
$content = $content -replace 'SMS Parser Tests', 'Notification Parser Tests'

# Replace all SMSMessage constructions
$content = $content -replace '(?s)final (sms\d?) = SMSMessage\(\s+id: ''(\d+)'',\s+address: ''([^'']+)'',\s+body: ''([^'']+)'',\s+timestamp: ([^)]+)\)', 'final notification$1 = NotificationData(packageName: ''com.google.android.apps.messaging'', title: ''$3'', text: ''$4'', subText: '''', timestamp: $5'

# Replace test titles
$content = $content -replace 'Parse (\w+) (\w+) transaction', 'Parse $1 $2 notification'
$content = $content -replace 'Parse (\w+) UPI', 'Parse $1 UPI notification'

# Replace parser calls
$content = $content -replace 'SMSParser\.parse\(sms(\d?)\)', 'NotificationParser.parse(notification$1)'

# Replace variable names in simple cases
$content = $content -replace '\bfinal sms = ', 'final notification = '
$content = $content -replace '\bsms\)','notification)'

Set-Content "test\services\notification_parser_test.dart" $content
Write-Host "Conversion complete!"
