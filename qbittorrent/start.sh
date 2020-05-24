#!/bin/bash

QBT_ROOT_DIR=/config/qBittorrent
QBT_CONF_DEST=$QBT_ROOT_DIR/config/qBittorrent.conf

if [[ ! -e /config/qBittorrent ]]; then
	mkdir -p /config/qBittorrent/config/
    mkdir -p /config/qBittorrent/data/logs/
	chown -R ${PUID}:${PGID} /config/qBittorrent
else
	chown -R ${PUID}:${PGID} /config/qBittorrent
fi

if [[ ! -e ${QBT_CONF_DEST} ]]; then
	/bin/cp /etc/qbittorrent/qBittorrent.conf ${QBT_CONF_DEST}
	chmod 666 ${QBT_CONF_DEST}
    chown ${PUID}:${PGID} ${QBT_CONF_DEST}
fi

# Set qBittorrent WebUI and Incoming ports
if [ ! -z "${QBT_WEBUI_PORT}" ]; then
	qbt_webui_port_exist=$(cat ${QBT_CONF_DEST} | grep -m 1 'WebUI\\Port='${QBT_WEBUI_PORT})
	if [[ -z "${qbt_webui_port_exist}" ]]; then
		qbt_webui_exist=$(cat ${QBT_CONF_DEST} | grep -m 1 'WebUI\\Port')
		if [[ ! -z "${qbt_webui_exist}" ]]; then
			# Get line number of WebUI Port
			LINE_NUM=$(grep -Fn -m 1 'WebUI\Port' ${QBT_CONF_DEST} | cut -d: -f 1)
			sed -i "${LINE_NUM}s@.*@WebUI\\Port=${QBT_WEBUI_PORT}@" ${QBT_CONF_DEST}
		else
			echo "WebUI\Port=${QBT_WEBUI_PORT}" >> ${QBT_CONF_DEST}
		fi
	fi
fi

if [ ! -z "${QBT_INCOMING_PORT}" ]; then
	incoming_port_exist=$(cat ${QBT_CONF_DEST} | grep -m 1 'Connection\\PortRangeMin='${QBT_INCOMING_PORT})
	if [[ -z "${incoming_port_exist}" ]]; then
		incoming_exist=$(cat ${QBT_CONF_DEST} | grep -m 1 'Connection\\PortRangeMin')
		if [[ ! -z "${incoming_exist}" ]]; then
			# Get line number of Incoming
			LINE_NUM=$(grep -Fn -m 1 'Connection\PortRangeMin' ${QBT_CONF_DEST} | cut -d: -f 1)
			sed -i "${LINE_NUM}s@.*@Connection\\PortRangeMin=${QBT_INCOMING_PORT}@" ${QBT_CONF_DEST}
		else
			echo "Connection\PortRangeMin=${QBT_INCOMING_PORT}" >> ${QBT_CONF_DEST}
		fi
	fi
fi

echo "[info] Starting qBittorrent daemon..." | ts '%Y-%m-%d %H:%M:%.S'
su $PUNAME -c "/usr/bin/qbittorrent-nox --profile=/config >> /config/qBittorrent/data/logs/qbittorrent-daemon.log 2>&1 &"

sleep 1
qbpid=$(pgrep -o -x qbittorrent-nox)
echo "[info] qBittorrent PID: $qbpid" | ts '%Y-%m-%d %H:%M:%.S'

if [ -e /proc/$qbpid ]; then
	if [[ -e /config/qBittorrent/data/logs/qbittorrent.log ]]; then
		chmod 775 /config/qBittorrent/data/logs/qbittorrent.log
	fi
    echo "[info] set qbittorrent log permissions" | ts '%Y-%m-%d %H:%M:%.S'
else
	echo "qBittorrent failed to start!" | ts '%Y-%m-%d %H:%M:%.S'
    exit 1
fi