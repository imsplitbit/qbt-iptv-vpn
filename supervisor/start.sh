#!/bin/bash

# DEFAULTS
CHECK_INTERVAL=120

if [[ -z "${VPN_ENABLED}" ]]
then
    VPN_ENABLED=no
fi

if [[ -z "${QBT_ENABLED}" ]]
then
    QBT_ENABLED=no
fi

if [[ -z "${IPTV_ENABLED}" ]]
then
    IPTV_ENABLED=no
fi

if [[ -z "${IPTV_WEB_PORT}" ]]
then
    export IPTV_WEB_PORT=8081
fi
echo "[info] IPTV web port defined as ${IPTV_WEB_PORT}" | ts '%Y-%m-%d %H:%M:%.S'

if [[ -z "${QBT_WEB_PORT}" ]]
then
    export QBT_WEB_PORT=8082
fi
echo "[info] qBittorrent web port defined as ${QBT_WEB_PORT}" | ts '%Y-%m-%d %H:%M:%.S'

export VPN_ENABLED=$(echo "${VPN_ENABLED}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')
if [[ ! -z "${VPN_ENABLED}" ]]
then
	echo "[info] VPN_ENABLED defined as '${VPN_ENABLED}'" | ts '%Y-%m-%d %H:%M:%.S'
else
	echo "[warn] VPN_ENABLED not defined,(via -e VPN_ENABLED), defaulting to 'yes'" | ts '%Y-%m-%d %H:%M:%.S'
	export VPN_ENABLED="yes"
fi

# User setup
## Check for missing group
if [[ -z "${PGID}" ]]
then
    export PGID=100
fi
if [[ -z "${PGNAME}" ]]
then
    export PGNAME=mediagroup
fi
/bin/egrep  -i "^${PGID}:" /etc/passwd
if [ $? -eq 0 ]; then
   echo "Group $PGID exists"
else
   echo "Adding $PGID group"
	 groupadd -g $PGID $PGNAME
fi

## Check for missing userid
if [[ -z "${PUID}" ]]
then
    export PUID=99
fi
if [[ -z "${PUNAME}" ]]
then
    export PUNAME=mediauser
fi
/bin/egrep  -i "^${PUID}:" /etc/passwd
if [ $? -eq 0 ]; then
   echo "User $PUID exists in /etc/passwd"
else
   echo "Adding $PUID user"
	 useradd -c "media user" -g $PGID -u $PUID mediauser
fi

# set umask
export UMASK=$(echo "${UMASK}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')
if [[ ! -z "${UMASK}" ]]; then
  echo "[info] UMASK defined as '${UMASK}'" | ts '%Y-%m-%d %H:%M:%.S'
else
  echo "[warn] UMASK not defined (via -e UMASK), defaulting to '002'" | ts '%Y-%m-%d %H:%M:%.S'
  export UMASK="002"
fi

if [[ $VPN_ENABLED = "no" ]] || [[ $VPN_ENABLED = "false" ]]
then
	echo "[warn] !!IMPORTANT!! You have set the VPN to disabled, you will NOT be secure!" | ts '%Y-%m-%d %H:%M:%.S'
else
    /etc/openvpn/start.sh
fi

if [[ $QBT_ENABLED = "yes" ]] || [[ $QBT_ENABLED = "true" ]]
then
    echo "[info] qBittorrent enabled, starting..." | ts '%Y-%m-%d %H:%M:%.S'
    /etc/qbittorrent/start.sh
    echo "[info] qBittorrent started" | ts '%Y-%m-%d %H:%M:%.S'
fi

if [[ $IPTV_ENABLED = "yes" ]] || [[ $IPTV_ENABLED = "true" ]]
then
    echo "[info] iptv-proxy enabled, starting..." | ts '%Y-%m-%d %H:%M:%.S'
    /etc/iptv-proxy/start.sh
    echo "[info] iptv-proxy started" | ts '%Y-%m-%d %H:%M:%.S'
fi

# Begin watch loop
while true
do
    sleep $CHECK_INTERVAL

    if [[ $VPN_ENABLED = "yes" ]] || [[ $VPN_ENABLED = "true" ]]
    then
        openvpnpid=$(pgrep -o -x openvpn)
        echo "[info] openvpn PID: $openvpnpid" | ts '%Y-%m-%d %H:%M:%.S'

        if [ -e /proc/$openvpnpid ]
        then
            pgrep -o -x openvpn 2>&1 > /dev/null
            if [ $? -gt 0 ]
            then
                echo "[error] openvpn died!" | ts '%Y-%m-%d %H:%M:%.S'
                exit 1
            fi
        else
            echo "[error] openvpn failed to start!" | ts '%Y-%m-%d %H:%M:%.S'
            exit 1
        fi
    fi

    if [[ $IPTV_ENABLED = "yes" ]] || [[ $IPTV_ENABLED = "true" ]]
    then
        iptvproxypid=$(pgrep -o -x iptv-proxy)
        echo "[info] IPTV-Proxy PID: $iptvproxypid" | ts '%Y-%m-%d %H:%M:%.S'

        if [ -e /proc/$iptvproxypid ]
        then
            pgrep -o -x iptv-proxy 2>&1 > /dev/null
            if [ $? -gt 0 ]
            then
                echo "[error] iptv-proxy died!" | ts '%Y-%m-%d %H:%M:%.S'
                exit 1
            fi
        else
            echo "[error] iptv-proxy failed to start!" | ts '%Y-%m-%d %H:%M:%.S'
            exit 1
        fi
    fi

    if [[ $QBT_ENABLED = "yes" ]] || [[ $QBT_ENABLED = "true" ]]
    then
        qbtpid=$(pgrep -o -x qbittorrent-nox)
        echo "[info] qbittorrent PID: $qbtpid" | ts '%Y-%m-%d %H:%M:%.S'

        if [ -e /proc/$qbtpid ]
        then
            pgrep -o -x qbittorrent-nox 2>&1 > /dev/null
            if [ $? -gt 0 ]
            then
                echo "[error] qbittorrent died!" | ts '%Y-%m-%d %H:%M:%.S'
                exit 1
            fi
        else
            echo "[error] qbittorrent failed to start!" | ts '%Y-%m-%d %H:%M:%.S'
            exit 1
        fi
    fi
done