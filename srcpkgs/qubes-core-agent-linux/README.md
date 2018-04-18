# Installation

## Warning!
Install this package only if this is a qubesvm!

## Additional steps required

----

!!! Follow the readme of qubes-linux-utils first !!!

----

1. Append these to /etc/rc.local:

/etc/rc.local-qubes/qubes-core-qubesdb/rc.local

/etc/rc.local-qubes/qubes-core-agent-linux/rc.local


2. Enable all qubes-* services
3. Enable the haveged service
4. Enable the qubes-meminfo-writer service
5. Enable xenconsoled and xenstored service
6. Enable the iptables service

