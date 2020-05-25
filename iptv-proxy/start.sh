#!/bin/bash
if [[ ! -e /config/iptv-proxy ]]; then
	mkdir -p /config/iptv-proxy
fi
chown -R ${PUID}:${PGID} /config/iptv-proxy

if [ -z "${PROXY_USER}" ]
then
    PROXY_USER=iptv
fi
echo "[info] Proxy username: ${PROXY_USER}" | ts '%Y-%m-%d %H:%M:%.S'

if [ -z "${PROXY_PASS}" ]
then
    PROXY_PASS=iptv
fi
echo "[info] Proxy password: ${PROXY_PASS}" | ts '%Y-%m-%d %H:%M:%.S'

if [ -z "${PROXY_HOST}" ]
then
    PROXY_HOST=localhost
fi
echo "[info] Proxy host: ${PROXY_HOST}" | ts '%Y-%m-%d %H:%M:%.S'

#echo "[info] Proxy m3u url: ${M3U_URL}" | ts '%Y-%m-%d %H:%M:%.S'
echo "[debug] xtream base url: ${XTREAM_BASE_URL}" | ts '%Y-%m-%d %H:%M:%.S'
echo "[debug] xtream username: ${XTREAM_USERNAME}" | ts '%Y-%m-%d %H:%M:%.S'
echo "[debug] xtream password: ${XTREAM_PASSWORD}" | ts '%Y-%m-%d %H:%M:%.S'
#echo "[debug] Proxy command: 'iptv-proxy --m3u-url ${M3U_URL} --port $WEB_PORT --user $PROXY_USER --password $PROXY_PASS --hostname $PROXY_HOST --custom-endpoint $PROXY_PATH &'" | ts '%Y-%m-%d %H:%M:%.S'
echo "[debug] Proxy command: 'iptv-proxy --xtream-base-url ${XTREAM_BASE_URL} --xtream-user ${XTREAM_USERNAME} --xtream-password ${XTREAM_PASSWORD} --port $IPTV_WEB_PORT --user $PROXY_USER --password $PROXY_PASS --hostname $PROXY_HOST --custom-endpoint $PROXY_PATH &" | ts '%Y-%m-%d %H:%M:%.S'
echo "[info] Starting iptv-proxy daemon..." | ts '%Y-%m-%d %H:%M:%.S'
if [ -z "${PROXY_PATH}" ]
then
    su $PUNAME -c "iptv-proxy --xtream-base-url ${XTREAM_BASE_URL} --xtream-user ${XTREAM_USERNAME} --xtream-password ${XTREAM_PASSWORD} --port $IPTV_WEB_PORT --user $PROXY_USER --password $PROXY_PASS --hostname $PROXY_HOST &"
else
    echo "[info] Proxy path: ${PROXY_PATH}" | ts '%Y-%m-%d %H:%M:%.S'
    su $PUNAME -c "iptv-proxy --xtream-base-url ${XTREAM_BASE_URL} --xtream-user ${XTREAM_USERNAME} --xtream-password ${XTREAM_PASSWORD} --port $IPTV_WEB_PORT --user $PROXY_USER --password $PROXY_PASS --hostname $PROXY_HOST --custom-endpoint $PROXY_PATH &"
fi

sleep 1
iptvproxypid=$(pgrep -o -x iptv-proxy)
echo "[info] IPTV-Proxy PID: $iptvproxypid" | ts '%Y-%m-%d %H:%M:%.S'

if ! [ -e /proc/$iptvproxypid ]
then
	echo "[error] iptv-proxy failed to start!" | ts '%Y-%m-%d %H:%M:%.S'
    exit 1
fi
