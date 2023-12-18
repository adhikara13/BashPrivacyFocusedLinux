#!/bin/bash

# Zethius 'skengman' redacted presents the 'Privacy Focused Linux'
# adhkr made the bash version of it
# This script only runs on Ubuntu-Minimal

echo "--------------------------------------------------------------------------------"
echo "PRIVACY FOCUSED LINUX"
echo $(date)
echo "--------------------------------------------------------------------------------"

# Function to clean and reboot
function aClean {
    echo "Removing..."
    sudo apt-get -y autoremove --purge
    sleep 1

    echo -e "\nCleaning..."
    sudo apt-get autoclean && sudo apt-get clean
    sleep 1

    echo "--------------------------------------------------"
    echo "YOU HAVE BEEN...PRIVATISED ( ͡° ͜ʖ ͡°)"
    echo "--------------------------------------------------"

    echo "Press Enter to reboot..."
    read
    sudo reboot
}

# Function to install privacy enhancing tools
function privInstall {
    # Various installations
    echo "Installing privacy enhancing tools..."
    sudo apt-get install -y mat secure-delete htop locate macchanger nautilus-wipe clamav clamtk keepassxc gtkhash firejail apparmor-profiles apparmor-utils fail2ban

    # Enabling AppArmor profiles
    echo -e "\nEnabling AppArmor profiles..."
    sudo aa-enforce /etc/apparmor.d/*

    # Configuring fail2ban
    echo -e "\nConfiguring fail2ban..."
    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban
    echo "[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600" | sudo tee /etc/fail2ban/jail.local > /dev/null

    aClean
}

# Function for classic Linux setup
function classicLin {
    echo "Disabling Ubuntu Dock..."
    sudo apt-get purge -y gnome-shell-extension-ubuntu-dock
    sleep 1

    privInstall
}

# Function to remove Snap and setup alternatives
function deSnap {
    # Firewall setup
    echo -e "\nSetting up Uncomplicated Firewall..."
    sudo apt-get install -y ufw
    sudo ufw enable
    sudo ufw default deny incoming
    sudo ufw default deny forward
    sudo ufw limit 22/tcp
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw reload

    echo "--------------------------------------------------------------------------------"
    echo "DESNAPING AND MAKING MORE PRIVATE"
    echo "--------------------------------------------------------------------------------"

    # Disabling Apport
    echo "Disabling Apport..."
    sleep 1
    sudo sed -i 's/enabled=1/enabled=0/g' /etc/default/apport
    echo "Done!"

    # Removing Snap
    echo "Purging Snap completely..."
    sleep 1
    sudo apt-get purge -y snapd
    echo "Done!"

    # Installing Flatpak
    echo "Installing Flatpak..."
    sleep 1
    sudo apt-get install -y flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo apt-get install -y gnome-software-plugin-flatpak
    sudo apt-get purge -y gnome-software-plugin-snap
    sudo apt-get purge -y snapd
    echo "Done!"

    # Disabling automatic updates
    echo "Disabling automatic updates..."
    sleep 1
    sudo apt-get purge -y update-notifier

    # Handling kernel modules
    echo -e "\nDo you use Nvidia drivers or the application 'virtualbox'? (Y/N)"
    read kern_mod
    if [ "$kern_mod" = "n" ] || [ "$kern_mod" = "no" ]; then
        sudo sysctl kernel.modules_disabled=1
        sudo sysctl net.ipv4.conf.all.rp_filter
    else
        echo "Kernel Modules will remain untouched."
    fi

    # Handling cups daemon
    echo -e "\nWould you like to disable the 'cups-daemon'? (Y/N)"
    read printer_question
    if [ "$printer_question" = "y" ] || [ "$printer_question" = "yes" ]; then
        sudo apt-get purge -y cups-daemon
    else
        echo "The 'cups-deamon' will remain untouched."
    fi

    # Handling avahi daemon
    echo -e "\nWould you like to disable 'avahi-deamon'? (Y/N)"
    read apple_question
    if [ "$apple_question" = "y" ] || [ "$apple_question" = "yes" ]; then
        sudo apt-get purge -y avahi-daemon
    else
        echo "The 'avahi-daemon' will remain untouched."
    fi

    # Removing Ubuntu Dock
    echo -e "\nWould you like to delete the Ubuntu Dock? (Y/N)"
    read classicLin_ques
    if [ "$classicLin_ques" = "y" ] || [ "$classicLin_ques" = "yes" ]; then
        classicLin
    else
        privInstall
    fi

    # Disabling and purging reporting packages
    echo "Disabling and purging reporting packages..."
    sleep 1
    sudo apt-get purge -y ubuntu-report popularity-contest apport apport-symptoms whoopsie
    sudo apt-mark hold avahi-daemon snapd cups-daemon update-notifier gnome-shell-extension-ubuntu-dock gnome-shell-extension-desktop-icons ubuntu-report popularity-contest apport apport-symptoms whoopsie
    echo "Done!"

    # Hardening network configuration
    echo "Hardening network config files..."
    sleep 1
    sudo sed -i 's/#net.ipv4.conf.default.rp_filter=1/net.ipv4.conf.default.rp_filter=1/g' /etc/sysctl.conf
    sudo sed -i 's/#net.ipv4.conf.all.rp_filter=1/net.ipv4.conf.all.rp_filter=1/g' /etc/sysctl.conf
    sudo sed -i 's/#net.ipv4.conf.all.accept_redirects\ \=\ \0/net.ipv4.conf.all.accept_redirects=0/g' /etc/sysctl.conf
    sudo sed -i 's/#net.ipv6.conf.all.accept_redirects\ \=\ \0/net.ipv6.conf.all.accept_redirects=0/g' /etc/sysctl.conf
    sudo sed -i 's/#net.ipv4.conf.all.send_redirects\ \=\ \0/net.ipv4.conf.all.send_redirects=0/g' /etc/sysctl.conf
    sudo sed -i 's/#net.ipv4.conf.all.accept_source_route\ \=\ \0/net.ipv4.conf.all.accept_source_route=0/g' /etc/sysctl.conf
    sudo sed -i 's/#net.ipv6.conf.all.accept_source_route\ \=\ \0/net.ipv6.conf.all.accept_source_route=0/g' /etc/sysctl.conf
    sudo sed -i 's/#net.ipv4.conf.all.log_martians\ \=\ \1/net.ipv4.conf.all.log_martians=1/g' /etc/sysctl.conf
    echo "Done!"
}

# Main program start
echo "Are you running Ubuntu-Minimal? (Y/N)"
read ques
if [ "$ques" = "y" ] || [ "$ques" = "yes" ]; then
    echo "Updating..."
    sudo apt-get -y update
    sleep 1

    echo "Upgrading..."
    sudo apt-get -y full-upgrade
    sleep 1

    deSnap
else
    echo -e "\nUnfortunately, this program was designed for Ubuntu-Minimal."
    echo "Please re-install Ubuntu for maximum privacy."
    read
fi
