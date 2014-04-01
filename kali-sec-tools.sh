#!/bin/bash
. helper.sh

security_tools(){

    if ask "Do you want to install armitage, mimikatz, unicornscan, and zenmap.. ?" Y; then
        print_status "Installing armitage, mimikatz, unicornscan, and zenmap.."
        apt-get -y install armitage mimikatz unicornscan zenmap
        success_check

        #This is a simple git pull of the Cortana .cna script repository available on github.
        print_status "Grabbing Armitage Cortana Scripts via github.."
        git clone http://www.github.com/rsmudge/cortana-scripts.git /opt/cortana
        success_check
        print_notification "Cortana scripts installed under /opt/cortana."
    fi

    if ask "Do you want to install BeEF,arachni,w3af?" Y; then
        apt-get -y install beef-xss beef-xss-bundle arachni w3af
    fi

    if ask "Do you want to install Veil?" Y; then
        git clone git://github.com/ChrisTruncer/Veil.git /usr/share/veil/
    fi

    if ask  "Do you want to install OWASP tools? (zaproxy,mantra)" Y; then
        apt-get install -y zaproxy owasp-mantra-ff
    fi

    if ask "Do you want to install OWTF?" Y; then
        git clone https://github.com/7a/owtf/ /tmp/owtf
        python /tmp/owtf/install/install.py
    fi

    # http://seclist.us/2013/12/update-watobo-v-0-9-13-semi-automated-web-application-security-audits.html
    if ask "Do you want to install WATOBO?" Y; then
        gem install watobo
    fi

    if ask "Do you want to install htshells?" Y; then
        git clone git://github.com/wireghoul/htshells.git /usr/share/htshells/
    fi

    if ask "Do you want to install the buffer-overvlow-kit? (requires ruby)" Y; then
        mkdir ~/develop
        cd ~/develop
        git clone https://github.com/KINGSABRI/BufferOverflow-Kit.git
    fi

    if ask "Do you want install mitm tools?" Y; then
        print_notification "Installing yamas.sh"
        apt-get install -y arpspoof ettercap-text-only sslstrip
        wget http://comax.fr/yamas/bt5/yamas.sh -O /usr/bin/yamas
        chmod +x /usr/bin/yamas

        print_notification "Installing parponera"
        git clone https://code.google.com/p/paraponera/ ~/develop/parponera
        cd ~/develop/parponera
        ./install.sh

        print_notification "Installing haxorblox"
        apt-get install -y hamster-sidejack ferret-sidejack dsniff gawk snarf ngrep
    fi

    if ask "Do you want to install TOR?" Y; then
        #TODO: add check if repo is already added
        echo "# tor repository" >> /etc/apt/sources.list
        echo "deb http://deb.torproject.org/torproject.org wheezy main" >> /etc/apt/sources.list

        gpg --keyserver keys.gnupg.net --recv 886DDD89
        gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
        apt-get update
        apt-get install -y deb.torproject.org-keyring tor tor-geoipdb polipo vidalia
        mv /etc/polipo/config /etc/polipo/config.orig
        wget https://gitweb.torproject.org/torbrowser.git/blob_plain/ae4aa49ad9100a50eec049d0a419fac63a84d874:/build-scripts/config/polipo.conf -O /etc/polipo/config
        service tor restart
        service polipo restart
        update-rc.d tor enable
        update-rc.d polipo enable
    fi

    if ask "Install SVN version of fuzzdb?" Y; then
        print_status "Installing SVN version of fuzzdb in /usr/share/fuzzdb and keeping it updated."
        if [ -d /usr/share/fuzzdb ]; then
            cd /usr/share/fuzzdb
            svn up
        else
            print_notification "Fuzzdb not found, installing at /usr/share/fuzzdb."
            cd /usr/share
            svn co http://fuzzdb.googlecode.com/svn/trunk fuzzdb
        fi
        print_good "Installed or updated Fuzzdb to /usr/share/fuzzdb."
    fi

    if ask "Install SVN version of nmap?" N; then
        print_status "Adding nmap-svn to /opt/nmap-svn."
        svn co --username guest --password "" https://svn.nmap.org/nmap /opt/nmap-svn
        cd /opt/nmap-svn
        ./configure && make
        /opt/nmap-svn/nmap -V
        print_good "Installed or updated nmap-svn to /opt/nmap-svn."
    fi

    if ask "Install SVN version of aircrack-ng?" N; then
        if [ -d /opt/aircrack-ng-svn ]; then
            cd /opt/aircrack-ng-svn
            svn up
        else
            svn co http://svn.aircrack-ng.org/trunk/ /opt/aircrack-ng-svn
            cd /opt/aircrack-ng-svn
        fi
        make && make install
        airodump-ng-oui-update
        print_good "Downloaded svn version of aircrack-ng to /opt/aircrack-ng-svn and overwrote package with it."
    fi

    if ask "Install freeradius server 2.1.11 with WPE patch?" N; then
        #Checking for free-radius and it not found installing it with the wpe patch.  This code is totally stollen from the easy-creds install file.  :-D
        if [ ! -e /usr/bin/radiusd ] && [ ! -e /usr/sbin/radiusd ] && [ ! -e /usr/local/sbin/radiusd ] && [ ! -e /usr/local/bin/radiusd ]; then
            print_notification "Free-radius is not installed, will attempt to install..."

            mkdir /tmp/freeradius
            print_notification "Downloading freeradius server 2.1.11 and the wpe patch..."
            wget ftp://ftp.freeradius.org/pub/radius/old/freeradius-server-2.1.11.tar.bz2 -O /tmp/freeradius/freeradius-server-2.1.11.tar.bz2
            wget http://www.opensecurityresearch.com/files/freeradius-wpe-2.1.11.patch -O /tmp/freeradius/freeradius-wpe-2.1.11.patch
            cd /tmp/freeradius
            tar -jxvf freeradius-server-2.1.11.tar.bz2
            mv freeradius-wpe-2.1.11.patch /tmp/ec-install/freeradius-server-2.1.11/freeradius-wpe-2.1.11.patch
            cd freeradius-server-2.1.11
            patch -p1 < freeradius-wpe-2.1.11.patch
            print_notification "Installing the patched freeradius server..."

            ./configure && make && make install
            cd /usr/local/etc/raddb/certs/
            ./bootstrap
            rm -r /tmp/freeradius
            print_good "The patched freeradius server has been installed"
        else
            print_good "I found free-radius installed on your system"
        fi
    fi

    if ask "Install easy-creds?" Y; then
        #Installing easy-creds.  The needed packages should be taken care of in the extra packages section.
        if [ -d /opt/easy-creds ]; then
            echo "Easy easy-creds install already found."
        else
            git clone git://github.com/brav0hax/easy-creds.git /opt/easy-creds
            ln -s /opt/easy-creds/easy-creds.sh /usr/bin/easy-creds
        fi
        updatedb
        echo -e "If easy-creds was not found it was installed."
    fi

    #TODO: add Nessus installation
    if ask "Install unsploitable?" N; then
        print_status "Pulling Unsploitable.."
        mkdir /opt/other-tools
        cd /opt/other-tools
        svn checkout svn://svn.code.sf.net/p/unsploitable/code/trunk unsploitable
        success_check
        print_notification "Unsploitable installed to /opt/other-tools/unsploitable"
    fi

    if ask "Pulling DTFTB (Defense Tools for the Blind)?" N; then
        print_status "The DTFTB scripts are a set of tools that are CTF oriented."
        svn checkout svn://svn.code.sf.net/p/dtftb/code/trunk dtftb
        success_check
        print_notification "DTFTB installed to /opt/other-tools/dtftb"
    fi

    if ask "Do you want to install stand-alone smbexec tool from brav0hax's github. (180mb of data)" N; then
        print_status "Pulling SMBexec. It's going to take a bit of time."
        git clone https://github.com/brav0hax/smbexec.git /opt/other-tools/smbexec-source
        success_check
        cd /opt/other-tools/smbexec-source

        #The script has to be ran twice. The first time, the script grabs the prereqs, etc required to compile smbexec
        print_status "Performing Installation pre-reqs."
        print_notification "The installation is scripted. When prompted for what OS you are using choose Debian or Ubuntu variant."
        print_notification "When prompted for where to install smbexec, select /opt/other-tools/smbexec-source"
        print_notification "Select option 5 to exit, if prompted."
        read -p "You'll have to run the installer twice. The script immediately bails after installing pre-reqs. Hit enter to continue." pause
        bash install.sh
        success_check

        #The second time around, it compiles smbexec, actually installing it.
        print_status "Re-running installer."
        print_notification "We have to re-run the installer. The first run verifies you have the right pre-reqs available and installs them."
        print_notification "This time, select option 4 to compile smbexec."
        print_notification "Like all good things compiled from source, be patient; this'll take a moment or two."
        read -p "Select option 5 to exit, post-compile, if prompted. Hit enter to continue" pause
        bash install.sh
        success_check
        print_notification "smbexec should be installed wherever you told the installer script to install it to. That should be /opt/other-tools/smbexec-source"
    fi

    if ask "Install Kali Lazy?" Y; then
        wget -q http://yourgeekonthego.com/scripts/lazykali/lazykali.sh -O /usr/bin/lazykali
        chmod +x /usr/bin/lazykali
        lazykali
    fi
}


check_euid
security_tools