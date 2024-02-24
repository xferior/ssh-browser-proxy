#!/bin/bash

echo -e "\n  ░▒▓███████▓▒░▒▓███████▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓███████▓▒░░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░"
echo " ░▒▓█▓▒░     ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░"
echo " ░▒▓█▓▒░     ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░"
echo "  ░▒▓██████▓▒░░▒▓██████▓▒░░▒▓████████▓▒░      ░▒▓███████▓▒░░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░ ░▒▓██████▓▒░"
echo "        ░▒▓█▓▒░     ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░"
echo "        ░▒▓█▓▒░     ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░"
echo " ░▒▓███████▓▒░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░"
echo -e "    01110011    01110011     01101000           01110000      01110010     01101111     01111000     01111001\n"

# Define supported browsers
BROWSERS=("chromium" "brave")

# Check installed browsers
INSTALLED_BROWSERS=()
for browser in "${BROWSERS[@]}"; do
  if type "$browser" &>/dev/null; then
    INSTALLED_BROWSERS+=("$browser")
  fi
done

# Exit if no supported browsers are installed
if [ ${#INSTALLED_BROWSERS[@]} -eq 0 ]; then
  echo "[X] No supported browsers are installed. Exiting."
  exit 1
fi

# Display installed browsers and ask for selection
echo "Installed browsers:"
for i in "${!INSTALLED_BROWSERS[@]}"; do
  printf "%d) %s\n" $((i+1)) "${INSTALLED_BROWSERS[$i]}"
done

# Check if valid browser number was entered
while true; do
  read -p "[+] Select a browser by number (Press Enter for 1): " BROWSER_CHOICE
  BROWSER_CHOICE=${BROWSER_CHOICE:-1}
  if [[ "$BROWSER_CHOICE" =~ ^[0-9]+$ ]] && [ "$BROWSER_CHOICE" -ge 1 ] && [ "$BROWSER_CHOICE" -le ${#INSTALLED_BROWSERS[@]} ]; then
    break
  else
    echo "[!] Please select a valid browser number."
  fi
done

SELECTED_BROWSER=${INSTALLED_BROWSERS[$BROWSER_CHOICE-1]}

# Check for running PIDs of the selected browser
BROWSER_PROCESS_COUNT=$(ps -ef | grep -v grep | grep -ci "$SELECTED_BROWSER")
if [ "$BROWSER_PROCESS_COUNT" -ne 0 ]; then
  echo "[+] Detected $BROWSER_PROCESS_COUNT process(es) related to $SELECTED_BROWSER. It might be already running."
  read -p "[+] Do you want to continue? (y/N): " CONTINUE
  if [[ ! $CONTINUE =~ ^[Yy]$ ]]; then
    echo "[X] Please close $SELECTED_BROWSER before proceeding."
    exit 1
  fi
fi

# Check y/n for incognito mode
while true; do
  read -p "[+] Open the browser in incognito mode? [y/n] (Press ENTER for n): " INC_MODE
  INC_MODE=${INC_MODE:-n}
  if [[ "$INC_MODE" =~ ^[yn]$ ]]; then
    break
  else
    echo "[!] Please enter 'y' for yes or 'n' for no."
  fi
done

# Check for user and server SSH details in correct format
read -p "[+] Enter the SSH user and hostname or ip (user@hostname): " SSH_DETAILS
if ! [[ $SSH_DETAILS =~ ^[^@]+@[^@]+$ ]]; then
  echo "[X] SSH details must be in the format 'user@server'. Exiting."
  exit 1
fi

# Ask if the hostname is set up in an SSH config file
while true; do
  read -p "[+] Is the hostname setup in an SSH config file? [y/n] (Press ENTER for n): " SSH_CONFIG_SETUP
  if [[ -z "$SSH_CONFIG_SETUP" ]]; then
    SSH_CONFIG_SETUP="n"
  fi
  if [[ "$SSH_CONFIG_SETUP" =~ ^[yn]$ ]]; then
    break
  else
    echo "[!] Please enter 'y' for yes or 'n' for no."
  fi
done

if [[ $SSH_CONFIG_SETUP =~ ^[y]$ ]]; then
  echo "Skipping hostname checks as it is configured in SSH config."
else

  # Set variable to 'y' for use later in default answer
  NO_SSH_CONFIG_USE_PASS="y"

  # Extract the hostname from SSH details 
  HOSTNAME=$(echo $SSH_DETAILS | cut -d "@" -f2)

  # Reverse DNS lookup
  if ! HOST_LOOKUP=$(host $HOSTNAME | sed 's/\.$//'); then
    echo "[X] Reverse DNS lookup failed for $HOSTNAME"
    exit 1
  fi
  echo "Reverse DNS lookup successful: $HOST_LOOKUP"

  # Ping test
  if ! ping -c 1 $HOSTNAME &>/dev/null; then
    echo "[X] Ping test failed for $HOSTNAME. Please check the host and try again."
    exit 1
  fi
  echo "Ping test successful for $HOSTNAME"

  # Check if the host's key is known
  if ! ssh-keygen -F $HOSTNAME &>/dev/null; then
    echo "[X] Host $HOSTNAME not found in ~/.ssh/known_hosts. Exiting."
    exit 1
  fi
  echo "Host $HOSTNAME found in ~/.ssh/known_hosts"
fi

# Check k/p for SSH authentication method. Check for sshpass if password authentication is selected.
while true; do
  if [ "$NO_SSH_CONFIG_USE_PASS" == "y" ]; then
    read -p "[+] Does the SSH connection use a keypair or password? [k/p] (Press ENTER for password): " SSH_AUTH_METHOD
    SSH_AUTH_METHOD=${SSH_AUTH_METHOD:-p}
  else
    read -p "[+] Does the SSH connection use a keypair or password? [k/p] (Press ENTER for keypair): " SSH_AUTH_METHOD
    SSH_AUTH_METHOD=${SSH_AUTH_METHOD:-k}
  fi
  if [[ "$SSH_AUTH_METHOD" =~ ^[kp]$ ]]; then
    if [ "$SSH_AUTH_METHOD" == "p" ]; then
      if ! type sshpass &>/dev/null; then
        echo "[X] sshpass is required for password authentication. Please install sshpass to continue."
        exit 1
      fi
      read -srp "[+] Enter the SSH password: " SSH_PASS
      SSH_AUTH_METHOD_WORD="password"
      echo
    else
      SSH_AUTH_METHOD_WORD="keypair"
    fi
    break
  else
    echo "[!] Please enter 'k' for keypair or 'p' for password."
  fi
done

# Set SOCKS5 proxy port
read -p "[+] Enter the SOCKS5 proxy port: " PROXY_PORT
if ! [[ $PROXY_PORT =~ ^[0-9]+$ ]] || [ $PROXY_PORT -le 0 ] || [ $PROXY_PORT -gt 65535 ]; then
  echo "[X] Invalid port number. Please enter a number between 1 and 65535."
  exit 1
fi

# Check if the port is in use using lsof
if lsof -i :$PROXY_PORT >/dev/null; then
  echo "[X] Port $PROXY_PORT is already in use:"
  lsof -i :$PROXY_PORT | awk 'NR>1'
  exit 1
else
  echo "Port $PROXY_PORT is avaliable"
fi

# Run SSH command based on authentication method and set PIDs to variables
if [ "$SSH_AUTH_METHOD" == "k" ]; then
  ssh -o PreferredAuthentications=publickey -o ExitOnForwardFailure=yes -o ConnectTimeout=4 -D $PROXY_PORT -C -N -q $SSH_DETAILS &
  PID=$!
elif [ "$SSH_AUTH_METHOD" == "p" ]; then
  sshpass -p $SSH_PASS ssh -o PreferredAuthentications=password -o ExitOnForwardFailure=yes -o ConnectTimeout=4 -D $PROXY_PORT -C -N -q $SSH_DETAILS &
  PID=$!
  SSH_PASS_PID=$(ps -ef | grep [s]shpass | grep "$PID" | awk '{print $2}')
fi
SSH_PID=$(ps -ef |grep [s]sh |grep $PID |awk '{print $2}')

sleep 5 # Wait for connection to work. This setting is 1 second more than ConnectTimeout in the ssh commands above.

# Check that SSH conection worked
if ! kill -0 $SSH_PID >/dev/null 2>&1; then
  echo "Failed to establish SSH connection using $SSH_AUTH_METHOD_WORD."
  echo "Please check your SSH details and ensure the SSH server is accessible."
  exit 1
else
  unset SSH_PASS
fi

# Launch browser with SOCKS5 proxy arg
if [[ $INC_MODE =~ ^[y]$ ]]; then
  ${SELECTED_BROWSER} --proxy-server="socks5://localhost:$PROXY_PORT" --incognito > /dev/null 2>&1 &
  BROWSER_PID=$!
else
  ${SELECTED_BROWSER} --proxy-server="socks5://localhost:$PROXY_PORT" > /dev/null 2>&1 &
  BROWSER_PID=$!
fi

echo "$SELECTED_BROWSER launched with SOCKS5 proxy on port $PROXY_PORT"

wait $BROWSER_PID

# Kill the SSH connection when the browser is closed
kill $SSH_PID
if [ "$SSH_AUTH_METHOD" == "p" ]; then
  kill $SSH_PASS_PID
fi
echo "SSH connection terminated."
exit 0
