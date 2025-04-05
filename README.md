# ADB Manager (scrcpy wrapper)

This is a little script i made for myself to manage scrcpy windows in a fancy menu-style way :D  
Works like a mini phone control center — toggling visibility, launching apps, and more.

⚠️ This is experimental, not production tested. Back up your stuff. I'm not responsible if something breaks or your files go poof.

---

##  Features

- Toggle scrcpy window on/off like a second monitor
- Launch common apps (YouTube, Chrome, Spotify, etc.)
- Keeps scrcpy on top
- Hides window by minimizing/offscreening
- Smart restore with window position & z-index
- Super Linux-y with xdotool + wmctrl + bash wizardry

---

##  Installation

1. Download **scrcpy** binaries  
   Go to: https://github.com/Genymobile/scrcpy/releases  
   Download and extract the tar file somewhere (e.g., `~/scrcpy/`)

2. Give scrcpy execute permission  
   ```bash
   chmod +x ~/scrcpy/scrcpy
   ```

3. ✅ Fix: Set up udev rules

   Run this to create the rules file (as root):
   ```bash
   sudo nano /etc/udev/rules.d/51-android.rules
   ```

   Paste this inside (for most devices):
   ```bash
   SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="plugdev"
   ```

   Or for broader support:
   ```bash
   SUBSYSTEM=="usb", ATTR{idVendor}=="*", MODE="0666", GROUP="plugdev"
   ```

   Then run:
   ```bash
   sudo chmod a+r /etc/udev/rules.d/51-android.rules
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   ```

   Finally, unplug and replug your phone.

4. 🔁 Alternative (quick & dirty test):
   ```bash
   sudo ./scrcpy
   ```
   Just to check if it runs (not recommended long-term).

---

##  Setup This Script

1. Clone the repo  
   ```bash
   git clone https://github.com/Arinji2/adb-manager
   ```

2. Make the script executable  
   ```bash
   chmod +x adbmenu.sh
   ```

3. Edit the following variables in `adbmenu.sh`:
   ```bash
   ADB="/home/arinji/scrcpy/adb"
   SCRCPY="/home/arinji/scrcpy/scrcpy"
   AUDIO_DEVICE="bt_a2dp"
   SCRCPY_ID_FILE="/tmp/.scrcpy_hidden_window_id"
   ```

4. Run it like a command. I use Kitty:
   ```bash
   kitty --title "ADB Menu" bash -c '~/scrcpy/adbmenu.sh'
   ```

---

##  Video Demo
Made a quick video on how it works, check it out here
https://github.com/user-attachments/assets/4afcda78-ed13-4718-8eca-8c54d874ef28

---

##  Notes

- Requires Linux (tested on Linux Mint)
- Needs `xdotool`, `wmctrl`, `xclip`, and `bash`
- Android 14+ recommended with USB debugging enabled

---

## Disclaimer
I have not tested this.. its purely just me making a nice tool for my self. Use this at your own risk :D

---

##  Built by Arinji

This project was proudly built by [Arinji](https://www.arinji.com/).  
Check out my website for more cool projects!

---
