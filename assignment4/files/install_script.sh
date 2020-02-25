#!/bin/bash

GIT_REPO="https://github.com/timoguic/ACIT4640-todo-app.git"
SETUP_DIR="/home/admin/setup"
SRV_USER="todoapp"

#install packages
install_packages() {
	sudo yum install -y git nodejs nginx mongodb-server
	}

#create service user
create_user() {
	#remove user if exists
	sudo pkill -u $SRV_USER
	sudo userdel -r $SRV_USER
	#add new user
	sudo useradd -r -m $SRV_USER
	#give proper permission so later on nginx user can read files
	sudo chmod 755 /home/$SRV_USER/
	}

#Clone project and install dependencies	
set_up_app() {
	#bypass "cannot change back to /home/admin/" permission error
	cd /tmp
	#clone project
	sudo -u $SRV_USER git clone $GIT_REPO /home/$SRV_USER/app
	#install dependencies
	sudo -u $SRV_USER npm install --prefix /home/$SRV_USER/app
	}

#configure services
configure_services() {
	#configure nginx
	sudo cp $SETUP_DIR/nginx.conf /etc/nginx
	#configure todoapp database
	sudo cp $SETUP_DIR/database.js /home/$SRV_USER/app/config/
	#create todoapp service
	sudo cp $SETUP_DIR/todoapp.service /etc/systemd/system/
	#sudo systemctl daemon-reload
	}

#enable & start services
start_services() {
	#start mongod, todoapp and nginx in sequence
	sudo systemctl enable mongod
	sudo systemctl enable todoapp
	sudo systemctl enable nginx
	sudo systemctl start mongod
	sudo systemctl start todoapp
	sudo systemctl start nginx
}

echo -e "\nStarting install script... \n"

install_packages
create_user
set_up_app
configure_services
start_services

echo -e "\nInstall script finished.\n"
