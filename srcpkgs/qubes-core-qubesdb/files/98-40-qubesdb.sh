unset NOTIFY_SOCKET
mkdir -p /var/run/qubes
mkdir -p /var/log/qubes
touch /var/log/qubes/qubesdb.dom0.log
/usr/bin/qubesdb-daemon 0

