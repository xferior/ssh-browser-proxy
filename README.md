# ssh-browser-proxy
A Bash script that creates a SSH SOCKS5 proxy connection and launches a web browser with the proxy information configured. It supports Chromium and Brave browsers and offers options for SSH connection via keypair or password authentication.

![SSH PROXY BANNER](https://github.com/xferior/ssh-browser-proxy/assets/149968394/0a0acab2-b9f2-471a-81db-fb15f1d7d7ac)

## Features

- **SSH Proxy**: Establishes an SSH SOCKS5 proxy connection using either a keypair or password authentication.
- **Chrome Browser Support**: Automatically detects installed browsers. Default array contains Chromium and Brave.
- **Incognito Mode**: Option to open the browser in incognito mode.
- **Dynamic Port Assignment**: Allows specifying the SOCKS5 proxy port.
- **Connectivity Checks**: Performs reverse DNS lookup, ping test, and checks if the host's key is known.

## Prerequisites

- `ssh` and `ssh-keygen` must be installed and available in your system's $PATH.
- `sshpass` is required for password authentication.
- At least one of the supported browsers (Chromium or Brave) must be installed.
- If using a keypair authentication, the key should already be accepted and added to the list of known hosts.

## Usage

- Clone repo `git clone https://github.com/xferior/ssh-browser-proxy`.
- Set script to executable `chmod +x ssh-browser-proxy/launch-proxy-browser.sh`.
- Run script `./ssh-browser-proxy/launch-proxy-browser.sh`.

### Selecting a Browser

Select the installed browser you wish to use by entering the corresponding number.

```
Installed browsers:
1) chromium
2) brave
[+] Select a browser by number (Press Enter for 1):
```

### Specify Incognito Mode

You can choose to open the browser in incognito mode by responding `y` when prompted.

```
[+] Open the browser in incognito mode? [y/n] (Press ENTER for n): 
```

### Entering SSH Connection Details

Provide the SSH user and hostname (or IP address) in the format `user@hostname` when prompted.

```
[+] Enter the SSH user and hostname or ip (user@hostname): 
```

### Specify If Connection Details Are In ~/.ssh/config

If you've setup connection details, you can enter 'y' to use these settings with the SSH Connection Details above.

Host remoteServer
   HostName = 255.255.255.255
   User = proxy
   PreferredAuthentications publickey
   IdentityFile = /home/user/.ssh/id_remoteServer_ed25519_1-1-1970

```
[+] Is the hostname setup in an SSH config file? [y/n] (Press ENTER for n): 
```

Selecting 'n' will cause the script to test reverse DNS lookup, ping, and known hosts.

```
Reverse DNS lookup successful: 255.255.255.255.in-addr.arpa domain name pointer remoteServer
Ping test successful for 255.255.255.255
Host 255.255.255.255 found in ~/.ssh/known_hosts.
```

### Choosing SSH Authentication Method

Select the authentication method for the SSH connection: 
- Enter `k` for keypair authentication.
- Enter `p` for password authentication.

```
[+] Does the SSH connection use a keypair or password? [k/p] (Press ENTER for password): 
```

### Choose Keypair Or Password

If you previously selected 'y' to "...hostname setup in an SSH config file", the default answer will be 'k'.

```
[+] Does the SSH connection use a keypair or password? [k/p] (Press ENTER for keypair): 
```
If you previously selected 'n', the default answer will be 'p'.

```
[+] Does the SSH connection use a keypair or password? [k/p] (Press ENTER for password):  
```

### Specifying the SOCKS5 Proxy Port

Enter the desired port number for the SOCKS5 proxy connection.

```
[+] Enter the SOCKS5 proxy port: 1234
Port 1234 is avaliable
```

### Browser Launch

The script will check that the SSH connection was successful. If so, the selected browser will launch with proxy setting.

```
chromium launched with SOCKS5 proxy on port 1234
```

### Browser Close

The script will close the SSH connection once the browser is closed.

```
SSH connection terminated.
```


## Notes

- The script performs various checks to ensure the security and availability of the SSH connection.
- The script will prompt for the SSH password if password authentication is selected.
- The script will check that no instances of the selected browser are running before proceeding with the setup.
- The script will change default answers based on previous choices to make it easier to complete.
- The script terminates the SSH connection once the browser is closed.

## Troubleshooting

- Check that at least one browser is installed and has been correctly added to the system's $PATH.
- Check the SSH user and hostname (or IP address) for typos or connectivity issues if the SSH connection fails.
- If using a keypair authentication, the key should already be accepted and added to the list of known hosts.
