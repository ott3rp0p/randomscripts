#!/bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Run this as root"
    exit
fi
while true; do
    read -p "Are you sure you want to install all tools into /opt? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

installTools(){
    git clone https://github.com/Tib3rius/AutoRecon.git /opt/
    git clone https://github.com/BloodHoundAD/Bloodhound.git /opt/
    git clone https://github.com/ReFirmLabs/binwalk.git /opt/
    git clone https://github.com/jpillora/chisel.git /opt/
    git clone https://github.com/TheWover/donut.git /opt/
    git clone https://github.com/EmpireProject/Empire.git /opt/
    git clone https://github.com/NationalSecurityAgency/ghidra.git /opt/
    git clone https://github.com/r3motecontrol/Ghostpack-CompiledBinaries.git /opt/
    git clone https://github.com/arthaud/git-dumper.git /opt/
    git clone https://github.com/nidem/kerberoast.git /opt/
    git clone https://github.com/mbechler/marshalsec /opt/
    git clone https://github.com/ParrotSec/mimikatz.git /opt/
    git clone https://github.com/H74N/netcat-binaries.git /opt/
    git clone https://github.com/opsec-infosec/nmap-static-binaries.git /opt/
    git clone https://github.com/carlospolop/PEASS-ng.git /opt/
    git clone https://github.com/besimorhino/powercat /opt/
    git clone https://github.com/PowerShellMafia/PowerSploit.git /opt/
    git clone https://github.com/DominicBreuker/pspy.git /opt/
    git clone https://github.com/ly4k/PwnKit.git /opt/
    git clone https://github.com/GhostPack/SharpUp.git /opt/
    git clone https://github.com/sshuttle/sshuttle.git /opt/
    git clone https://github.com/frohoff/ysoserial /opt/

}