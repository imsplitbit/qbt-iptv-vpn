#!/bin/bash
if [[ ! -e /config/qBittorrent ]]; then
	mkdir -p /config/qBittorrent/config/
	chown -R ${PUID}:${PGID} /config/qBittorrent
else
	chown -R ${PUID}:${PGID} /config/qBittorrent
fi

if [[ ! -e /config/qBittorrent/config/qBittorrent.conf ]]; then
	/bin/cp /etc/qbittorrent/qBittorrent.conf /config/qBittorrent/config/qBittorrent.conf
	chmod 755 /config/qBittorrent/config/qBittorrent.conf
fi

# Set qBittorrent WebUI and Incoming ports
if [ ! -z "${QBT_WEBUI_PORT}" ]; then
	qbt_webui_port_exist=$(cat /config/qBittorrent/config/qBittorrent.conf | grep -m 1 'WebUI\\Port='${QBT_WEBUI_PORT})
	if [[ -z "${qbt_webui_port_exist}" ]]; then
		qbt_webui_exist=$(cat /config/qBittorrent/config/qBittorrent.conf | grep -m 1 'WebUI\\Port')
		if [[ ! -z "${qbt_webui_exist}" ]]; then
			# Get line number of WebUI Port
			LINE_NUM=$(grep -Fn -m 1 'WebUI\Port' /config/qBittorrent/config/qBittorrent.conf | cut -d: -f 1)
			sed -i "${LINE_NUM}s@.*@WebUI\\Port=${QBT_WEBUI_PORT}@" /config/qBittorrent/config/qBittorrent.conf
		else
			echo "WebUI\Port=${QBT_WEBUI_PORT}" >> /config/qBittorrent/config/qBittorrent.conf
		fi
	fi
fi

if [ ! -z "${QBT_INCOMING_PORT}" ]; then
	incoming_port_exist=$(cat /config/qBittorrent/config/qBittorrent.conf | grep -m 1 'Connection\\PortRangeMin='${QBT_INCOMING_PORT})
	if [[ -z "${incoming_port_exist}" ]]; then
		incoming_exist=$(cat /config/qBittorrent/config/qBittorrent.conf | grep -m 1 'Connection\\PortRangeMin')
		if [[ ! -z "${incoming_exist}" ]]; then
			# Get line number of Incoming
			LINE_NUM=$(grep -Fn -m 1 'Connection\PortRangeMin' /config/qBittorrent/config/qBittorrent.conf | cut -d: -f 1)
			sed -i "${LINE_NUM}s@.*@Connection\\PortRangeMin=${QBT_INCOMING_PORT}@" /config/qBittorrent/config/qBittorrent.conf
		else
			echo "Connection\PortRangeMin=${QBT_INCOMING_PORT}" >> /config/qBittorrent/config/qBittorrent.conf
		fi
	fi
fi

echo "[info] Starting qBittorrent daemon..." | ts '%Y-%m-%d %H:%M:%.S'
/bin/bash /etc/qbittorrent/qbittorrent.init start &
chmod -R 755 /config/qBittorrent

sleep 1
qbpid=$(pgrep -o -x qbittorrent-nox)
echo "[info] qBittorrent PID: $qbpid" | ts '%Y-%m-%d %H:%M:%.S'

if [ -e /proc/$qbpid ]; then
	if [[ -e /config/qBittorrent/data/logs/qbittorrent.log ]]; then
		chmod 775 /config/qBittorrent/data/logs/qbittorrent.log
	fi
else
	echo "qBittorrent failed to start!" | ts '%Y-%m-%d %H:%M:%.S'
    exit 1
fi