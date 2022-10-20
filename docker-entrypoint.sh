#!/bin/sh

if [ ! -f app.py ]; then
	git clone -q https://gitcode.net/qq_32394351/dr_py.git .
	rm -rf base/rules.db
	echo "App Initialized"
elif [ -n "$AUTOUPDATE" ]; then
	mv base/rules.db /tmp
	ls -A1 | xargs rm -rf
	git clone -q https://gitcode.net/qq_32394351/dr_py.git .
	mv -f /tmp/rules.db base/rules.db
	echo "App Updated"
fi

if [ ! -f /etc/supervisord.conf ]; then
	cp /etc/supervisord.init /etc/supervisord.conf
	sed -i "s/INET_USERNAME/$INET_USERNAME/g" /etc/supervisord.conf
	sed -i "s/INET_PASSWORD/$INET_PASSWORD/g" /etc/supervisord.conf
	echo "Supervisord Initialized"
fi

exec "$@"
