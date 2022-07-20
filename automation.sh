apt update -y

myname='ashutosh'
s3_bucket='upgrad-ashutosh'
timestamp=$(date '+%d%m%Y-%H%M%S')

if [ $(dpkg --list | grep apache2 | cut -d ' ' -f 3 | head -1) == 'apache2' ]
then
        echo "Apache2 is installed."
        if [[ $(systemctl status apache2 | grep disabled | cut -d ';' -f 2) == ' disabled' ]];
                then
                        systemctl enable apache2
                        echo "Apache2 enabled"
                        systemctl start apache2
                else
                        if [ $(systemctl status apache2 | grep active | cut -d ':' -f 2 | cut -d ' ' -f 2) == 'active' ]
                        then
                                echo "Apache2 is already running"
                        else
                                systemctl start apache2
                                echo "Apache2 started"
                        fi
        fi
else
        printf 'Y\n' | apt-get install apache2
        echo "Apache2 service is installed"
fi



tar -zvcf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log


if [ $(dpkg --list | grep awscli | cut -d ' ' -f 3 | head -1) == 'awscli' ]
        then
                aws s3 \
                cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
                s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

        else
        printf 'Y\n' | apt install awscli
        aws s3 \
        cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
        s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

fi


if [ -f "/var/www/html/inventory.html" ]
        then
                printf "<p>" >> /var/www/html/inventory.html
                printf "\n\t$(ls -lrth /tmp | grep httpd | cut -d ' ' -f 10 | cut -d '-' -f 2,3 | tail -1)" >> /var/www/html/inventory.html
                printf "\t\t$(ls -lrth /tmp | grep httpd | cut -d ' ' -f 10 | cut -d '-' -f 4,5 | cut -d '.' -f 1 | tail -1)" >> /var/www/html/inventory.html
                printf "\t\t\t $(ls -lrth /tmp | grep httpd | cut -d ' ' -f 10 | cut -d '-' -f 4,5 | cut -d '.' -f 2 | tail -1 )" >> /var/www/html/inventory.html
                printf "\t\t\t\t$(ls -lrth /tmp/ | grep httpd | cut -d ' ' -f 6 | tail -1)" >> /var/www/html/inventory.html
                printf "</p>" >> /var/www/html/inventory.html
        else
                touch /var/www/html/inventory.html
                printf "<p>" >> /var/www/html/inventory.html
                printf "\tLog-Type\tDate-Created\tType\tSize" >> /var/www/html/inventory.html
                printf "</p>" >> /var/www/html/inventory.html
                printf "<p>" >> /var/www/html/inventory.html
                printf "\n\t$(ls -lrth /tmp | grep httpd | cut -d ' ' -f 10 | cut -d '-' -f 2,3 | tail -1)" >> /var/www/html/inventory.html
                printf "\t\t$(ls -lrth /tmp | grep httpd | cut -d ' ' -f 10 | cut -d '-' -f 4,5 | cut -d '.' -f 1 | tail -1)" >> /var/www/html/inventory.html
                printf "\t\t\t $(ls -lrth /tmp | grep httpd | cut -d ' ' -f 10 | cut -d '-' -f 4,5 | cut -d '.' -f 2 | tail -1)" >> /var/www/html/inventory.html
                printf "\t\t\t\t$(ls -lrth /tmp/ | grep httpd | cut -d ' ' -f 6 |tail -1)" >> /var/www/html/inventory.html
                printf "</p>" >> /var/www/html/inventory.html
fi



if [ -f "/etc/cron.d/automation" ];
        then
                echo "Automation at 00:00 hrs"
        else
                touch /etc/cron.d/automation
                printf "0 0 * * * root /root/Automation_Project/auotmation.sh" > /etc/cron.d/automation
fi