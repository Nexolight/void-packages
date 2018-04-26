!!! WARNING !!! 

Make sure your partition setup looks like this:

/dev/xvda1 1M BIOS boot
/dev/xvda2 EFI System
/dev/xvda3 Linux filesystem
/dev/xvda4 Linux swap

especially /dev/xvda3 is hardcoded by the devs in the initramfs!

