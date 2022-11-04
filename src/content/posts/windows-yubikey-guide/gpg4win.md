+++
title = "Setting up Gpg4win for Yubikey 5 NFC"
tags = ["security","windows","gpg",]
date = "2022-11-03"
+++

# Table of Contents
{{< table_of_contents >}}

### Step 1: Setup Gpg4win

To Install Gpg4win, Run the following commands with administrative permissions.
```ps
winget install GnuPG.Gpg4win
```

Now to add Gpg4win to your system Path

```ps
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path",[System.EnvironmentVariableTarget]::Machine) + ';' + ${Env:ProgramFiles(x86)} + '\GnuPG\bin', [System.EnvironmentVariableTarget]::Machine)
```

### Step 2: Generate a Master Key
```ps
gpg --expert --full-gen-key
    > Press 8: Use RSA (set your own capabilities)
    > Press E: Toggle the encrypt capability
```
You should see the following: 
**`Current allowed actions: Sign Certify`**

Now Press Q
Set the KeySize to 2048

Note: Keep a hold/note of the master's PubID and set it as a variable, such as
```ps
$masterKey = "312CA36A885761C43FB25C20DF1554D14ACB4423"
```

### Step 3: Generate a Revocation Cert
```ps
gpg --gen-revoke $masterKey > master-revocation-cert.asc
    > Enter Y
    > Enter 3: "Key is no longer used"
    > Enter a description of what the cert is for, Such as
    "Using revocation certificate, It is very likely that I have lost access to the private key."
```

### Step 3.1: Generate an Encryption Key
```ps
gpg --edit-key $masterKey
    > Type: addkey
    > Select 6: RSA (encrypt only)
    > Set keysize to 2048
    > Type: save
```

### Step 3.2: Create a backup of your Secret key
```ps
gpg --export-secret-key --armor $masterKey > gpg-secret-key.pgp
```

### Step 4: Create Signature and Authentication keys for Yubikey 
**Note: you will want to delete and reimport your master for every Yubikey you want to use.**
```ps
gpg --delete-secret-key $masterKey
gpg --import ./gpg-secret-key.pgp
```

```ps
gpg --edit-key $masterKey
    > Type: addcardkey
    > Select 1 (Signature key)
    > Enter your PIN
    > Follow the prompts
    > Enter your Admin Pin

    > Type: addcardkey
    > Select 3: (Authentication key)
    > Follow the prompts
```

Now to Write the keys to Yubikey.
```ps
    > Type: toggle
    > Type: key 1
    > Type: keytocard
    > Select 2: (Encryption key)
    > Type: save
``` 

### Optional 1: Setup Commit signing for Git
```ps
git config --global --unset gpg.format
git config --global gpg.program "C:\Program Files (x86)\GnuPG\bin\gpg.exe"
gpg --list-secret-keys --keyid-format=long
    > Select the ssb key with [S]
    > type: git config --global user.signingkey <Key>! 
```


### Optional 1: Generate a Pubkey for verification
```ps
gpg --armor --export $masterKey > gpg-pub.asc
```

### Optional 1.1: Make your Pubkey public.
```ps
gpg --keyserver keys.openpgp.org --send-key $masterKey  
```

### Optional 2: Force touch on Yubikey actions.
```ps
ykman openpgp set-touch aut off
ykman openpgp set-touch sig on
ykman openpgp set-touch enc on
```


Note: To fully reset GPG Keys on the Yubikey, do the following:
```
ykman openpgp reset
```

Default Pin: 123456
Default Admin Pin: 12345678

gpg --card-edit
>admin
>name