

# Needed files
sudo apt-get install fail2ban suricata timeshift docker.io docker-compose ufw python3-pip rsync clamav clamav-daemon rkhunter logrotate htop ssh-audit -y

sudo apt-get update && sudo apt-get upgrade -y

# Install and Configure UFW
sudo apt-get install ufw -y
# Ssh
sudo ufw allow 22
# Webserver
sudo ufw allow 80
sudo ufw allow 443 
# Mail server
sudo ufw allow 25
sudo ufw allow 465
sudo ufw allow 587
sudo ufw allow 143
sudo ufw allow 993
sudo ufw allow 110
sudo ufw allow 995
sudo ufw enable

# Basic Suricata Configuration 
sudo cp /etc/suricata/suricata.yaml /etc/suricata/suricata.yaml.backup
sudo systemctl enable suricata
sudo systemctl start suricata

# clamav update force
sudo chown -R clamav:clamav /var/log/clamav/
sudo chmod -R 750 /var/log/clamav/
sudo systemctl stop clamav-freshclam.service
sudo freshclam
sudo systemctl start clamav-freshclam.service


# set cron jobs/timeshift:
(crontab -l 2>/dev/null; echo "0 1 * * * /usr/bin/suricata-update && systemctl restart suricata"; echo "0 6 * * * sudo apt-get update && sudo apt-get upgrade -y && sudo freshclam && sudo rkhunter --update") | crontab -

(crontab -l 2>/dev/null; echo "0 4 * * * sudo clamscan -r / && sudo freshclam") | crontab -

(crontab -l 2>/dev/null; echo "0 5 * * * sudo rkhunter --check") | crontab -

(crontab -l 2>/dev/null; echo "0 6 * * * sudo apt-get update && sudo apt-get upgrade -y && sudo freshclam && sudo rkhunter --update") | crontab -


sudo bash -c 'cat > /etc/timeshift/timeshift.json' <<-'EOF'
{
  "backup_device_uuid" : "",
  "parent_device_uuid" : "",
  "do_first_run" : "true",
  "btrfs_mode" : "false",
  "include_btrfs_home" : "true",
  "stop_cron_emails" : "true",
  "schedule_monthly" : "true",
  "schedule_weekly" : "true",
  "schedule_daily" : "true",
  "schedule_hourly" : "true",
  "schedule_boot" : "true",
  "count_monthly" : "1",
  "count_weekly" : "1",
  "count_daily" : "6",
  "count_hourly" : "1",
  "count_boot" : "1",
  "snapshot_size" : "0",
  "snapshot_count" : "0",
  "exclude" : [
  ],
  "exclude-apps" : [
  ]
}
EOF

# For giggles
sudo apt-get update && sudo apt-get upgrade -y

# Better ui
sudo apt install fonts-powerline
git clone --recursive https://github.com/andresgongora/synth-shell.git
chmod +x synth-shell/setup.sh
cd synth-shell
./setup.sh
