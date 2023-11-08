# Install Docker
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce git python3 python3-pip python3-venv -y


# Clone ROS honeypot repo and start service
git clone https://github.com/samderanova/ros-honeypot.git
mv ros-honeypot honeypot
cd honeypot
mkdir data

# Install script dependencies
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Set up ROS docker container
docker build -t talker-listener .
docker run -d -p 11311:11311 talker-listener

# Set up sniffing service and data removal crontab
mv scapy-writer.service /etc/systemd/system
systemctl daemon-reload
systemctl start scapy-writer.service
(crontab -l; echo "0 1 * * * /usr/bin/python3 /root/honeypot/remover.py") | crontab -

# Add public SSH key to new cloud server to allow rsync access
echo "Enter public SSH key: "
read publicSSHKey
echo $publicSSHKey >> ~/.ssh/authorized_keys
