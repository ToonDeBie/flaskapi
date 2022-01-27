#connect fileshare
sudo mkdir /mnt/terraform
if [ ! -d "/etc/smbcredentials" ]; then
sudo mkdir /etc/smbcredentials
fi
if [ ! -f "/etc/smbcredentials/storeaccterraform.cred" ]; then
    sudo bash -c 'echo "username=storeaccterraform" >> /etc/smbcredentials/storeaccterraform.cred'
    sudo bash -c 'echo "password=FHwZg0dqV7Vbkr0g3O4wTh25PVoOVy1J9bmfKQR2I1sfTl92RUQSgPgDcml0bxDCfsGve4dJUJ6WaCtkmqrwag==" >> /etc/smbcredentials/storeaccterraform.cred'
fi
sudo chmod 600 /etc/smbcredentials/storeaccterraform.cred
sudo bash -c 'echo "//storeaccterraform.file.core.windows.net/terraform /mnt/terraform cifs nofail,vers=3.0,credentials=/etc/smbcredentials/storeaccterraform.cred,dir_mode=0777,file_mode=0777,serverino" >> /etc/fstab'
sudo mount -t cifs //storeaccterraform.file.core.windows.net/terraform /mnt/terraform -o vers=3.0,credentials=/etc/smbcredentials/storeaccterraform.cred,dir_mode=0777,file_mode=0777,serverino

#execute cmds
git clone https://gitlab.com/VolkertMoreels/apivoorvm.git
sudo apt update
sudo apt install gunicorn -y
sudo apt install python3-pip -y
pip3 install Flask
pip3 install torch==1.10.1+cpu torchvision==0.11.2+cpu torchaudio==0.10.1+cpu -f https://download.pytorch.org/whl/cpu/torch_stable.html
pip3 install fastai
sudo mv /tmp/gunicorn.service /etc/systemd/system/gunicorn.service
chmod 755 /etc/systemd/system/gunicorn.service
sudo systemctl daemon-reload
sudo systemctl start gunicorn.service