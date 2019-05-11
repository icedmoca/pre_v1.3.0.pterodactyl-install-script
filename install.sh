#!/bin/bash
#llynGq6k97xPD0aumF3mDrPoat3tuTpvF25k0FxY

output(){
    echo -e '\e[36m'$1'\e[0m';
}

warn(){
    echo -e '\e[31m'$1'\e[0m';
}

get_virtualization(){
    output "Automatic Virtualization Detection initialized."
    if [ "$lsb_dist" =  "ubuntu" ]; then
        apt-get update --fix-missing
        apt-get -y install software-properties-common
        add-apt-repository -y universe
        apt-get -y install virt-what
    elif [ "$lsb_dist" =  "debian" ]; then
        apt update --fix-missing
        apt-get -y install software-properties-common
        apt-get -y install virt-what
    elif [ "$lsb_dist" =  "fedora" ] || [ "$lsb_dist" =  "centos" ] || [ "$lsb_dist" =  "rhel" ]; then
        yum -y install virt-what
    fi
    virt_serv=$(echo $(virt-what))
    if [ "$virt_serv" = "" ]; then
        output "Virtualization: Bare Metal detected."
    elif [ "$virt_serv" = "openvz lxc" ]; then
        output "Virtualization: OpenVZ 7 detected."
    else
        output "Virtualization: $virt_serv detected."
    fi
    output ""
    if [ "$virt_serv" != "" ] && [ "$virt_serv" != "kvm" ] && [ "$virt_serv" != "vmware" ] && [ "$virt_serv" != "hyperv" ] && [ "$virt_serv" != "openvz lxc" ]; then
        warn "Unsupported Virtualization method. Please consult with your provider whether your server can run Docker or not. Proceed at your own risk."
        warn "No support would be given if your server breaks at any point in the future."
        warn "Proceed?\n[1] Yes.\n[2] No."
        read choice
        case $choice in 
            1)  output "Proceeding..."
                ;;
            2)  output "Cancelling installation..."
                exit 5
                ;;
        esac
        output ""
    fi

    output "Kernel Detection Initialized."
    if echo $(uname -r) | grep -q xxxx; then
        output "OVH Kernel Detected. The script will not work. Please install your server with a generic/distribution kernel."
        exit 6
    elif echo $(uname -r) | grep -q pve; then
        output "Proxmox LXE Kernel Detected. You have chosen to continue in the last step, therefore we are proceeding at your own risk."
        output "Proceeding with a risky operation..."
    elif echo $(uname -r) | grep -q stab; then
        if echo $(uname -r) | grep -q 2.6; then 
            output "OpenVZ 6 detected. This server will definitely not work with Docker, regardless of what your provider might say. Exiting to avoid further damages."
            exit 6
        fi
    elif echo $(uname -r) | grep -q lve; then
        output "CloudLinux Kernel detected. Docker is not supported on CloudLinux. The script will exit to avoid further damages."
        exit 6
    elif echo $(uname -r) | grep -q Microsoft; then
        output "Windows Subsystem for Linux detected. Docker is not supported on this system. The script will exit to avoid further damages."
        exit 6
    elif echo $(uname -r) | grep -q gcp; then
        output "Google Cloud Platform Detected. Good to go."
    else
        output "Did not detect any bad kernel. Moving forward."
    fi
}

webserver_options() {
    output "Please select which web server you would like to use:\n[1] Nginx (Recommended).\n[2] Apache2/Httpd."
    read choice
    case $choice in
        1 ) webserver=1
            output "You have selected Nginx."
            output ""
            ;;
        2 ) webserver=2
            output "You have selected Apache2 / Httpd."
            output ""
            ;;
        * ) output "You did not enter a valid selection."
            webserver_options
    esac
}

theme_options() {
    output "Would you like to install Fonix's themes?"
    output "[1] No."
    output "[2] Tango Twist."
    output "[3] Blue Brick."
    output "[4] Minecraft Madness."
    output "[5] Lime Stitch."
    output "[6] Red Ape."
    output "[7] BlackEnd Space."
    output "[8] Nothing But Graphite."
    output ""
    output "You can find out about Fonix's themes here: https://github.com/TheFonix/Pterodactyl-Themes"
    read choice
    case $choice in
        1 ) themeoption=1
            output "You have selected to install vanilla Pterodactyl theme."
            output ""
            ;;
        2 ) themeoption=2
            output "You have selected to install Fonix's Tango Twist theme."
            output ""
            ;;
        3 ) themeoption=3
            output "You have selected to install Fonix's Blue Brick theme."
            output ""
            ;;
        4 ) themeoption=4
            output "You have selected to install Fonix's Minecraft Madness theme."
            output ""
            ;;
        5 ) themeoption=5
            output "You have selected to install Fonix's Lime Stitch theme."
            output ""
            ;;
        6 ) themeoption=6
            output "You have selected to install Fonix's Red Ape theme."
            output ""
            ;;
        7 ) themeoption=7
            output "You have selected to install Fonix's BlackEnd Space theme."
            output ""
            ;;
        8 ) themeoption=8
            output "You have selected to install Fonix's Nothing But Graphite theme."
            output ""
            ;;        
        * ) output "You did not enter a a valid selection"
            theme_options
    esac
}   

required_infos() {
    output "Please enter the desired user email address:"
    read email
    dns_check
}

