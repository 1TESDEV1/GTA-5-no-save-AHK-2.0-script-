# GTA 5 No Save Tool (AHK v2)

A lightweight, fast, and secure AutoHotkey v2 script to instantly block outgoing network connections. This is primarily used in GTA 5 for the "no save" method (stopping the game from communicating with Rockstar cloud servers to prevent saving).

## ✨ Features
* **Instant Action:** Uses Windows Firewall COM API instead of CMD, meaning no annoying black console windows popping up on your screen.
* **Visual Status Badge:** A clean, on-screen overlay shows you exactly when the filter is active (Green/RUNNING) or inactive (Grey/STOPPED).
* **Stealthy:** Uses randomized firewall rule names and IP masking to stay hidden.
* **Clean Exit:** Automatically deletes its firewall rules when you close the script, so your internet doesn't stay blocked by accident.

## ⚙️ Requirements
* You need to have [AutoHotkey v2.0](https://www.autohotkey.com/) installed.
* Windows Firewall REQUIRED: You must have the default Windows Firewall active. If you use a third-party antivirus (like Bitdefender, Kaspersky, etc.), you do NOT need to uninstall it or turn off your virus protection. You just need to temporarily disable its built-in firewall module so the default Windows Firewall can take over. If the third-party firewall is running, it overwrites Windows Firewall and the script won't be able to block the connection.


## 🚀 How to Use
1. Make sure your GTA 5 graphics settings are set to **Borderless Fullscreen**.
2. Download the script and double-click to run it.
3. The script will automatically ask for **Administrator privileges** (this is required to manage Windows Firewall). Click Yes.
4. Use the following hotkeys in-game:

### Hotkeys:
* `Ctrl + F9`  -> **Enable No Save Mode** (Blocks connection)
* `Ctrl + F12` -> **Disable No Save Mode** (Restores connection)
* `Ctrl + F8`  -> **Close the script** (Cleans up firewall rules and exits)

## 📝 License
This project is licensed under the [MIT License](https://choosealicense.com/licenses/mit/) - meaning you are free to use, modify, and share it.

*Disclaimer: Use at your own risk. This tool is provided as-is, and the creator is not responsible for any issues related to your game account or network.*
