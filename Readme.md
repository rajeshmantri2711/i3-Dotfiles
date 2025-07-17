# i3-Dotfiles Setup Script

A custom i3 window manager setup designed for a clean and productive environment.

---

## Important Notes

-  **Supported Systems:** This script currently supports **Debian-based distributions** only:
  - Linux Mint (Cinnamon)
  - Ubuntu
  - Kali Linux
-  **Arch Linux support** is planned and will be added soon.
-  **Do not install Picom inside a virtual machine (VM)** — it may cause lag, unresponsiveness, or graphics issues due to limited GPU passthrough. If you're running this on **bare metal**, Picom will work as intended.

---

##  Try Without Picom

If you'd like to test the setup **without Picom**, run:

```bash
curl -SL https://raw.githubusercontent.com/i-am-paradoxx/i3-Dotfiles/main/install_without_picom.sh | bash
```

---

##  Installation on Debian-Based Systems

To install the full i3 setup (with Picom and all configurations):

```bash
curl -SL https://raw.githubusercontent.com/i-am-paradoxx/i3-Dotfiles/main/install.sh | bash
```

This will:
- Set up i3 window manager
- Install Polybar, Rofi, and other utilities
- Apply custom keybindings and layouts
- Configure terminal, wallpaper, fonts, and more

---

##  About This Project

This dotfiles setup is built from the ground up with inspiration from several community ricing setups.

> **Disclaimer:**  
> This is not entirely original work — it’s a collection and customization of many great dotfiles shared by the Linux community. Credit goes to all those creators whose ideas inspired this configuration.  
> Feel free to use or modify this setup — just consider mentioning this repository if you do. Thank you!
