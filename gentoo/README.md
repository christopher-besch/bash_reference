# Gentoo Cheatsheet

-   `rc-service sshd start`
-   `ntpd -q -g`
-   ```
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
-   ```
    chroot /mnt/gentoo /bin/bash
    source /etc/profile
    export PS1="(chroot) ${PS1}"
    export TERM=xterm
    set -o vi
    ```
-   `/etc/security/passwdqc.conf`
