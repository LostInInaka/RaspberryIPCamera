# ok, let's get started.
# To begin with, start by downloading a Raspbian Jessie Lite image from the Raspbian foundation website, write to sd card, boot it up.
# Ssh into it with username pi and password raspberry or any other account in the admin group

# Set user to variable for non-pi user installs
#current_user="$(last | grep $USER | head -1 |cut -d' ' -f1)"

# Bring the OS up to date:
sudo apt-get update && sudo apt-get -y upgrade

# Install git since we'll be pulling this from git repo.
sudo apt-get -y install git

# Clone our git repository.
git clone https://github.com/ronnyvdbr/RaspberryIPCamera.git

# add our pi user to www-data group.
#sudo usermod -a -G www-data ${current_user}
sudo usermod -a -G www-data $USER

# Install our webserver with PHP support.
sudo apt-get -y install nginx

# Install php5 fast process manager.
sudo apt-get -y install php5-fpm

# Disable the nginx default website
sudo rm /etc/nginx/sites-enabled/default

# Copy our own website config file to the nginx available website configurations
sudo cp ${HOME}/RaspberryIPCamera/DefaultConfigFiles/RaspberryIPCamera.Nginx.Siteconf /etc/nginx/sites-available/RaspberryIPCamera.Nginx.Siteconf

# Let's enable our new website:
sudo ln -s /etc/nginx/sites-available/RaspberryIPCamera.Nginx.Siteconf /etc/nginx/sites-enabled/RaspberryIPCamera.Nginx.Siteconf

# Restart our web server to pick up the new config.
sudo systemctl restart nginx.service

# Enable the Raspberry Pi Camera Module
sudo mount -o remount rw /boot
echo "start_x=1" | sudo tee -a /boot/config.txt
echo "gpu_mem=256" | sudo tee -a /boot/config.txt
echo "disable_camera_led=1" | sudo tee -a /boot/config.txt

# Unmount the boot volume so you don't accidentally mess things up ;)
sudo mount -o remount ro /boot

# put a sudoers file in the correct location for php shell commands integration
sudo cp ${HOME}/RaspberryIPCamera/DefaultConfigFiles/sudoers_commands /etc/sudoers.d/sudoers_commands

# Install UV4L software
curl http://www.linux-projects.org/listing/uv4l_repo/lrkey.asc | sudo apt-key add -
echo "deb http://www.linux-projects.org/listing/uv4l_repo/raspbian/ wheezy main" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get -y install uv4l uv4l-raspicam
sudo apt-get -y install uv4l-raspicam-extras
sudo apt-get -y install uv4l-uvc
sudo cp ${HOME}/RaspberryIPCamera/DefaultConfigFiles/uv4l-raspicam.conf /etc/uv4l/uv4l-raspicam.conf
sudo chgrp www-data /etc/uv4l/uv4l-raspicam.conf
sudo chmod 664 /etc/uv4l/uv4l-raspicam.conf

# This should allow for removal of git directory if you want to clean up after install - also allows for easy backup of config files
mkdir -p ${HOME}/.config/RaspberryIPCamera
cp ${HOME}/RaspberryIPCamera/www/RaspberryIPCameraSettings.ini ${HOME}/.config/RaspberryIPCamera/

# Put correct security rights on configuration files
sudo chgrp www-data ${HOME}/.config/RaspberryIPCamera/RaspberryIPCameraSettings.ini
sudo chmod 664 ${HOME}/.config/RaspberryIPCamera/RaspberryIPCameraSettings.ini

sudo chgrp www-data /etc/timezone
sudo chmod 664 /etc/timezone

sudo chgrp www-data /etc/ntp.conf
sudo chmod 664 /etc/ntp.conf


## install mjpeg streamer
# first install dependencies
sudo apt-get install libv4l-dev
sudo apt-get install libjpeg-dev

# input_testpicture.so uses 'convert' from imagemagick 
sudo apt-get install imagemagick

git clone https://github.com/ronnyvdbr/mjpg-streamer.git
cd ~/mjpg-streamer/mjpg-streamer
make USE_LIBV4L2=true clean all







