# Gentoo Cheatsheet

"fix" passwd complaining
```
min=0,0,0,0,0
max=72
passphrase=0
match=0
simliar=permit

/etc/security/passwdqc.conf
```

start ssh server
```
rc-service sshd start
```

set time and date
```
ntpd -q -g
```

configure disks

extract stage3
```
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
```

prepare chroot
```
mount /dev/sda3 /mnt/gentoo
mount /dev/sda1 /mnt/gentoo/boot
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run 
```

enter chroot
```
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"
export TERM=xterm
set -o vi
```

```
# /dev/sda1
UUID=15F7-55FC                            /boot vfat defaults,noatime 0 2
# /dev/sda2
UUID=eeec9b3b-5adc-425f-a73c-2377bacfc8cb none  swap sw               0 0
# /dev/sda3
UUID=fbd09928-d172-43a9-92e0-2892df275152 /     ext4 noatime          0 1
/etc/fstab
```


/dev/sda1: UUID="15F7-55FC" BLOCK_SIZE="512" TYPE="vfat" PARTUUID="79ada79b-58c7-c64a-91b3-6b73e8a4b9ef"
/dev/sda2: UUID="eeec9b3b-5adc-425f-a73c-2377bacfc8cb" TYPE="swap" PARTUUID="7e663262-9c41-d64b-a126-d864cd3ffc07"
/dev/sda3: UUID="fbd09928-d172-43a9-92e0-2892df275152" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="b91880e0-028c-a34b-ba6d-29f4e8982e9c"
