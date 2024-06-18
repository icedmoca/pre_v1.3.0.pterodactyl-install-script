
# Deprecated ❌ :bird: pterodactyl-install-script

### 🛑  This repository has been deprecated and is no longer maintained, please see [vilhelmprytz/pterodactyl-installer](https://github.com/vilhelmprytz/pterodactyl-installer).
>Lightweight installation script for game server manager pterodactyl. This panel can run any game server.


## Using the installation script

>For Pterodactyl panel versions before v1.3.0

To use the installation scripts, simply run this command as root. The script will ask you whether you would like to install just the panel, just the daemon or both.

```bash
login as root
```
```bash
git clone https://github.com/icedmoca/pterodactyl-install-script.git
```
```bash
chmod -R 777 pterodactyl-install-script/
```
```bash
./pterodactyl-install-script/install.sh
```
>Firewall setup is optional
### Supported panel operating systems and webservers

| Operating System | Version | nginx support      | PHP Version | wings support
| ---------------- | ------- | ------------------ | ----------- | ------------------ |
| Ubuntu           | 14.04   | :red_circle:       |             | :red_circle:       |
|                  | 16.04   | :red_circle:       |             | :red_circle:       |
|                  | 18.04   | :white_check_mark: | 7.4         | :white_check_mark: |
|                  | 20.04   | :white_check_mark: | 7.4         | :white_check_mark: |
| Debian           | 8       | :red_circle:       |             | :red_circle:       |
|                  | 9       | :white_check_mark: | 7.4         | :white_check_mark: |
|                  | 10      | :white_check_mark: | 7.4         | :white_check_mark: |
| CentOS           | 6       | :red_circle:       |             | :red_circle:       |
|                  | 7       | :white_check_mark: | 7.4         | :white_check_mark: |
|                  | 8       | :white_check_mark: | 7.4         | :white_check_mark: |

Deprecated for security reasons please use vilhelmprytz's pterodactyl-installer :)
