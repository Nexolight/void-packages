#These dirs are created by the package but xbps removes them
mkdir -p /rw
mkdir -p /mnt/removeable
mkdir -p /var/run/qubes
mkdir -p /var/lib/qubes/dom0-updates

#forked xendriverdomain
/usr/bin/xl devd

#oneshot qubes-mount-dirs
/usr/lib/qubes/init/mount-dirs.sh

#not a oneshot
modprobe xen_evtchn
/usr/lib/qubes/qrexec-agent 1>&2 /dev/null &

#oneshot qubes-sysinit
/usr/lib/qubes/init/qubes-sysinit.sh

#oneshot qubes-early-vm-config
/usr/lib/qubes/init/qubes-early-vm-config.sh

#oneshot qubes-iptables
/usr/lib/qubes/init/qubes-iptables start

#Enabled by default for NetVM and ProxyVM
if [ "$(/usr/bin/qubesdb-read /qubes-vm-type)" = "ProxyVM" ] || [ "$(/usr/bin/qubesdb-read /qubes-vm-type)" = "NetVM" ]; then
	#oneshot qubes-network
	/usr/lib/qubes/init/network-proxy-setup.sh
fi

#Enabled by default for ProxyVM
if [ "$(/usr/bin/qubesdb-read /qubes-vm-type)" = "ProxyVM" ]; then
	#not a oneshot
	/usr/bin/qubes-firewall 1>&2 /dev/null &
fi

#Enabled by default for NetVM
if [ "$(/usr/bin/qubesdb-read /qubes-vm-type)" = "NetVM" ]; then
	#not a oneshot
	/usr/bin/qrexec-client-vm '' qubes.UpdatesProxy 1>&2 /dev/null &
fi

#oneshot qubes-updates-proxy
/usr/lib/qubes/iptables-updates-proxy start
/usr/bin/tinyproxy -d -c /etc/tinyproxy/tinyproxy-updates.conf
#/usr/lib/qubes/iptables-updates-proxy stop

#oneshot qubes-update-check
/usr/lib/qubes/upgrades-status-notify

#oneshot qubes-rootfs-resize
/usr/lib/qubes/init/resize-rootfs-if-needed.sh

#oneshot
/usr/bin/qvm-sync-clock 1>&2 /dev/null

#oneshot qubes-misc-post
/usr/lib/qubes/init/misc-post.sh
