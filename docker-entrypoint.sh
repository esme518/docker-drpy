#!/bin/sh
set -e

if [ ! -f app.py ]; then
	git clone --depth 1 -q ${REPO_URL} .
	rm -rf .git* base/rules.db
	echo "App Initialized"
	echo "Version $(cat js/version.txt)"
elif [ -n "$AUTOUPDATE" ] && [ "$AUTOUPDATE" != 0 ]; then
	mv base/rules.db base/直播.txt /tmp
	ls -A1 | xargs rm -rf
	git clone --depth 1 -q ${REPO_URL} .
	rm -rf .git*
	mv -f /tmp/rules.db /tmp/直播.txt base/
	echo "App Updated"
	echo "Version $(cat js/version.txt)"
fi

if [ ! -f /etc/supervisord.conf ]; then
	cp /etc/supervisord.init /etc/supervisord.conf
	sed -i "s/INET_USERNAME/$INET_USERNAME/g" /etc/supervisord.conf
	sed -i "s/INET_PASSWORD/$INET_PASSWORD/g" /etc/supervisord.conf
	echo "Supervisord Initialized"
fi

exec "$@"
