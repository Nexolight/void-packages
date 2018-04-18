# Installation

## Warning!
Install this package only if this is a qubesvm!

## Additional steps required

1. Main user must be "user" and be able to sudo without password. It must belong to the qubes group with gid 98.
2. The root partition must be the 3rd partition! (initramfs scripts expect that)
3. Move the /etc/default/grub.qubes to /etc/default/grub
4. Add this to /etc/fstab "xen /proc/xen xenfs defaults 0 0".
5. Do "update-grub".
6. Check that in /boot/grub/grub.cfg the kernelline contains root=/dev/mapper/dmroot! It will trigger the initramfs 
scripts. Otherwise you end up in the dracut rescue terminal.
