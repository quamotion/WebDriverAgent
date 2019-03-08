To export and encrypt your provisioning profile, developer certificate and the private key for your
developer certificate:

1. Using the Keychain Access application, export your private key. The result is a `.p12` file.
   Provide a password for encrypting the private key. You don't need to double-encrypte the `.p12`
   file.
2. Using the Keychain Access application, export your developer certificate. The result is a `.cer`
   file.
3. Copy your developer profile from `~/Library/MobileDevice/Provisioning Profiles`. The result is
   a `.developerprofile` file.

Next, encrypt the `.cer` and `.developerprofile` file:

```
openssl aes-256-cbc -k "$KEY_PASSWORD" -in adhoc.cer -a -out adhoc.cer.enc
openssl aes-256-cbc -k "$KEY_PASSWORD" -in adhoc.mobileprovision -a -out adhoc.mobileprovision.enc
```

