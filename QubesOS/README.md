### QubesOS VM packages for Void


#### Provided packages

* qubes-vm-meta - Meta package which contains everything required.
  * qubes-vmm-xen
  * qubes-core-vchan-xen
  * qubes-core-agent-linux
  * qubes-core-qubesdb
  * qubes-linux-utils-dkms
  * qubes-gui-agent-linux
  * qubes-app-linux-usb-proxy

* qubes-core-vchan-xen-devel
* qubes-gui-common-devel

#### Drawbacks
Runit doesn't play very well with the style the Qubes services are 
meant to be used. It required some hacky workarounds. 

* Early oneshot services are executed in `/etc/runit/core-services/98-qubes-client-vm.sh` at stage 1
* Some normal services are executed as usual runit services at stage 2. 
That's the case for the memory balancer and the gui agent.
However be aware that restarting the gui-agent requires to kill Xorg.
This is done on start and not on stop. It should not affect you on a qubes environment.
* Some oneshot services are executed via `/etc/rc.local` at stage 3

Furthermore the kernel is not suitable for the Qubes gui agent.
That means there's a custom kernel which must either be built or setup on a custom repository and which must be prefered over 
potentially more recent versions from the official repository.


### Installation steps

It might require a few tweaks as the installer isn't too reliable.
You should at least check these things before you proceed to reboot.

#### 0. HVM Setup

* Create a new HVM.
* Set the memory to fixed 4G
* Execute `qvm-prefs <vmname> kernel ""` - Otherwise it will not start
* Use the `void-installer` to install the system on `/dev/xvda`
* Maybe you want also install a logger since void by default doesn't have one. There's a wiki 
entry for that.

Make sure your partition setup looks like this:

```
/dev/xvda1 1M BIOS boot
/dev/xvda2 EFI System
/dev/xvda3 Linux filesystem
/dev/xvda4 Linux swap
```

especially `/dev/xvda3` is hardcoded by the devs in the initramfs!


#### 1. Kernel

You **must** use the kernel from this branch/repository:

`xbps-install --repository=<placeholder> linux<version>-headers linux<version>`

You also need to make sure that updates pulled in do not override that kernel.
Install the kernel updates only from the custom repository!
Otherwise the qubes gui agent wont work

The grub script will automatically detect the required changes in the config
and generate entries for these kernels by doing `update-grub`
after the meta package was installed.


#### 2. The metapackage

`xbps-install --repository=<placeholder> qubes-vm-xen`

This will install everything required.


#### 3. Services and Checks

**Ensure that:**

* `user ALL=(ALL) ALL` is present in `/etc/sudoers`
* `/home/user` does exist and contains the usual skeleton
* The user "user" and group "user" do exist.
* `xen /proc/xen xenfs defaults 0 0` is in `/etc/fstab`
* `/etc/rc.local` is executable and contains the shebang.
  * It should contain a few entries that point to `/etc/rc.local-qubes/qubes-*/rc.local`
* `/etc/runit/core-services/98-qubes-client-vm.sh` is present


**Enable the services:**

```
ln -s /etc/sv/iptables /var/service/
ln -s /etc/sv/haveged /var/service/
ln -s /etc/sv/qubes-meminfo-writer /var/service/
ln -s /etc/sv/qubes-gui-agent /var/service/

optionally:
ln -s /etc/sv/ip6tables /var/service/
ln -s /etc/sv/pulseaudio /var/service/

ln -s /etc/sv/NetworkManager /var/service/
ln -s /etc/sv/dhcpcd /var/service/

```

**Disable the services:**

```
rm -f /var/service/dhcpcd (unconfigured it conflicts with the qubes init)
```


#### 4. Test boot

You may now try a reboot and hope it doesn't end up in the rescue console.
If the boot is successful you should be able to use all the usual qvm commands,
pass devices, use the gui-agent, etc.


#### 5. Finish

You may now change your app VM type to whatever it should be. 
Keep it a HVM type for now. Dynamic memory should now work so you can switch that back.
Set it to minmal 600MB. 400MB may cause OOMs on qubes.
