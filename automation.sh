s3_bucket="upgrad-ashutosh"
myname="ashutosh"
echo "Updating the packages"
run_sudo=$(sudo apt update -y)
echo "$run_sudo"

echo "installing apache2"
install_apache2=$(sudo apt install apache2 -y)
echo "$install_apache2"

echo "Starting apache2...."
sudo systemctl start apache2


echo "Check if Apache2 is running or not"
if sudo systemctl status apache2 | grep "active (running)"; then
    echo "Apache2 service running"
else
    echo "Apache2 service not running"
fi

timestamp="$(date '+%d%m%Y-%H%M%S')"
filename="/tmp/${myname}-httpd-logs-${timestamp}.tar"


echo "Creating Tar file "

tar -cf ${filename} $( find /var/log/apache2/ -name "*.log")


filesize=$(wc -c $filename | awk '{print $1}')

echo "uploading to S3"
aws s3 cp ${filename} s3://${s3_bucket}/${filename}

echo "uploading to S3 is done"

inventory_file="/var/www/html/inventory.html"

echo "checking the inventory file"

if [[ ! -f $inventory_file ]]; then
    echo "Inventory file is not found hence creating one" 
    sudo touch $inventory_file
    sudo chmod 777 $inventory_file
    sudo echo "Log Type&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Time Created&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Type&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Size<br>" >> $inventory_file
fi

sudo echo "httpd-logs&nbsp;&nbsp;&nbsp;&nbsp;$timestamp&nbsp;&nbsp;&nbsp;&nbsp;tar&nbsp;&nbsp;&nbsp;&nbsp;$filesize Bytes<br>" >> $inventory_file

echo "inventory file is updated"

cron_file="/etc/cron.d/automation"
automation_file="/root/Automation_Project/automation.sh"

echo "checking cron job"

cron_job_exists=$(sudo crontab -l | grep 'automation')

echo "cron job found : $cron_job_exists"

if [[ ! $cron_job_exists ]]; then
	if [[ ! -f  $cron_file ]]; then
		echo "cron_file file is not found hence creating one"
		sudo touch $cron_file
		sudo chmod 777 $cron_file
		sudo echo "00 11 * * * $automation_file" >> $cron_file
	fi

	echo "registering cronjob"
	sudo crontab $cron_file
fi