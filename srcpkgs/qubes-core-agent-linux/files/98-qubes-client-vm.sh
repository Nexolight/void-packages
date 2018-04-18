#These dirs are created by the package but xbps removes them
mkdir -p /rw
mkdir -p /mnt/removeable
mkdir -p /var/run/qubes
mkdir -p /var/lib/qubes/dom0-updates
mkdir -p /var/log/qubes

#forked xendriverdomain
/usr/bin/xl devd 2> /var/log/qubes/xendriverdomain.log

#oneshot qubes-mount-dirs
/usr/lib/qubes/init/mount-dirs.sh 2> /var/log/qubes/mount-dirs.log

#not a oneshot
modprobe xen_evtchn
/usr/lib/qubes/qrexec-agent 2> /var/log/qubes/qrexec-agent.log &

#oneshot qubes-sysinit
/usr/lib/qubes/init/qubes-sysinit.sh 2> /var/log/qubes/qubes-sysinit.log

#oneshot qubes-early-vm-config
/usr/lib/qubes/init/qubes-early-vm-config.sh 2> /var/log/qubes/qubes-early-vm-config.log

#oneshot qubes-iptables
/usr/lib/qubes/init/qubes-iptables start 2> /var/log/qubes/qubes-iptables.log

#Enabled by default for NetVM and ProxyVM
if [ "$(/usr/bin/qubesdb-read /qubes-vm-type)" = "ProxyVM" ] || [ "$(/usr/bin/qubesdb-read /qubes-vm-type)" = "NetVM" ]; then
	#oneshot qubes-network
	/usr/lib/qubes/init/network-proxy-setup.sh 2> /var/log/qubes/network-proxy-setup.log
fi

#Enabled by default for ProxyVM
if [ "$(/usr/bin/qubesdb-read /qubes-vm-type)" = "ProxyVM" ]; then
	#not a oneshot
	/usr/bin/qubes-firewall 2> /var/log/qubes/qubes-firewall.log &
fi

#Enabled by default for NetVM
if [ "$(/usr/bin/qubesdb-read /qubes-vm-type)" = "NetVM" ]; then
	#not a oneshot
	/usr/bin/qrexec-client-vm '' qubes.UpdatesProxy 2> /var/log/qubes/qubes-updates-proxy.log &
fi

#oneshot qubes-updates-proxy
/usr/lib/qubes/iptables-updates-proxy start 2> /var/log/qubes/iptables-updates-proxy.log
/usr/bin/tinyproxy -d -c /etc/tinyproxy/tinyproxy-updates.conf 2> /var/log/qubes/tinyproxy.log
/usr/lib/qubes/iptables-updates-proxy stop

#oneshot qubes-update-check
/usr/lib/qubes/upgrades-status-notify 2> /var/log/qubes/upgrades-status-notify.log

#oneshot qubes-rootfs-resize
/usr/lib/qubes/init/resize-rootfs-if-needed.sh 2> /var/log/qubes/resizefs.log

#oneshot
/usr/bin/qvm-sync-clock 2> /var/log/qubes/syncclock.log

#oneshot qubes-misc-post
/usr/lib/qubes/init/misc-post.sh 2> /var/log/qubes/misc.log