dns_check(){
    output "Please enter your FQDN (panel.yourdomain.com):"
    read FQDN

    output "Resolving DNS."
    SERVER_IP=$(curl -s http://checkip.amazonaws.com)
    DOMAIN_RECORD=$(dig +short ${FQDN})
    if [ "${SERVER_IP}" != "${DOMAIN_RECORD}" ]; then
        output ""
        output "The entered domain does not resolve to the primary public IP of this server."
        output "Please make an A record pointing to your server's ip. For example, if you make an A record called 'panel' pointing to your server's ip, your FQDN is panel.yourdomain.tld"
        output "If you are using Cloudflare, please disable the orange cloud."
        output "If you do not have a domain, you can get a free one at https://www.freenom.com/en/index.html?lang=en."
        dns_check
    else 
        output "Domain resolved correctly. Good to go."
    fi
}

theme() {
    output "Theme installation initialized."
    cd /var/www/pterodactyl
    if [ "$themeoption" = "1" ]; then
        output "Keeping Pterodactyl's vanilla theme."
    elif [ "$themeoption" = "2" ]; then
        curl https://raw.githubusercontent.com/TheFonix/Pterodactyl-Themes/master/MasterThemes/TangoTwist/build.sh | sh
    elif [ "$themeoption" = "3" ]; then
        curl https://raw.githubusercontent.com/TheFonix/Pterodactyl-Themes/master/MasterThemes/BlueBrick/build.sh | sh
    elif [ "$themeoption" = "4" ]; then
        curl https://raw.githubusercontent.com/TheFonix/Pterodactyl-Themes/master/MasterThemes/MinecraftMadness/build.sh | sh 
    elif [ "$themeoption" = "5" ]; then
        curl https://raw.githubusercontent.com/TheFonix/Pterodactyl-Themes/master/MasterThemes/LimeStitch/build.sh | sh
    elif [ "$themeoption" = "6" ]; then
        curl https://raw.githubusercontent.com/TheFonix/Pterodactyl-Themes/master/MasterThemes/RedApe/build.sh | sh
    elif [ "$themeoption" = "7" ]; then
        curl https://raw.githubusercontent.com/TheFonix/Pterodactyl-Themes/master/MasterThemes/BlackEndSpace/build.sh | sh
    elif [ "$themeoption" = "8" ]; then
        curl https://raw.githubusercontent.com/TheFonix/Pterodactyl-Themes/master/MasterThemes/NothingButGraphite/build.sh | sh
    fi
    php artisan view:clear
    php artisan cache:clear
}

repositories_setup(){
    output "Configuring your repositories."
    if [ "$lsb_dist" =  "ubuntu" ] || [ "$lsb_dist" =  "debian" ]; then
        apt-get -y install sudo
        apt-get -y install software-properties-common
        echo 'Acquire::ForceIPv4 "true";' | sudo tee /etc/apt/apt.conf.d/99force-ipv4
        apt-get -y update 
        if [ "$lsb_dist" =  "ubuntu" ]; then
            LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
            add-apt-repository -y ppa:chris-lea/redis-server
            add-apt-repository -y ppa:certbot/certbot
            add-apt-repository ppa:nginx/development
            if [ "$dist_version" = "18.10" ]; then
                apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
                add-apt-repository 'deb [arch=amd64] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.3/ubuntu cosmic main'
            elif [ "$dist_version" = "18.04" ]; then
                apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
                add-apt-repository -y 'deb [arch=amd64,arm64,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.3/ubuntu bionic main'
            elif [ "$dist_version" = "16.04" ]; then
                apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
                add-apt-repository 'deb [arch=amd64,arm64,i386,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.3/ubuntu xenial main'       
            fi
        elif [ "$lsb_dist" =  "debian" ]; then
            apt-get -y install ca-certificates apt-transport-https
            if [ "$dist_version" = "9" ]; then
                apt-get install -y software-properties-common dirmngr
                wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -
                sudo echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list
                sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
                sudo add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.3/debian stretch main'
            elif [ "$dist_version" = "8" ]; then
                wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -
                echo "deb https://packages.sury.org/php/ jessie main" | sudo tee /etc/apt/sources.list.d/php.list
                apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
                add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.3/debian jessie main'
            fi
        fi
        apt-get -y update 
        apt-get -y upgrade
        apt-get -y autoremove
        apt-get -y autoclean   
        apt-get -y install dnsutils curl
    elif  [ "$lsb_dist" =  "fedora" ] || [ "$lsb_dist" =  "centos" ] || [ "$lsb_dist" =  "rhel" ]; then
        if  [ "$lsb_dist" =  "fedora" ] && [ "$dist_version" = "29" ]; then

            bash -c 'cat > /etc/yum.repos.d/mariadb.repo' <<-'EOF'
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.3/fedora29-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

            bash -c 'cat > /etc/yum.repos.d/nginx.repo' <<-'EOF'
[heffer-nginx-mainline]
name=Copr repo for nginx-mainline owned by heffer
baseurl=https://copr-be.cloud.fedoraproject.org/results/heffer/nginx-mainline/fedora-$releasever-$basearch/
type=rpm-md
skip_if_unavailable=True
gpgcheck=1
gpgkey=https://copr-be.cloud.fedoraproject.org/results/heffer/nginx-mainline/pubkey.gpg
repo_gpgcheck=0
enabled=1
enabled_metadata=1
EOF
        elif  [ "$lsb_dist" =  "fedora" ] && [ "$dist_version" = "28" ]; then

            bash -c 'cat > /etc/yum.repos.d/mariadb.repo' <<-'EOF'
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.3/fedora28-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

            bash -c 'cat > /etc/yum.repos.d/nginx.repo' <<-'EOF'
[heffer-nginx-mainline]
name=Copr repo for nginx-mainline owned by heffer
baseurl=https://copr-be.cloud.fedoraproject.org/results/heffer/nginx-mainline/fedora-$releasever-$basearch/
type=rpm-md
skip_if_unavailable=True
gpgcheck=1
gpgkey=https://copr-be.cloud.fedoraproject.org/results/heffer/nginx-mainline/pubkey.gpg
repo_gpgcheck=0
enabled=1
enabled_metadata=1
EOF

        elif  [ "$lsb_dist" =  "centos" ] && [ "$dist_version" = "7" ]; then

            bash -c 'cat > /etc/yum.repos.d/mariadb.repo' <<-'EOF'
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.3/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

            bash -c 'cat > /etc/yum.repos.d/nginx.repo' <<-'EOF'
[heffer-nginx-mainline]
name=Copr repo for nginx-mainline owned by heffer
baseurl=https://copr-be.cloud.fedoraproject.org/results/heffer/nginx-mainline/epel-7-$basearch/
type=rpm-md
skip_if_unavailable=True
gpgcheck=1
gpgkey=https://copr-be.cloud.fedoraproject.org/results/heffer/nginx-mainline/pubkey.gpg
repo_gpgcheck=0
enabled=1
enabled_metadata=1
EOF

            yum -y install epel-release
            yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
        elif  [ "$lsb_dist" =  "rhel" ]; then
            
            bash -c 'cat > /etc/yum.repos.d/mariadb.repo' <<-'EOF'        
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.3/rhel7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

            bash -c 'cat > /etc/yum.repos.d/nginx.repo' <<-'EOF'
[heffer-nginx-mainline]
name=Copr repo for nginx-mainline owned by heffer
baseurl=https://copr-be.cloud.fedoraproject.org/results/heffer/nginx-mainline/epel-7-$basearch/
type=rpm-md
skip_if_unavailable=True
gpgcheck=1
gpgkey=https://copr-be.cloud.fedoraproject.org/results/heffer/nginx-mainline/pubkey.gpg
repo_gpgcheck=0
enabled=1
enabled_metadata=1
EOF
            yum -y install epel-release
            yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
        fi
        yum -y install yum-utils
        yum-config-manager --enable remi-php72
        yum -y upgrade
        yum -y autoremove
        yum -y clean packages
        yum -y install curl bind-utils
    fi
}

install_dependencies(){
    output "Installing dependencies."
    if  [ "$lsb_dist" =  "ubuntu" ] ||  [ "$lsb_dist" =  "debian" ]; then
        if [ "$webserver" = "1" ]; then
            apt-get -y install php7.2 php7.2-cli php7.2-gd php7.2-mysql php7.2-pdo php7.2-mbstring php7.2-tokenizer php7.2-bcmath php7.2-xml php7.2-fpm php7.2-curl php7.2-zip curl tar unzip git redis-server nginx git wget expect
        elif [ "$webserver" = "2" ]; then
            apt-get -y install php7.2 php7.2-cli php7.2-gd php7.2-mysql php7.2-pdo php7.2-mbstring php7.2-tokenizer php7.2-bcmath php7.2-xml php7.2-fpm php7.2-curl php7.2-zip curl tar unzip git redis-server apache2 libapache2-mod-php7.2 redis-server git wget expect
        fi
        sh -c "DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server"
    elif [ "$lsb_dist" =  "fedora" ] ||  [ "$lsb_dist" =  "centos" ] ||  [ "$lsb_dist" =  "rhel" ]; then
        if [ "$webserver" = "1" ]; then
            yum -y install php php-common php-fpm php-cli php-json php-mysqlnd php-mcrypt php-gd php-mbstring php-pdo php-zip php-bcmath php-dom php-opcache mariadb-server redis nginx git policycoreutils-python-utils libsemanage-devel unzip wget expect
        elif [ "$webserver" = "2" ]; then
            yum -y install php php-common php-fpm php-cli php-json php-mysqlnd php-mcrypt php-gd php-mbstring php-pdo php-zip php-bcmath php-dom php-opcache mariadb-server redis httpd git policycoreutils-python-utils libsemanage-devel mod_ssl unzip wget expect
        fi
    fi

    output "Enabling Services."
    if [ "$lsb_dist" =  "ubuntu" ] || [ "$lsb_dist" =  "debian" ]; then
        systemctl enable redis-server
        service redis-server start
        systemctl enable php7.2-fpm
        service php7.2-fpm start
    elif [ "$lsb_dist" =  "fedora" ] || [ "$lsb_dist" =  "centos" ] || [ "$lsb_dist" =  "rhel" ]; then
        systemctl enable redis
        service redis start
        systemctl enable php-fpm
        service php-fpm start
    fi
    
    systemctl enable cron
    systemctl enable mariadb

    if [ "$webserver" = "1" ]; then
        systemctl enable nginx
        service nginx start
    elif [ "$webserver" = "2" ]; then
        if [ "$lsb_dist" =  "ubuntu" ] || [ "$lsb_dist" =  "debian" ]; then
            systemctl enable apache2
            service apache2 start
        elif [ "$lsb_dist" =  "fedora" ] || [ "$lsb_dist" =  "centos" ] || [ "$lsb_dist" =  "rhel" ]; then
            systemctl enable httpd
            service httpd start
        fi
    fi
    service cron start
    service mariadb start
}

install_pterodactyl() {
    output "Creating the databases and setting root password."
    password=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
    adminpassword=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
    rootpassword=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
    Q0="DROP DATABASE IF EXISTS test;"
    Q1="CREATE DATABASE IF NOT EXISTS panel;"
    Q2="GRANT ALL ON panel.* TO 'pterodactyl'@'127.0.0.1' IDENTIFIED BY '$password';"
    Q3="GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX, DROP, EXECUTE, PROCESS, RELOAD, CREATE USER ON *.* TO 'admin'@'$SERVER_IP' IDENTIFIED BY '$adminpassword' WITH GRANT OPTION;"
    Q4="SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$rootpassword');"
    Q5="SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('$rootpassword');"
    Q6="SET PASSWORD FOR 'root'@'::1' = PASSWORD('$rootpassword');"
    Q7="DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    Q8="DELETE FROM mysql.user WHERE User='';"
    Q9="DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';"
    Q10="FLUSH PRIVILEGES;"
    SQL="${Q0}${Q1}${Q2}${Q3}${Q4}${Q5}${Q6}${Q7}${Q8}${Q9}${Q10}"
    mysql -u root -e "$SQL"

    output "Binding MariaDB to 0.0.0.0."
	if [ -f /etc/mysql/my.cnf ] ; then
        sed -i -- 's/bind-address/# bind-address/g' /etc/mysql/my.cnf
		sed -i '/\[mysqld\]/a bind-address = 0.0.0.0' /etc/mysql/my.cnf
		output 'Restarting MySQL process...'
		service mariadb restart
	elif [ -f /etc/my.cnf ] ; then
        sed -i -- 's/bind-address/# bind-address/g' /etc/my.cnf
		sed -i '/\[mysqld\]/a bind-address = 0.0.0.0' /etc/my.cnf
		output 'Restarting MySQL process...'
		service mariadb restart
	else 
		output 'File my.cnf was not found! Please contact support.'
	fi
    
    output "Downloading Pterodactyl."
    mkdir -p /var/www/pterodactyl
    cd /var/www/pterodactyl
    curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/download/v0.7.13/panel.tar.gz
    tar --strip-components=1 -xzvf panel.tar.gz
    chmod -R 755 storage/* bootstrap/cache/

    output "Installing Pterodactyl."
    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
    cp .env.example .env
    if [ "$lsb_dist" =  "rhel" ]; then
        yum -y install composer
        composer update
    else
        composer install --no-dev --optimize-autoloader
    fi
    php artisan key:generate --force
    php artisan p:environment:setup -n --author=$email --url=https://$FQDN --timezone=America/New_York --cache=redis --session=database --queue=redis --redis-host=127.0.0.1 --redis-pass= --redis-port=6379
    php artisan p:environment:database --host=127.0.0.1 --port=3306 --database=panel --username=pterodactyl --password=$password
    output "To use PHP's internal mail sending, select [mail]. To use a custom SMTP server, select [smtp]. TLS Encryption is recommended."
    php artisan p:environment:mail
    php artisan migrate --seed --force
    php artisan p:user:make --email=$email --admin=1
    if  [ "$lsb_dist" =  "ubuntu" ] || [ "$lsb_dist" =  "debian" ]; then
        chown -R www-data:www-data * /var/www/pterodactyl
    elif  [ "$lsb_dist" =  "fedora" ] || [ "$lsb_dist" =  "centos" ] || [ "$lsb_dist" =  "rhel" ]; then
        if [ "$webserver" = "1" ]; then
            chown -R nginx:nginx * /var/www/pterodactyl
        elif [ "$webserver" = "2" ]; then
            chown -R apache:apache * /var/www/pterodactyl
        fi
	    semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/pterodactyl/storage(/.*)?"
        restorecon -R /var/www/pterodactyl
    fi

    output "Creating panel queue listeners"
    (crontab -l ; echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1")| crontab -
    service cron restart

    if  [ "$lsb_dist" =  "ubuntu" ] ||  [ "$lsb_dist" =  "debian" ]; then
        cat > /etc/systemd/system/pteroq.service <<- 'EOF'
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3

[Install]
WantedBy=multi-user.target
EOF
    elif  [ "$lsb_dist" =  "fedora" ] ||  [ "$lsb_dist" =  "centos" ] ||  [ "$lsb_dist" =  "rhel" ]; then
        if [ "$webserver" = "1" ]; then
            cat > /etc/systemd/system/pteroq.service <<- 'EOF'
Description=Pterodactyl Queue Worker
After=redis-server.service

[Service]
User=nginx
Group=nginx
Restart=always
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3

[Install]
WantedBy=multi-user.target
EOF
        elif [ "$webserver" = "2" ]; then
            cat > /etc/systemd/system/pteroq.service <<- 'EOF'
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service

[Service]
User=apache
Group=apache
Restart=always
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3

[Install]
WantedBy=multi-user.target
EOF
        fi
    fi
    sudo systemctl daemon-reload
    systemctl enable pteroq.service
    systemctl start pteroq
}

upgrade_pterodactyl(){
    cd /var/www/pterodactyl
    php artisan down
    curl -L https://github.com/pterodactyl/panel/releases/download/v0.7.13/panel.tar.gz | tar --strip-components=1 -xzv
    unzip panel
    chmod -R 755 storage/* bootstrap/cache
    composer install --no-dev --optimize-autoloader
    php artisan view:clear
    php artisan migrate --force
    php artisan db:seed --force
    chown -R www-data:www-data * /var/www/pterodactyl
    if [ "$lsb_dist" =  "fedora" ] || [ "$lsb_dist" =  "centos" ] || [ "$lsb_dist" =  "rhel" ]; then
        chown -R apache:apache * /var/www/pterodactyl
        chown -R nginx:nginx * /var/www/pterodactyl
        semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/pterodactyl/storage(/.*)?"
        restorecon -R /var/www/pterodactyl
    fi
    output "Your panel has been updated to version 0.7.13."
    php artisan up
    php artisan queue:restart
}

nginx_config() {
    output "Disabling default configuration"
    rm -rf /etc/nginx/sites-enabled/default
    output "Configuring Nginx Webserver"
    
echo '
server_tokens off;

set_real_ip_from 103.21.244.0/22;
set_real_ip_from 103.22.200.0/22;
set_real_ip_from 103.31.4.0/22;
set_real_ip_from 104.16.0.0/12;
set_real_ip_from 108.162.192.0/18;
set_real_ip_from 131.0.72.0/22;
set_real_ip_from 141.101.64.0/18;
set_real_ip_from 162.158.0.0/15;
set_real_ip_from 172.64.0.0/13;
set_real_ip_from 173.245.48.0/20;
set_real_ip_from 188.114.96.0/20;
set_real_ip_from 190.93.240.0/20;
set_real_ip_from 197.234.240.0/22;
set_real_ip_from 198.41.128.0/17;
set_real_ip_from 2400:cb00::/32;
set_real_ip_from 2606:4700::/32;
set_real_ip_from 2803:f800::/32;
set_real_ip_from 2405:b500::/32;
set_real_ip_from 2405:8100::/32;
set_real_ip_from 2c0f:f248::/32;
set_real_ip_from 2a06:98c0::/29;

real_ip_header X-Forwarded-For;

server {
    listen 80;
    server_name '"$FQDN"';
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name '"$FQDN"';

    root /var/www/pterodactyl/public;
    index index.php;

    access_log /var/log/nginx/pterodactyl.app-access.log;
    error_log  /var/log/nginx/pterodactyl.app-error.log error;

    # allow larger file uploads and longer script runtimes
    client_max_body_size 100m;
    client_body_timeout 120s;

    sendfile off;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/'"$FQDN"'/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/'"$FQDN"'/privkey.pem;
    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2;
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256';
    ssl_prefer_server_ciphers on;

    # See https://hstspreload.org/ before uncommenting the line below.
    # add_header Strict-Transport-Security "max-age=15768000; preload;";
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag none;
    add_header Content-Security-Policy "frame-ancestors 'self'";
    add_header X-Frame-Options DENY;
    add_header Referrer-Policy same-origin;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
        include /etc/nginx/fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
' | sudo -E tee /etc/nginx/sites-available/pterodactyl.conf >/dev/null 2>&1

    ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf
    service nginx restart
}

apache_config() {
    output "Disabling default configuration"
    rm -rf /etc/nginx/sites-enabled/default
    output "Configuring Apache2"
echo '
<VirtualHost *:80>
  ServerName '"$FQDN"'
  RewriteEngine On
  RewriteCond %{HTTPS} !=on
  RewriteRule ^/?(.*) https://%{SERVER_NAME}/$1 [R,L] 
</VirtualHost>

<VirtualHost *:443>
  ServerName '"$FQDN"'
  DocumentRoot "/var/www/pterodactyl/public"
  AllowEncodedSlashes On
  php_value upload_max_filesize 100M
  php_value post_max_size 100M
  <Directory "/var/www/pterodactyl/public">
    AllowOverride all
  </Directory>
  SSLEngine on
  SSLCertificateFile /etc/letsencrypt/live/'"$FQDN"'/fullchain.pem
  SSLCertificateKeyFile /etc/letsencrypt/live/'"$FQDN"'/privkey.pem
</VirtualHost> 


' | sudo -E tee /etc/apache2/sites-available/pterodactyl.conf >/dev/null 2>&1
    
    ln -s /etc/apache2/sites-available/pterodactyl.conf /etc/apache2/sites-enabled/pterodactyl.conf
    a2enmod ssl
    a2enmod rewrite
    service apache2 restart
}

nginx_config_redhat(){
    output "Configuring Nginx Webserver"
    
echo '
server_tokens off;

set_real_ip_from 103.21.244.0/22;
set_real_ip_from 103.22.200.0/22;
set_real_ip_from 103.31.4.0/22;
set_real_ip_from 104.16.0.0/12;
set_real_ip_from 108.162.192.0/18;
set_real_ip_from 131.0.72.0/22;
set_real_ip_from 141.101.64.0/18;
set_real_ip_from 162.158.0.0/15;
set_real_ip_from 172.64.0.0/13;
set_real_ip_from 173.245.48.0/20;
set_real_ip_from 188.114.96.0/20;
set_real_ip_from 190.93.240.0/20;
set_real_ip_from 197.234.240.0/22;
set_real_ip_from 198.41.128.0/17;
set_real_ip_from 2400:cb00::/32;
set_real_ip_from 2606:4700::/32;
set_real_ip_from 2803:f800::/32;
set_real_ip_from 2405:b500::/32;
set_real_ip_from 2405:8100::/32;
set_real_ip_from 2c0f:f248::/32;
set_real_ip_from 2a06:98c0::/29;

real_ip_header X-Forwarded-For;
server {
    listen 80;
    server_name '"$FQDN"';
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name '"$FQDN"';

    root /var/www/pterodactyl/public;
    index index.php;

    access_log /var/log/nginx/pterodactyl.app-access.log;
    error_log  /var/log/nginx/pterodactyl.app-error.log error;

    # allow larger file uploads and longer script runtimes
    client_max_body_size 100m;
    client_body_timeout 120s;
    
    sendfile off;

    # strengthen ssl security
    ssl_certificate /etc/letsencrypt/live/'"$FQDN"'/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/'"$FQDN"'/privkey.pem;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:ECDHE-RSA-AES128-GCM-SHA256:AES256+EECDH:DHE-RSA-AES128-GCM-SHA256:AES256+EDH:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";
    
    # See the link below for more SSL information:
    #     https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
    #
    # ssl_dhparam /etc/ssl/certs/dhparam.pem;

    # Add headers to serve security related headers
    add_header Strict-Transport-Security "max-age=15768000; preload;";
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag none;
    add_header Content-Security-Policy "frame-ancestors 'self'";

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php-fpm/pterodactyl.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
        include /etc/nginx/fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
' | sudo -E tee /etc/nginx/conf.d/pterodactyl.conf >/dev/null 2>&1

    service nginx restart
    chown -R nginx:nginx $(pwd)
    semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/pterodactyl/storage(/.*)?"
    restorecon -R /var/www/pterodactyl
}

apache_config_redhat() {
    output "Configuring Apache2"
echo '
<VirtualHost *:80>
  ServerName '"$FQDN"'
  RewriteEngine On
  RewriteCond %{HTTPS} !=on
  RewriteRule ^/?(.*) https://%{SERVER_NAME}/$1 [R,L] 
</VirtualHost>
<VirtualHost *:443>
  ServerName '"$FQDN"'
  DocumentRoot "/var/www/pterodactyl/public"
  AllowEncodedSlashes On
  <Directory "/var/www/pterodactyl/public">
    AllowOverride all
  </Directory>
  SSLEngine on
  SSLCertificateFile /etc/letsencrypt/live/'"$FQDN"'/fullchain.pem
  SSLCertificateKeyFile /etc/letsencrypt/live/'"$FQDN"'/privkey.pem
</VirtualHost> 

' | sudo -E tee /etc/httpd/conf.d/pterodactyl.conf >/dev/null 2>&1
    service httpd restart
}

php_config(){
    output "Configuring PHP socket."
    bash -c 'cat > /etc/php-fpm.d/www-pterodactyl.conf' <<-'EOF'
[pterodactyl]

user = nginx
group = nginx

listen = /var/run/php-fpm/pterodactyl.sock
listen.owner = nginx
listen.group = nginx
listen.mode = 0750

pm = ondemand
pm.max_children = 9
pm.process_idle_timeout = 10s
pm.max_requests = 200
EOF
    systemctl restart php-fpm
}

webserver_config(){
    if  [ "$lsb_dist" =  "ubuntu" ] || [ "$lsb_dist" =  "debian" ]; then
        if [ "$webserver" = "1" ]; then
            nginx_config
        elif [ "$webserver" = "2" ]; then
            apache_config
        fi
    elif  [ "$lsb_dist" =  "fedora" ] ||  [ "$lsb_dist" =  "centos" ] ||  [ "$lsb_dist" =  "rhel" ]; then
        if [ "$webserver" = "1" ]; then
            php_config
            nginx_config_redhat
        elif [ "$webserver" = "2" ]; then
            apache_config_redhat
        fi
    fi
}

setup_pterodactyl(){
    install_dependencies
    install_pterodactyl
    ssl_certs
    webserver_config
    theme
}

install_daemon() {
    cd /root
    output "Installing Pterodactyl Daemon dependencies."
    if  [ "$lsb_dist" =  "ubuntu" ] ||  [ "$lsb_dist" =  "debian" ]; then
        apt-get -y install curl tar unzip
    elif  [ "$lsb_dist" =  "fedora" ] ||  [ "$lsb_dist" =  "centos" ] ||  [ "$lsb_dist" =  "rhel" ]; then
        yum -y install curl tar unzip
    fi
    output "Installing Docker"
    curl -sSL https://get.docker.com/ | CHANNEL=stable bash
    systemctl enable docker
    systemctl start docker
    output "Enabling Swap support for Docker & Installing NodeJS."
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& swapaccount=1/' /etc/default/grub
    if  [ "$lsb_dist" =  "ubuntu" ] ||  [ "$lsb_dist" =  "debian" ]; then
        sudo update-grub
        curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
        apt -y install nodejs make gcc g++ node-gyp
        apt-get -y update 
        apt-get -y upgrade
        apt-get -y autoremove
        apt-get -y autoclean
    elif  [ "$lsb_dist" =  "fedora" ] ||  [ "$lsb_dist" =  "centos" ] ||  [ "$lsb_dist" =  "rhel" ]; then
        grub2-mkconfig -o "$(readlink /etc/grub2.conf)"
        curl --silent --location https://rpm.nodesource.com/setup_10.x | sudo bash -
        yum -y install nodejs gcc-c++ make
        yum -y upgrade
        yum -y autoremove
        yum -y clean packages
    fi
    output "Installing the Pterodactyl Daemon."
    mkdir -p /srv/daemon /srv/daemon-data
    cd /srv/daemon
    curl -L https://github.com/pterodactyl/daemon/releases/download/v0.6.12/daemon.tar.gz | tar --strip-components=1 -xzv
    npm install --only=production
    bash -c 'cat > /etc/systemd/system/wings.service' <<-'EOF'
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service

[Service]
User=root
#Group=some_group
WorkingDirectory=/srv/daemon
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/bin/node /srv/daemon/src/index.js
Restart=on-failure
StartLimitInterval=600

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable wings
    if [ "$lsb_dist" =  "debian" ] && [ "$dist_version" = "8" ]; then
        kernel_modifications_d8
    fi
}

upgrade_daemon(){
    cd /srv/daemon
    service wings stop
    curl -L https://github.com/pterodactyl/daemon/releases/download/v0.6.12/daemon.tar.gz | tar --strip-components=1 -xzv
    npm install -g npm
    npm install --only=production
    service wings restart
    output "Your daemon has been updated to version 0.6.12."
    output "npm has been updated to the latest version."
}

install_standalone_sftp(){
    cd /srv/daemon
    if [ $(cat /srv/daemon/config/core.json | jq -r '.sftp.enabled') == "null" ]; then
        output "Updating config to enable sftp-server."
        cat /srv/daemon/config/core.json | jq '.sftp.enabled |= false' > /tmp/core
        cat /tmp/core > /srv/daemon/config/core.json
        rm -rf /tmp/core
    elif [ $(cat /srv/daemon/config/core.json | jq -r '.sftp.enabled') == "false" ]; then
       output "Config already set up for golang sftp server."
    else 
       output "You may have purposly set the sftp to true and that will fail."
    fi
    service wings restart
    output "Installing standalone SFTP server."
    curl -Lo sftp-server https://github.com/pterodactyl/sftp-server/releases/download/v1.0.4/sftp-server
    chmod +x sftp-server
    bash -c 'cat > /etc/systemd/system/pterosftp.service' <<-'EOF'
[Unit]
Description=Pterodactyl Standalone SFTP Server
After=wings.service

[Service]
User=root
WorkingDirectory=/srv/daemon
LimitNOFILE=4096
PIDFile=/var/run/wings/sftp.pid
ExecStart=/srv/daemon/sftp-server
Restart=on-failure
StartLimitInterval=600

[Install]
WantedBy=multi-user.target
EOF
    systemctl enable pterosftp
    service pterosftp restart
}

upgrade_standalone_sftp(){
    output "Turning off the standalone SFTP server."
    service pterosftp stop
    curl -Lo sftp-server https://github.com/pterodactyl/sftp-server/releases/download/v1.0.4/sftp-server
    chmod +x sftp-server
    service pterosftp start
    output "Your standalone SFTP server has been updated to v1.0.4"
}

install_phpmyadmin(){
    output "Installing phpMyAdmin."
    cd /var/www/pterodactyl/public
    rm -rf phpmyadmin
    wget https://files.phpmyadmin.net/phpMyAdmin/4.8.5/phpMyAdmin-4.8.5-all-languages.zip
    unzip phpMyAdmin-4.8.5-all-languages
    mv phpMyAdmin-4.8.5-all-languages phpmyadmin
    rm -rf phpMyAdmin-4.8.5-all-languages.zip
    cd /var/www/pterodactyl/public/phpmyadmin

    SERVER_IP=$(curl -s http://checkip.amazonaws.com)
    BOWFISH=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 34 | head -n 1`
    bash -c 'cat > /var/www/pterodactyl/public/phpmyadmin/config.inc.php' <<EOF
<?php
/* Servers configuration */
\$i = 0;

/* Server: MariaDB [1] */
\$i++;
\$cfg['Servers'][\$i]['verbose'] = 'MariaDB';
\$cfg['Servers'][\$i]['host'] = '${SERVER_IP}';
\$cfg['Servers'][\$i]['port'] = '';
\$cfg['Servers'][\$i]['socket'] = '';
\$cfg['Servers'][\$i]['auth_type'] = 'cookie';
\$cfg['Servers'][\$i]['user'] = 'root';
\$cfg['Servers'][\$i]['password'] = '';

/* End of servers configuration */

\$cfg['blowfish_secret'] = '${BOWFISH}';
\$cfg['DefaultLang'] = 'en';
\$cfg['ServerDefault'] = 1;
\$cfg['UploadDir'] = '';
\$cfg['SaveDir'] = '';
\$cfg['CaptchaLoginPublicKey'] = 'llynGq6k97xPD0aumF3mDrPoat3tuTpvF25k0FxY';
\$cfg['CaptchaLoginPrivateKey'] = 'llynGq6k97xPD0aumF3mDrPoat3tuTpvF25k0FxY'
?>    
EOF
    output "Installation completed."
    if [ "$lsb_dist" =  "ubuntu" ] || [ "$lsb_dist" =  "debian" ]; then
        chown -R www-data:www-data * /var/www/pterodactyl
    elif [ "$lsb_dist" =  "fedora" ] || [ "$lsb_dist" =  "centos" ] ||  [ "$lsb_dist" =  "rhel" ]; then
        chown -R apache:apache * /var/www/pterodactyl
        chown -R nginx:nginx * /var/www/pterodactyl
        semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/pterodactyl/storage(/.*)?"
        restorecon -R /var/www/pterodactyl
    fi
}

kernel_modifications_d8(){
    output "Modifying Grub."
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& cgroup_enable=memory/' /etc/default/grub  
    output "Adding backport repositories." 
    echo deb http://http.debian.net/debian jessie-backports main > /etc/apt/sources.list.d/jessie-backports.list
    echo deb http://http.debian.net/debian jessie-backports main contrib non-free > /etc/apt/sources.list.d/jessie-backports.list
    output "Updating Server Packages."
    apt-get -y update
    apt-get -y upgrade
    apt-get -y autoremove
    apt-get -y autoclean
    output"Installing new kernel"
    apt install -t jessie-backports linux-image-4.9.0-0.bpo.7-amd64
    output "Modifying Docker."
    sed -i 's,/usr/bin/dockerd,/usr/bin/dockerd --storage-driver=overlay2,g' /lib/systemd/system/docker.service
    systemctl daemon-reload
    service docker start
}

ssl_certs(){
    output "Installing LetsEncrypt and creating an SSL certificate."
    cd /root
    if  [ "$lsb_dist" =  "ubuntu" ] || [ "$lsb_dist" =  "debian" ]; then
        if [ "$lsb_dist" =  "debian" ] && [ "$dist_version" = "8" ]; then
            wget https://dl.eff.org/certbot-auto
            chmod a+x certbot-auto
        else
            apt-get -y install certbot
        fi
    elif [ "$lsb_dist" =  "fedora" ] || [ "$lsb_dist" =  "centos" ] ||  [ "$lsb_dist" =  "rhel" ]; then
        yum -y install certbot
    fi
    if [ "$webserver" = "1" ]; then
        service nginx stop
    elif [ "$webserver" = "2" ]; then
        if  [ "$lsb_dist" =  "ubuntu" ] || [ "$lsb_dist" =  "debian" ]; then
            service apache2 stop
        elif [ "$lsb_dist" =  "fedora" ] || [ "$lsb_dist" =  "centos" ] ||  [ "$lsb_dist" =  "rhel" ]; then
            service httpd stop
        fi
    fi

    if [ "$lsb_dist" =  "debian" ] && [ "$dist_version" = "8" ]; then
        ./certbot-auto certonly --standalone --email "$email" --agree-tos -d "$FQDN" --non-interactive
    else
        certbot certonly --standalone --email "$email" --agree-tos -d "$FQDN" --non-interactive
    fi
    if [ "$installoption" = "2" ]; then
        if  [ "$lsb_dist" =  "ubuntu" ] || [ "$lsb_dist" =  "debian" ]; then
            ufw deny 80
        elif [ "$lsb_dist" =  "fedora" ] || [ "$lsb_dist" =  "centos" ] ||  [ "$lsb_dist" =  "rhel" ]; then
            firewall-cmd --permanent --remove-port=80/tcp
            firewall-cmd --reload
        fi
    else
        if [ "$webserver" = "1" ]; then
            service nginx restart
        elif [ "$webserver" = "2" ]; then
            if  [ "$lsb_dist" =  "ubuntu" ] || [ "$lsb_dist" =  "debian" ]; then
                service apache2 restart
            elif [ "$lsb_dist" =  "fedora" ] || [ "$lsb_dist" =  "centos" ] ||  [ "$lsb_dist" =  "rhel" ]; then
                service httpd restart
            fi
        fi
    fi

    if [ "$lsb_dist" =  "debian" ] && [ "$dist_version" = "8" ]; then
        apt -y install cronie
        if [ "$installoption" = "1" ]; then
            if [ "$webserver" = "1" ]; then
                (crontab -l ; echo "0 0,12 * * * ./certbot-auto renew --pre-hook "service nginx stop" --post-hook "service nginx restart" >> /dev/null 2>&1")| crontab -
            elif [ "$webserver" = "2" ]; then
                (crontab -l ; echo "0 0,12 * * * ./certbot-auto renew --pre-hook "service apache2 stop" --post-hook "service apache2 restart" >> /dev/null 2>&1")| crontab -
            fi
        elif [ "$installoption" = "2" ]; then
            (crontab -l ; echo "0 0,12 * * * ./certbot-auto renew --pre-hook "ufw allow 80" --pre-hook "service wings stop" --post-hook "ufw deny 80" --post-hook "service wings restart" >> /dev/null 2>&1")| crontab -
        elif [ "$installoption" = "3" ]; then
            if [ "$webserver" = "1" ]; then
                (crontab -l ; echo "0 0,12 * * * ./certbot-auto renew --pre-hook "service nginx stop" --pre-hook "service wings stop" --post-hook "service nginx restart" --post-hook "service wings restart" >> /dev/null 2>&1")| crontab -
            elif [ "$webserver" = "2" ]; then
                (crontab -l ; echo "0 0,12 * * * ./certbot-auto renew --pre-hook "service apache2 stop" --pre-hook "service wings stop" --post-hook "service apache2 restart" --post-hook "service wings restart" >> /dev/null 2>&1")| crontab -
            fi
        fi            
    elif [ "$lsb_dist" =  "debian" ] || [ "$lsb_dist" =  "ubuntu" ]; then
        apt -y install cronie
        if [ "$installoption" = "1" ]; then
            if [ "$webserver" = "1" ]; then
                (crontab -l ; echo "0 0,12 * * * certbot renew --pre-hook "service nginx stop" --post-hook "service nginx restart" >> /dev/null 2>&1")| crontab -
            elif [ "$webserver" = "2" ]; then
                (crontab -l ; echo "0 0,12 * * * certbot renew --pre-hook "service apache2 stop" --post-hook "service apache2 restart" >> /dev/null 2>&1")| crontab -
            fi
        elif [ "$installoption" = "2" ]; then
            (crontab -l ; echo "0 0,12 * * * certbot renew --pre-hook "ufw allow 80" --pre-hook "service wings stop" --post-hook "ufw deny 80" --post-hook "service wings restart" >> /dev/null 2>&1")| crontab -
        elif [ "$installoption" = "3" ]; then
            if [ "$webserver" = "1" ]; then
                (crontab -l ; echo "0 0,12 * * * certbot renew --pre-hook "service nginx stop" --pre-hook "service wings stop" --post-hook "service nginx restart" --post-hook "service wings restart" >> /dev/null 2>&1")| crontab -
            elif [ "$webserver" = "2" ]; then
                (crontab -l ; echo "0 0,12 * * * certbot renew --pre-hook "service apache2 stop" --pre-hook "service wings stop" --post-hook "service apache2 restart" --post-hook "service wings restart" >> /dev/null 2>&1")| crontab -
            fi
        fi    
    elif [ "$lsb_dist" =  "fedora" ] || [ "$lsb_dist" =  "centos" ] || [ "$lsb_dist" =  "rhel" ]; then
        yum -y install cronie
        if [ "$installoption" = "1" ]; then
            if [ "$webserver" = "1" ]; then
                (crontab -l ; echo "0 0,12 * * * certbot renew --pre-hook "service nginx stop" --post-hook "service nginx restart" >> /dev/null 2>&1")| crontab -
            elif [ "$webserver" = "2" ]; then
                (crontab -l ; echo "0 0,12 * * * certbot renew --pre-hook "service httpd stop" --post-hook "service httpd restart" >> /dev/null 2>&1")| crontab -
            fi
        elif [ "$installoption" = "2" ]; then
            (crontab -l ; echo "0 0,12 * * * certbot renew --pre-hook "firewall-cmd --add-port=80/tcp && firewall-cmd --reload" --pre-hook "service wings stop" --post-hook "firewall-cmd --remove-port=80/tcp && firewall-cmd --reload" --post-hook "service wings restart" >> /dev/null 2>&1")| crontab -
        elif [ "$installoption" = "3" ]; then
            if [ "$webserver" = "1" ]; then
                (crontab -l ; echo "0 0,12 * * * certbot renew --pre-hook "service nginx stop" --pre-hook "service wings stop" --post-hook "service nginx restart" --post-hook "service wings restart" >> /dev/null 2>&1")| crontab -
            elif [ "$webserver" = "2" ]; then
                (crontab -l ; echo "0 0,12 * * * certbot renew --pre-hook "service httpd stop" --pre-hook "service wings stop" --post-hook "service httpd restart" --post-hook "service wings restart" >> /dev/null 2>&1")| crontab -
            fi
        fi    
    fi
    service cron restart
}

firewall(){
    rm -rf /etc/rc.local
    printf '%s\n' '#!/bin/bash' 'exit 0' | sudo tee -a /etc/rc.local
    chmod +x /etc/rc.local

    iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP
    iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
    iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP 
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP 
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP 
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP 
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP 
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP 
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP 
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP 
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP 
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP 
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP 
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP 
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
    iptables -A INPUT -p tcp -m connlimit --connlimit-above 1000 --connlimit-mask 32 --connlimit-saddr -j REJECT --reject-with tcp-reset
    iptables -t mangle -A PREROUTING -f -j DROP
    /sbin/iptables -N port-scanning 
    /sbin/iptables -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN 
    /sbin/iptables -A port-scanning -j DROP  
    sh -c "iptables-save > /etc/iptables.conf"
    sed -i -e '$i \iptables-restore < /etc/iptables.conf\n' /etc/rc.local

    output "Setting up Fail2Ban"
    if [ "$lsb_dist" =  "ubuntu" ] || [ "$lsb_dist" =  "debian" ]; then
        apt -y install fail2ban
    elif [ "$lsb_dist" =  "centos" ] || [ "$lsb_dist" =  "fedora" ] ||  [ "$lsb_dist" =  "rhel" ]; then
        yum -y install fail2ban
    fi 
    systemctl enable fail2ban
    bash -c 'cat > /etc/fail2ban/jail.local' <<-'EOF'
[DEFAULT]
# Ban hosts for ten hours:
bantime = 36000

# Override /etc/fail2ban/jail.d/00-firewalld.conf:
banaction = iptables-multiport

[sshd]
enabled = true
EOF
    service fail2ban restart

    output "Configuring your firewall."
    if [ "$lsb_dist" =  "ubuntu" ] || [ "$lsb_dist" =  "debian" ]; then
        apt-get -y install ufw
        ufw allow 22
        if [ "$installoption" = "1" ]; then
            ufw allow 80
            ufw allow 443
            ufw allow 3306
        elif [ "$installoption" = "2" ]; then
            ufw allow 80
            ufw allow 8080
            ufw allow 2022
        elif [ "$installoption" = "3" ]; then
            ufw allow 80
            ufw allow 443
            ufw allow 8080
            ufw allow 2022
            ufw allow 3306
        fi
        yes |ufw enable 
    elif [ "$lsb_dist" =  "centos" ] || [ "$lsb_dist" =  "fedora" ] ||  [ "$lsb_dist" =  "rhel" ]; then
        yum -y install firewalld
        systemctl enable firewalld
        systemctl start firewalld
        if [ "$installoption" = "1" ]; then
            firewall-cmd --add-service=http --permanent
            firewall-cmd --add-service=https --permanent 
            firewall-cmd --add-service=mysql --permanent 
        elif [ "$installoption" = "2" ]; then
            firewall-cmd --permanent --add-port=80/tcp
            firewall-cmd --permanent --add-port=2022/tcp
            firewall-cmd --permanent --add-port=8080/tcp
        elif [ "$installoption" = "3" ]; then
            firewall-cmd --add-service=http --permanent
            firewall-cmd --add-service=https --permanent 
            firewall-cmd --permanent --add-port=2022/tcp
            firewall-cmd --permanent --add-port=8080/tcp
            firewall-cmd --add-service=mysql --permanent 
        fi
        firewall-cmd --reload
    fi
}

mariadb_root_reset(){
    service mariadb stop
    mysqld_safe --skip-grant-tables >res 2>&1 &
    sleep 5
    rootpassword=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
    Q1="UPDATE user SET plugin='';"
    Q2="UPDATE user SET password=PASSWORD('$rootpassword') WHERE user='root';"
    Q3="FLUSH PRIVILEGES;"
    SQL="${Q1}${Q2}${Q3}"
    mysql mysql -e "$SQL"
    pkill mysqld
    service mariadb restart
    output "Your MariaDB root password is $rootpassword"
}

database_host_reset(){
    SERVER_IP=$(curl -s http://checkip.amazonaws.com)
    service mariadb stop
    mysqld_safe --skip-grant-tables >res 2>&1 &
    sleep 5
    adminpassword=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
    Q1="UPDATE user SET plugin='';"
    Q2="UPDATE user SET password=PASSWORD('$adminpassword') WHERE user='admin';"
    Q3="FLUSH PRIVILEGES;"
    SQL="${Q1}${Q2}${Q3}"
    mysql mysql -e "$SQL"
    pkill mysqld
    service mariadb restart
    output "New database host information:"
    output "Host: $SERVER_IP"
    output "Port: 3306"
    output "User: admin"
    output "Password: $adminpassword"
}

broadcast(){
    if [ "$installoption" = "1" ] || [ "$installoption" = "3" ]; then
        output "###############################################################"
        output "MARIADB INFORMATION"
        output ""
        output "Your MariaDB root password is $rootpassword"
        output ""
        output "Create your MariaDB host with the following information:"
        output "Host: $SERVER_IP"
        output "Port: 3306"
        output "User: admin"
        output "Password: $adminpassword"
        output "###############################################################"
        output ""
    fi
    output "###############################################################"
    output "FIREWALL INFORMATION"
    output ""
    output "All unnecessary ports are blocked by default."
    if [ "$lsb_dist" =  "ubuntu" ] || [ "$lsb_dist" =  "debian" ]; then
        output "Use 'ufw allow <port>' to enable your desired ports"
    elif [ "$lsb_dist" =  "fedora" ] || [ "$lsb_dist" =  "centos" ] ||  [ "$lsb_dist" =  "rhel" ]; then
        output "Use 'firewall-cmd --permanent --add-port=<port>/tcp' to enable your desired ports."
        semanage permissive -a httpd_t
        semanage permissive -a redis_t
    fi
    output "###############################################################"
    output ""

    if [ "$installoption" = "2" ] || [ "$installoption" = "3" ]; then
        output "###############################################################"
        output "DAEMON CONFIGURATION"
        output ""
        output "Installation completed. Please configure the daemon. "
        output "The guide for daemon configuration can be founded here: https://pterodactyl.io/daemon/installing.html#configure-daemon"   
        output "Please run 'service wings restart' after the configuration."  
        if [ "$lsb_dist" =  "debian" ] && [ "$dist_version" = "8" ]; then
            output "Please restart the server after you have configured the daemon to apply the necessary kernel changes on Debian 8."
        fi
        output "###############################################################"
    fi
                         
}

#Execution
z="
";eCz='ist"';kGz='iver';KNz='scor';fNz='stan';rGz='n" ]';rBz='ized';iPz='te p';gKz='q 2.';OMz='io >';VEz='"7.3';TNz='e to';vDz='!= "';WBz='ling';cIz='e gi';sIz='] No';TDz=' 2';RLz='l de';mOz='et."';ZGz='oftw';lGz='se';sz='resr';JHz='virt';qHz='erv"';QEz='"7.1';rLz='Did ';uKz='ardl';pLz='tfor';AGz='d! P';CLz='ght ';Vz='ran ';XKz='isk.';DHz='|| [';XHz='Bare';gJz='k. P';iFz='YPE}';nDz=' "fe';KLz='mage';GIz=' you';xPz='d Ma';YHz=' Met';ZHz='al d';nFz='it s';iMz='html';ZIz=' "No';nKz='nite';JDz='Only';UDz='elif';LKz='the ';ZEz='RHEL';iNz='FTP ';KDz=' Ubu';QLz='erne';TGz='-fix';MGz='on i';WJz='| gr';lFz='_64'\''';DLz='say.';iGz='ry -';eDz='an v';SLz='ed. ';dPz='mon.';LJz='ion.';TPz='ver.';KBz='t is';oz=' to ';WGz='-y i';bLz='he s';ZNz='on."';EBz=' Ple';rOz=' inf';oBz='etec';CQz='assw';WLz='t su';WHz='on: ';VPz='n=5';cKz='oper';tNz='[6] ';HIz='r pr';mMz='good';OKz='p, t';VHz='zati';RNz='ould';SFz='s ro';DBz='ase.';OHz='))';Dz='odac';FIz='with';xOz='You ';fEz='= "u';sNz='3."';ADz='"16.';WCz='t $d';MLz='lve;';XPz='rade';TLz='Dock';aNz='[3] ';qOz='host';jIz=' poi';nBz='em D';RIz='r or';Lz='crip';xz='k yo';ABz='r yo';jNz='er."';aHz='ted.';xDz='Fedo';cNz='d da';IQz='d Da';kBz='erat';kz='copy';Wz='<thi';VBz='stal';JCz='o "$';REz='" ]&';vCz='= "1';DGz='it (';MEz='7 is';UNz='all ';mBz='Syst';gNz='dalo';OJz='esac';NHz=' $(v';bJz=' The';sOz='orma';uFz='arch';Xz='entr';fJz=' wor';Fz='Inst';ELz=' Exi';kJz='r wi';UCz='$lsb';mz='olat';NGz='niti';NEz=' "rh';WMz='M64V';QCz='exit';dFz='ame ';dBz='y ca';JOz='5 (O';NNz='elec';hGz='sito';gLz='void';pMz='rf i';JNz='n Di';IFz='28"';JBz='is s';kIz='nt i';wDz='28" ';fIz='er b';uEz='stem';NBz='o be';Pz='Copy';sCz='t_ve';yIz='oice';GKz='e ch';ZMz='umd6';yGz='edor';kCz=' "$d';uLz='ny b';gz='t an';GCz='leas';cHz='t_se';HFz='29, ';pFz='r de';fLz='to a';nNz='0.7.';CEz='29 a';wMz=' ple';iz='sues';GQz='11 )';FMz='ates';hKz='6; t';EFz='an: ';DOz='or U';MOz=' aft';YNz='daem';tFz='go."';IDz='on. ';POz='inst';MPz='n=4';fBz='prob';iJz='l yo';ALz='vide';GBz='note';tz='v.io';FHz='l" ]';bKz='sky ';IHz='t';GJz='2)  ';Iz=' & U';Oz='"';aGz='are-';ZPz='el."';uOz='allo';LDz='ntu ';oLz=' Pla';iCz=' ]; ';CIz='hod.';gOz='aria';COz='[8] ';yz='u fo';mIz='e fu';xEz=':"';hEz='u" ]';sGz='apt ';YFz='re D';Sz='2018';SCz='fi';aDz='n';fOz='cy M';RDz='port';Mz='t v2';XBz=' it ';UFz=' 3';YOz='tero';IPz='3 ) ';PGz='apt-';tMz='Outd';qJz='n ke';mGz='ll v';FQz='t."';sJz=' 6';BLz='r mi';CPz=' onl';sBz='if [';NJz=' 5';BKz='Prox';hCz='ntu"';Cz='Pter';JQz='taba';nGz='irt-';nHz='kvm"';kFz=''\''x86';rKz=' Doc';Zz='ecur';GMz='..."';DQz='ord ';aLz='x. T';gDz='ian ';qNz='to 0';mHz=' "" ';ZBz=' non';NMz='srv.';IIz='ovid';TEz='= "7';xNz='[7] ';FLz='ting';gHz='z lx';az='esrv';bOz='heme';JGz='liza';BFz='0, 1';hJz='e in';JPz='n=3';mPz='9 ) ';IGz='rtua';oFz='erve';VKz='ur o';aBz='-fre';bCz='cted';XIz='n ri';LBz=' mea';YJz='q xx';yEz='tu: ';cBz='S ma';RMz='l 2>';iEz=' && ';rCz='$dis';PMz='/dev';cz='."';dCz='sb_d';Qz='righ';OPz=' sta';xLz='ovin';qEz='rhel';BCz='dist';YLz='loud';dJz='ipt ';mCz=' != ';qMz='ndex';WDz=' "de';EGz='x86_';EEz='8 is';KIz='heth';GPz='n on';sPz='eme.';sMz='l';NKz=' ste';JFz='7"';jEz='[ "$';NLz='Clou';tHz='"hyp';nCz='"18.';VGz='sing';qz='s://';BJz='1)  ';eBz='use ';PIz='un D';LNz=' 69';YCz='vers';UOz=')"';pNz='nel ';NDz='4, 1';rMz='.htm';iLz='ther';eGz='ommo';PJz='Kern';nz='ions';XGz='nsta';BEz='ora ';MDz='18.0';pz='http';mFz='64-b';nOz='[11]';nPz='n=9';lMz='te, ';UBz='. In';ACz='lsb_';UEz='.2" ';ODz='6.04';eFz='-m`';pBz=' ini';jOz='pass';mJz=' gen';aCz='dete';SHz='"" ]';rNz='.7.1';ZKz='ith ';EOz='pdat';yKz=' pro';qGz='ebia';hz='y is';RGz='upda';iHz='Open';BIz=' met';HGz='c Vi';oHz='"$vi';ZCz='ion ';AJz=' in';LLz='s."';kKz='his ';OLz='dLin';XDz='bian';AIz='d Vi';yDz='ra v';KOz='nly ';qLz='m De';KHz='_ser';TOz='nel.';gBz='lems';hHz='c" ]';vBz='/os-';wHz='lxc"';fDz=' Deb';QFz='en';VIz='d at';WPz=' upg';pEz='st" ';cGz='erti';LQz='ost ';sDz='"$di';eLz='xit ';vz='cord';rFz='ed! ';gIz='reak';aFz='INE_';vGz='hat ';hMz='dex.';oNz='x pa';QDz=' sup';ILz='rthe';vNz='x da';GGz=' 4';VFz='c Ar';MKz='last';Kz='de s';oEz='b_di';dz='Plea';PFz='; th';WIz='r ow';KEz=' Cen';wLz='l. M';hLz=' fur';dKz='atio';jFz=' == ';cFz='=`un';APz=' sel';uBz='/etc';PCz='else';xJz='grep';tIz='read';CGz='itch';eHz='= "o';aJz='OVH ';LIz='er y';aKz='a ri';AMz='rwar';tPz='10 )';gCz='"ubu';xGz='  "f';YGz='ll s';CJz='Proc';vOz='ptio';wz='Than';tLz='ct a';jHz='VZ 7';yLz='g fo';vHz='nvz ';VLz='s no';WNz='l."';OIz='an r';LCz='_ver';pHz='rt_s';YDz='" ];';EPz='2 ) ';QMz='/nul';jMz='Up t';VDz='t" =';iBz='mati';cJz=' scr';qDz=' ] &';sEz='atin';lOz=' res';TIz='. Pr';kOz='word';PPz='ndal';PDz=' are';ECz='tc/o';GOz='MyAd';IEz='Cent';rDz='& [ ';nJz='eric';AKz='pve;';eNz='[4] ';oDz='dora';QJz='el D';INz='us o';pDz='"29"';dLz='ll e';VMz='-q "';FPz='n=2';tDz='st_v';fMz='7pjW';qPz='tyl'\''';DFz='.04"';LFz=' "$E';bBz='sh O';EMz=' upd';sHz='are"';DEz='nd 2';oIz='d?\n';jDz='are ';gFz='ACHI';wJz=') | ';bGz='prop';NPz='d to';TKz='ng a';uGz='rt-w';nIz=' "Pr';oOz='cy D';DNz='ve t';BBz='ur p';MIz='our ';lBz='ing ';wEz='d OS';cMz='J3ui';TCz='OS: ';oJz='trib';BPz='d pa';dMz='jMXQ';EHz='"rhe';pPz='nge ';BOz='0.4.';LHz='v=$(';qFz='tect';fz='epor';JIz='er w';bNz='l an';hNz='ne S';hOz='DB r';JJz='ng i';Jz='pgra';bIz='ld b';Nz='9.0.';HKz='osen';tBz=' -r ';ULz='er i';qIz='Yes.';UIz='ocee';jKz='d. T';SBz='fres';RHz='serv';aEz=' ver';GDz='tu v';eJz='will';eOz='rgen';LMz='h.se';oKz='ly n';kPz='Admi';RCz=' 1';jBz='c Op';yHz=' "Un';YEz='.6" ';MJz='.."';YMz='nsdz';hFz='NE_T';mKz='defi';fCz=' =  ';bFz='TYPE';uDz='on" ';BHz=' || ';pIz='[1] ';HEz='"7" ';CCz='="$(';PLz='ux K';NCz='VERS';FKz=' hav';EJz='ng..';IBz='t th';HPz='ly."';OCz='ION_';CHz='" = ';UGz='-mis';CBz='urch';XNz='[2] ';uMz='ated';fFz=' ${M';UPz='5 ) ';PEz=']&&[';hIz='s at';LPz='4 ) ';PNz='at y';FEz=' "ce';THz='Virt';xFz=' det';cDz='= "8';cOz='[10]';ICz=' ech';TJz='cho ';rPz='s th';AHz='a" ]';lNz='Upgr';kNz='[5] ';RFz='un a';mDz='d.."';QIz='ocke';LOz='this';dNz='emon';wKz='of w';bEz='. On';KFz=': 7"';YIz='sk."';Bz='ut "';QNz='ou w';tKz=' reg';WOz='Chan';iDz='d 8 ';xHz='warn';AFz='18.1';GHz='yum ';FGz='64).';lz='t vi';Ez='tyl ';JKz='inue';pKz='ot w';fKz='stab';rJz='rnel';lEz='"cen';GFz='ra: ';OFz=' 0 ]';AEz=' Fed';FDz='Ubun';IMz='ps:/';kHz='d."';BGz='e sw';TBz='h OS';bDz='"9" ';ANz='If y';xBz=']; t';nEz='"$ls';FFz='9, 8';MBz='nt t';MCz='sion';HMz=' htt';SNz=' lik';eIz='if y';wIz='case';FJz=';;';mNz='ade ';WFz='chit';pCz='] &&';yMz='st v';jPz='hpMy';vPz='on=1';lKz='ill ';yPz='riaD';PHz=' "$v';BDz='04" ';uz='/dis';AOz='o 1.';HHz=' wge';lLz='gcp;';SKz='proc';JEz='OS v';xIz=' $ch';kDz='supp';ZOz='dact';GLz='avoi';yFz='ecte';LEz='tOS ';SPz=' ser';IOz='4.8.';rIz='\n[2';PBz='tall';vFz='itec';BQz='ot p';qBz='tial';Az='outp';uPz='opti';KQz='se H';MHz='echo';IJz='elli';sFz='Good';DCz='. /e';VCz='_dis';RJz=' Ini';LGz='ecti';KKz=' in ';JLz='r da';Uz='en T';aPz='6 ) ';CFz=', 16';MMz='cure';fHz='penv';FBz='ase ';YPz=' pan';QPz='one ';pJz='utio';XOz='ge P';vEz='Supp';pOz='atab';UHz='uali';SEz='&[ "';hBz='Auto';GNz='ror,';FCz='s-re';SGz='te -';ez='se r';qCz=' [ "';iOz='oot ';OBz=' ins';OEz='el" ';QHz='irt_';nLz='le C';Yz='an@s';DMz=' for';MQz='info';cPz=' dae';uHz='"ope';SJz='if e';VNz='pane';ZLz='Linu';iKz='VZ 6';HDz='ersi';eEz='t" !';HOz='min ';yCz='&& [';FOz=' php';uIz=' cho';SDz='ed."';wNz='12."';qKz='ork ';dGz='es-c';BMz='Chec';rz='secu';wOz='n=1';cLz='t wi';vKz='ess ';NIz='er c';lDz='orte';QGz='get ';bMz='gE2r';HQz='1';eMz='36iy';ONz='t wh';MFz='UID"';CNz='elie';uJz='unam';tCz='rsio';XJz='ep -';cEz='ly R';NQz='rmat';dIz='ven ';bHz='$vir';oPz=' cha';AQz='B ro';KGz=' Det';gEz='bunt';EDz='ted ';ePz='7 ) ';oGz='what';wBz='rele';dOz=' Eme';ZJz='xx; ';wGz='wget';jCz='then';gPz='8 ) ';kEz='" !=';vMz='ipt,';oCz='10" ';RBz='n a ';jJz='ur s';QKz='fore';SMz='&1';lPz='n."';XMz='kKnD';xMz='late';HBz=' tha';hDz='9 an';bz='.io>';tJz='o $(';DDz='ppor';EIz='ult ';YBz='on a';WKz='wn r';xKz='your';CKz='mox ';HCz='e &&';lHz='rv d';kMz='o da';ZFz='MACH';HLz='d fu';CMz='king';lJz='th a';WEz='.4" ';UKz='t yo';Hz='tion';oMz='rm -';OGz='aliz';mEz='tos"';eKz='n...';wFz='ture';sLz='not ';hPz='n=8';gMz='" in';cCz=' "$l';aOz='yl t';DJz='eedi';bPz='n=6';gGz='repo';dEz='HEL ';KPz='and ';jLz=' dam';dHz='rv" ';MNz='se s';fPz='n=7';SOz='e pa';ROz='d th';KCz='ID")';vJz='e -r';VOz='[9] ';YKz='ng w';VJz='-r) ';lCz='ion"';NOz='ou h';BNz='ou b';tOz='1 ) ';IKz='cont';lIz='n th';kLz='ages';CDz='Unsu';uCz='n" !';PKz='here';sKz='ker,';Rz='t © ';HNz='act ';DPz='y."';nMz='go!"';aMz='CmWV';FNz='n er';jz=' or ';DIz='cons';yOz='have';yBz='hen';pGz='  "d';RKz=' we ';wCz='8.04';HJz='Canc';XFz='ectu';mLz='Goog';tEz='g Sy';XCz='ist_';GEz='ntos';EKz=' You';Gz='alla';SIz=' not';XEz='"7.5';RPz='SFTP';jGz='y un';KMz='taut';TFz='ot"';EQz='rese';UMz='rep ';TMz='if g';wPz='0';vLz='ad k';OOz='ave ';QOz='alle';fGz='add-';NFz=' -ne';Tz=' Thi';yJz=' -q ';iIz=' any';UJz='$(un';KJz='llat';aIz=' wou';uNz='0.6.';vIz='ice';rHz='"vmw';XLz='on C';tGz='n vi';DKz='LXE ';QBz='ed o';ENz='is a';ZDz=' the';yNz='er t';xCz='" ] ';rEz='Oper';dDz='Debi';JMz='/sof';
eval "$Az$Bz$Cz$Dz$Ez$Fz$Gz$Hz$Iz$Jz$Kz$Lz$Mz$Nz$Oz$z$Az$Bz$Pz$Qz$Rz$Sz$Tz$Uz$Vz$Wz$Xz$Yz$Zz$az$bz$cz$z$Az$Bz$dz$ez$fz$gz$hz$iz$jz$kz$Qz$lz$mz$nz$oz$pz$qz$rz$sz$tz$uz$vz$Oz$z$Az$Bz$Oz$z$Az$Bz$wz$xz$yz$ABz$BBz$CBz$DBz$EBz$FBz$GBz$HBz$IBz$JBz$Lz$KBz$LBz$MBz$NBz$OBz$PBz$QBz$RBz$SBz$TBz$UBz$VBz$WBz$XBz$YBz$ZBz$aBz$bBz$cBz$dBz$eBz$fBz$gBz$cz$z$Az$Bz$hBz$iBz$jBz$kBz$lBz$mBz$nBz$oBz$Hz$pBz$qBz$rBz$cz$z$sBz$tBz$uBz$vBz$wBz$FBz$xBz$yBz$z$ACz$BCz$CCz$DCz$ECz$FCz$GCz$HCz$ICz$JCz$KCz$Oz$z$BCz$LCz$MCz$CCz$DCz$ECz$FCz$GCz$HCz$ICz$JCz$NCz$OCz$KCz$Oz$z$PCz$z$QCz$RCz$z$SCz$z$Az$Bz$TCz$UCz$VCz$WCz$XCz$YCz$ZCz$aCz$bCz$cz$z$Az$Bz$Oz$z$sBz$cCz$dCz$eCz$fCz$gCz$hCz$iCz$jCz$z$sBz$kCz$XCz$YCz$lCz$mCz$nCz$oCz$pCz$qCz$rCz$sCz$tCz$uCz$vCz$wCz$xCz$yCz$kCz$XCz$YCz$lCz$mCz$ADz$BDz$xBz$yBz$z$Az$Bz$CDz$DDz$EDz$FDz$GDz$HDz$IDz$JDz$KDz$LDz$MDz$NDz$ODz$PDz$QDz$RDz$SDz$z$QCz$TDz$z$SCz$z$UDz$qCz$UCz$VCz$VDz$WDz$XDz$YDz$ZDz$aDz$z$sBz$kCz$XCz$YCz$lCz$mCz$bDz$pCz$qCz$rCz$sCz$tCz$uCz$cDz$YDz$ZDz$aDz$z$Az$Bz$CDz$DDz$EDz$dDz$eDz$HDz$IDz$JDz$fDz$gDz$hDz$iDz$jDz$kDz$lDz$mDz$z$QCz$TDz$z$SCz$z$UDz$qCz$UCz$VCz$VDz$nDz$oDz$YDz$ZDz$aDz$z$sBz$kCz$XCz$YCz$lCz$mCz$pDz$qDz$rDz$sDz$tDz$HDz$uDz$vDz$wDz$xBz$yBz$z$Az$Bz$CDz$DDz$EDz$xDz$yDz$HDz$IDz$JDz$AEz$BEz$CEz$DEz$EEz$QDz$RDz$SDz$z$QCz$TDz$z$SCz$z$UDz$qCz$UCz$VCz$VDz$FEz$GEz$YDz$ZDz$aDz$z$sBz$kCz$XCz$YCz$lCz$mCz$HEz$xBz$yBz$z$Az$Bz$CDz$DDz$EDz$IEz$JEz$HDz$IDz$JDz$KEz$LEz$MEz$QDz$RDz$SDz$z$QCz$TDz$z$SCz$z$UDz$qCz$UCz$VCz$VDz$NEz$OEz$xBz$yBz$z$sBz$kCz$XCz$YCz$lCz$mCz$HEz$PEz$kCz$XCz$YCz$lCz$mCz$QEz$REz$SEz$rCz$sCz$tCz$uCz$TEz$UEz$PEz$kCz$XCz$YCz$lCz$mCz$VEz$REz$SEz$rCz$sCz$tCz$uCz$TEz$WEz$PEz$kCz$XCz$YCz$lCz$mCz$XEz$REz$SEz$rCz$sCz$tCz$uCz$TEz$YEz$xBz$yBz$z$Az$Bz$CDz$DDz$EDz$ZEz$aEz$MCz$bEz$cEz$dEz$MEz$QDz$RDz$SDz$z$QCz$TDz$z$SCz$z$UDz$qCz$UCz$VCz$eEz$fEz$gEz$hEz$iEz$jEz$ACz$BCz$kEz$WDz$XDz$xCz$yCz$cCz$dCz$eCz$mCz$lEz$mEz$qDz$rDz$nEz$oEz$pEz$vDz$qEz$YDz$ZDz$aDz$z$Az$Bz$CDz$DDz$EDz$rEz$sEz$tEz$uEz$cz$z$Az$Bz$Oz$z$Az$Bz$vEz$lDz$wEz$xEz$z$Az$Bz$FDz$yEz$AFz$BFz$wCz$CFz$DFz$z$Az$Bz$dDz$EFz$FFz$Oz$z$Az$Bz$xDz$GFz$HFz$IFz$z$Az$Bz$IEz$TCz$JFz$z$Az$Bz$ZEz$KFz$z$QCz$TDz$z$SCz$z$sBz$LFz$MFz$NFz$OFz$PFz$QFz$z$Az$Bz$dz$ez$RFz$SFz$TFz$z$QCz$UFz$z$SCz$z$Az$Bz$hBz$iBz$VFz$WFz$XFz$YFz$oBz$Hz$pBz$qBz$rBz$cz$z$ZFz$aFz$bFz$cFz$dFz$eFz$z$sBz$fFz$gFz$hFz$iFz$jFz$kFz$lFz$iCz$jCz$z$Az$Bz$mFz$nFz$oFz$pFz$qFz$rFz$sFz$oz$tFz$z$Az$Bz$Oz$z$PCz$z$Az$Bz$CDz$DDz$EDz$uFz$vFz$wFz$xFz$yFz$AGz$GCz$BGz$CGz$oz$mFz$DGz$EGz$FGz$Oz$z$QCz$GGz$z$SCz$z$Az$Bz$hBz$iBz$HGz$IGz$JGz$Hz$KGz$LGz$MGz$NGz$OGz$SDz$z$sBz$cCz$dCz$eCz$fCz$gCz$hCz$iCz$jCz$z$PGz$QGz$RGz$SGz$TGz$UGz$VGz$z$PGz$QGz$WGz$XGz$YGz$ZGz$aGz$bGz$cGz$dGz$eGz$aDz$z$fGz$PGz$gGz$hGz$iGz$jGz$kGz$lGz$z$PGz$QGz$WGz$XGz$mGz$nGz$oGz$z$UDz$qCz$UCz$VCz$VDz$pGz$qGz$rGz$PFz$QFz$z$sGz$RGz$SGz$TGz$UGz$VGz$z$PGz$QGz$WGz$XGz$YGz$ZGz$aGz$bGz$cGz$dGz$eGz$tGz$uGz$vGz$wGz$z$UDz$qCz$UCz$VCz$VDz$xGz$yGz$AHz$BHz$jEz$ACz$BCz$CHz$FEz$GEz$xCz$DHz$cCz$dCz$eCz$fCz$EHz$FHz$PFz$QFz$z$GHz$WGz$XGz$mGz$nGz$oGz$HHz$IHz$z$SCz$z$JHz$KHz$LHz$MHz$NHz$nGz$oGz$OHz$z$sBz$PHz$QHz$RHz$CHz$SHz$PFz$QFz$z$Az$Bz$THz$UHz$VHz$WHz$XHz$YHz$ZHz$oBz$aHz$Oz$z$UDz$qCz$bHz$cHz$dHz$eHz$fHz$gHz$hHz$PFz$QFz$z$Az$Bz$THz$UHz$VHz$WHz$iHz$jHz$xFz$yFz$kHz$z$PCz$z$Az$Bz$THz$UHz$VHz$WHz$bHz$cHz$lHz$oBz$aHz$Oz$z$SCz$z$Az$Bz$Oz$z$sBz$PHz$QHz$RHz$kEz$mHz$pCz$qCz$bHz$cHz$dHz$vDz$nHz$qDz$rDz$oHz$pHz$qHz$mCz$rHz$sHz$qDz$rDz$oHz$pHz$qHz$mCz$tHz$qHz$qDz$rDz$oHz$pHz$qHz$mCz$uHz$vHz$wHz$iCz$jCz$z$xHz$yHz$kDz$lDz$AIz$IGz$JGz$Hz$BIz$CIz$EBz$FBz$DIz$EIz$FIz$GIz$HIz$IIz$JIz$KIz$LIz$MIz$RHz$NIz$OIz$PIz$QIz$RIz$SIz$TIz$UIz$VIz$GIz$WIz$XIz$YIz$z$xHz$ZIz$QDz$RDz$aIz$bIz$cIz$dIz$eIz$MIz$RHz$fIz$gIz$hIz$iIz$jIz$kIz$lIz$mIz$wFz$cz$z$xHz$nIz$UIz$oIz$pIz$qIz$rIz$sIz$cz$z$tIz$uIz$vIz$z$wIz$xIz$yIz$AJz$z$BJz$Az$Bz$CJz$DJz$EJz$cz$z$FJz$z$GJz$Az$Bz$HJz$IJz$JJz$XGz$KJz$LJz$MJz$z$QCz$NJz$z$FJz$z$OJz$z$Az$Bz$Oz$z$SCz$z$Az$Bz$PJz$QJz$oBz$Hz$RJz$qBz$rBz$cz$z$SJz$TJz$UJz$dFz$VJz$WJz$XJz$YJz$ZJz$jCz$z$Az$Bz$aJz$PJz$QJz$oBz$aHz$bJz$cJz$dJz$eJz$SIz$fJz$gJz$GCz$hJz$VBz$iJz$jJz$oFz$kJz$lJz$mJz$nJz$uz$oJz$pJz$qJz$rJz$cz$z$QCz$sJz$z$UDz$ICz$tJz$uJz$vJz$wJz$xJz$yJz$AKz$ZDz$aDz$z$Az$Bz$BKz$CKz$DKz$PJz$QJz$oBz$aHz$EKz$FKz$GKz$HKz$oz$IKz$JKz$KKz$LKz$MKz$NKz$OKz$PKz$QKz$RKz$jDz$SKz$DJz$TKz$UKz$VKz$WKz$XKz$Oz$z$Az$Bz$CJz$DJz$YKz$ZKz$aKz$bKz$cKz$dKz$eKz$Oz$z$UDz$ICz$tJz$uJz$vJz$wJz$xJz$yJz$fKz$PFz$QFz$z$SJz$TJz$UJz$dFz$VJz$WJz$XJz$gKz$hKz$yBz$z$Az$Bz$iHz$iKz$xFz$yFz$jKz$kKz$RHz$JIz$lKz$mKz$nKz$oKz$pKz$qKz$FIz$rKz$sKz$tKz$uKz$vKz$wKz$vGz$xKz$yKz$ALz$BLz$CLz$DLz$ELz$FLz$oz$GLz$HLz$ILz$JLz$KLz$LLz$z$QCz$sJz$z$SCz$z$UDz$ICz$tJz$uJz$vJz$wJz$xJz$yJz$MLz$ZDz$aDz$z$Az$Bz$NLz$OLz$PLz$QLz$RLz$qFz$SLz$TLz$ULz$VLz$WLz$DDz$EDz$XLz$YLz$ZLz$aLz$bLz$Lz$cLz$dLz$eLz$fLz$gLz$hLz$iLz$jLz$kLz$cz$z$QCz$sJz$z$UDz$ICz$tJz$uJz$vJz$wJz$xJz$yJz$lLz$ZDz$aDz$z$Az$Bz$mLz$nLz$YLz$oLz$pLz$qLz$qFz$SLz$sFz$oz$tFz$z$PCz$z$Az$Bz$rLz$sLz$aCz$tLz$uLz$vLz$QLz$wLz$xLz$yLz$AMz$kHz$z$Az$Bz$Oz$z$SCz$z$Az$Bz$BMz$CMz$DMz$EMz$FMz$GMz$z$wGz$HMz$IMz$JMz$KMz$LMz$MMz$NMz$OMz$PMz$QMz$RMz$SMz$z$TMz$UMz$VMz$WMz$XMz$YMz$ZMz$aMz$bMz$cMz$dMz$eMz$fMz$gMz$hMz$iMz$PFz$QFz$z$Az$Bz$jMz$kMz$lMz$mMz$oz$nMz$z$Az$Bz$Oz$z$oMz$pMz$qMz$rMz$sMz$z$PCz$z$Az$Bz$tMz$uMz$cJz$vMz$wMz$FBz$eBz$LKz$xMz$yMz$HDz$IDz$ANz$BNz$CNz$DNz$kKz$ENz$FNz$GNz$wMz$FBz$IKz$HNz$INz$JNz$KNz$kHz$z$oMz$pMz$qMz$rMz$sMz$z$QCz$LNz$z$SCz$z$Az$Bz$dz$MNz$NNz$ONz$PNz$QNz$RNz$SNz$TNz$OBz$PBz$xEz$z$Az$Bz$pIz$Fz$UNz$LKz$VNz$WNz$z$Az$Bz$XNz$Fz$UNz$LKz$YNz$ZNz$z$Az$Bz$aNz$Fz$UNz$LKz$VNz$bNz$cNz$dNz$cz$z$Az$Bz$eNz$Fz$UNz$LKz$fNz$gNz$hNz$iNz$RHz$jNz$z$Az$Bz$kNz$lNz$mNz$nNz$oNz$pNz$qNz$rNz$sNz$z$Az$Bz$tNz$lNz$mNz$uNz$vNz$dNz$oz$uNz$wNz$z$Az$Bz$xNz$lNz$mNz$LKz$fNz$gNz$hNz$iNz$RHz$yNz$AOz$BOz$Oz$z$Az$Bz$COz$Fz$UNz$DOz$EOz$TNz$FOz$GOz$HOz$IOz$JOz$KOz$eBz$LOz$MOz$LIz$NOz$OOz$POz$QOz$ROz$SOz$TOz$UOz$z$Az$Bz$VOz$WOz$XOz$YOz$ZOz$aOz$bOz$cz$z$Az$Bz$cOz$dOz$eOz$fOz$gOz$hOz$iOz$jOz$kOz$lOz$mOz$z$Az$Bz$nOz$dOz$eOz$oOz$pOz$FBz$qOz$rOz$sOz$Hz$lOz$mOz$z$tIz$uIz$vIz$z$wIz$xIz$yIz$AJz$z$tOz$POz$uOz$vOz$wOz$z$Az$Bz$xOz$yOz$APz$yFz$BPz$pNz$POz$Gz$Hz$CPz$DPz$z$FJz$z$EPz$POz$uOz$vOz$FPz$z$Az$Bz$xOz$yOz$APz$yFz$cNz$dNz$OBz$PBz$dKz$GPz$HPz$z$FJz$z$IPz$POz$uOz$vOz$JPz$z$Az$Bz$xOz$yOz$APz$yFz$BPz$pNz$KPz$YNz$MGz$XGz$KJz$LJz$Oz$z$FJz$z$LPz$POz$uOz$vOz$MPz$z$Az$Bz$xOz$yOz$APz$yFz$NPz$OBz$PBz$ZDz$OPz$PPz$QPz$RPz$SPz$TPz$Oz$z$FJz$z$UPz$POz$uOz$vOz$VPz$z$Az$Bz$xOz$yOz$APz$yFz$NPz$WPz$XPz$ZDz$YPz$ZPz$z$FJz$z$aPz$POz$uOz$vOz$bPz$z$Az$Bz$xOz$yOz$APz$yFz$NPz$WPz$XPz$ZDz$cPz$dPz$Oz$z$FJz$z$ePz$POz$uOz$vOz$fPz$z$Az$Bz$xOz$yOz$APz$yFz$NPz$WPz$XPz$ZDz$OPz$PPz$QPz$RPz$cz$z$FJz$z$gPz$POz$uOz$vOz$hPz$z$Az$Bz$xOz$yOz$APz$yFz$NPz$OBz$PBz$jz$RGz$iPz$jPz$kPz$lPz$z$FJz$z$mPz$POz$uOz$vOz$nPz$z$Az$Bz$xOz$yOz$APz$yFz$NPz$oPz$pPz$Cz$Dz$qPz$rPz$sPz$Oz$z$FJz$z$tPz$OBz$PBz$uPz$vPz$wPz$z$Az$Bz$xOz$yOz$APz$yFz$xPz$yPz$AQz$BQz$CQz$DQz$EQz$FQz$z$FJz$z$GQz$OBz$PBz$uPz$vPz$HQz$z$Az$Bz$xOz$yOz$APz$yFz$IQz$JQz$KQz$LQz$MQz$NQz$ZCz$EQz$FQz$z$FJz$z$OJz"
case $installoption in 
    1)  webserver_options
        theme_options
        repositories_setup
        required_infos
        firewall
        setup_pterodactyl
        broadcast
        ;;
    2)  get_virtualization
        repositories_setup
        required_infos
        firewall
        ssl_certs
        install_daemon
        broadcast
        ;;
    3)  get_virtualization
        webserver_options
        theme_options
        repositories_setup
        required_infos
        firewall
        setup_pterodactyl
        install_daemon
        broadcast
        ;;
    4)  install_standalone_sftp
        ;;
    5)  theme_options
        upgrade_pterodactyl
        theme
        ;;
    6)  upgrade_daemon
        ;;
    7)  upgrade_standalone_sftp
        ;;
    8)  install_phpmyadmin
        ;;
    9)  theme_options
        if [ "$themeoption" = "1" ]; then
            upgrade_pterodactyl
        fi
        theme
        ;;
    10) mariadb_root_reset
        ;;
    11) database_host_reset
        ;;
esac
