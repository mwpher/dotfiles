echo '/var/log/denyhosts 			644  7 	   1024 *     J     /var/run/denyhosts.pid' >> /etc/newsyslog.conf
echo "# Log denyhosts messages\nlocal7.info /var/log/wrapper.log" >> /etc/syslog.conf
