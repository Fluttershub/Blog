+++
title = "Using Yubikey 5 NFC with OpenSSH For Windows"
tags = ["security","windows","ssh"]
date = "2022-11-03"
+++

# Table of Contents
{{< table_of_contents >}}

### Step 0: Preparing Windows 10 for OpenSSH (Importent!)

1. Check if you have OpenSSH already installed.
```ps
ssh -V
```
if you get the following
```ps
❯ ssh -V
OpenSSH_for_Windows_8.9p1, LibreSSL 3.4.3
```
If OpenSSH Version is < 8.1, then you need to remove OpenSSH from your system.<br>
if OpenSSH Version is 8.2 or greater, Feel free to jump to [Step 2](#step-2-creating-your-ssh-keys)

Most likely, if you are using 8.1, then it was installed from **Add or Remove Optional Features** or **Turn Windows Features on or off**
So look though these and remove OpenSSH.

### Step 1: Install an Updated version of OpenSSH.
Run the following command in an Administrator powershell window .

```ps
winget install Microsoft.OpenSSH.Beta
```
To add OpenSSH to your system path, Run the following command.
```ps
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path",[System.EnvironmentVariableTarget]::Machine) + ';' + ${Env:ProgramFiles} + '\OpenSSH', [System.EnvironmentVariableTarget]::Machine)
```

To verify that OpenSSH is setup correctly, run `ssh -V` again
```ps
❯ ssh -V
OpenSSH_for_Windows_8.9p1, LibreSSL 3.4.3
```

### Step 2: Creating A Multifactor SSH key (This returns a Private keystub + and a .pub)
**Note: This keeps the Private Key on the Yubikey, The Private file you recieve just tells SSH about the Yubikey and does not contain the private key.**
```ps
$keyPath = Join-Path $env:USERPROFILE '/.ssh/' $env:USERNAME
$keySN = ykman info | Select-String "Serial number:"; $keySN = $keySN.Line.split();
$keySN = $keySN[2]

ssh-keygen -t ecdsa-sk -f $keyPath-$keySN-yubikey-master -O resident
```

If this is a new Key, Windows may ask you to setup a pin for the Yubikey.
***Note: This is your FIDO security pin, it can only be numbers and should be something you can easily remember.***

Now simply upload your public key and you are done.


