# Generate Release Keystore (Run ONCE)

# 1. Create keystore directory
New-Item -ItemType Directory -Force -Path "C:\Users\sahil\keystores"

# 2. Generate keystore (fill in the prompts)
keytool -genkey -v -keystore "C:\Users\sahil\keystores\mftracker-release.jks" `
    -keyalg RSA `
    -keysize 2048 `
    -validity 10000 `
    -alias mftracker `
    -storetype JKS

# You'll be prompted for:
# - Password (remember this!)
# - Name, Organization, City, State, Country
# - Key password (can be same as store password)

Write-Host "Keystore created at: C:\Users\sahil\keystores\mftracker-release.jks"
Write-Host ""
Write-Host "⚠️ IMPORTANT: Save these values for key.properties:"
Write-Host "Store password: [what you entered]"
Write-Host "Key password: [what you entered]"
Write-Host "Key alias: mftracker"
