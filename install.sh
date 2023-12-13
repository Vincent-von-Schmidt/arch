# arch install script

# format partitions
mkfs.ext4 /dev/sda3 # root
mkfs.fat -F 32 /dev/sda1 # boot
mkswap /dev/sda2 # swap

# mount partitions
mount /dev/sda3 /mnt
mkdir -p /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
swapon /dev/sda2

# install packages
pacstrap /mnt \\
    linux \\
    linux-firmware \\
    base \\
    base-devel \\  # sudo, etc.
    grub \\ # bootloader
    efibootmgr \\ # enables efi boot
    networkmanager \\ # handels the network
    gnome gnome-tweaks \\ # desktop
    git \\
    vim \\ # text editor
    zsh \\ # prompt
    starship \\ # prompt design
    tmux # terminal tilling window manager
    alacritty \\ # terminal emulator

# generate filesystem table
genfstab /mnt > /mnt/etc/fstab

# -- config in new root --

# timezone
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
arch-chroot /mnt hwclock --systohc

# local
arch-chroot /mnt echo "en_US.UTF-8 UTF-8" > /etc/locale.gen 
locale-gen
arch-chroot /mnt echo "LANG=en_US.UTF-8" > /etc/locale.conf 

# keyboard layout
arch-chroot /mnt echo "KEYMAP=de" > /etc/vconsole.conf 

# hostname
arch-chroot /mnt echo "arch" > /etc/hostname 

# hosts
arch-chroot /mnt echo 127.0.0.1 localhost > /etc/hosts

# root passwd -> TODO: does not work
arch-chroot /mnt echo "root:1234" | chpasswd --crypt-method SHA256 

# add user -> TODO: does not work
arch-chroot /mnt useradd -m -G wheel -s /bin/zsh vincent
arch-chroot /mnt echo "vincent:1234" | chpasswd --crypt-method SHA256 

# set sudoerfile -> allow group wheel to use sudo
arch-chroot /mnt echo "%wheel ALL=(ALL) NOPASSWD: ALL" | (EDITOR="tee -a" visudo) 

# enable services
arch-chroot /mnt systemctl enable NetworkManager
arch-chroot /mnt systemctl enable gdm

# grub
arch-chroot /mnt grub-install /dev/sda
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# -----------------------

# copy the config
cp /dotfiles/.zshrc /mnt/home/vincent/.zshrc
cp /dotfiles/.vimrc /mnt/home/vincent/.vimrc
cp -r /dotfiles/.config /mnt/home/vincent/.config

# umount every unused disk
umount -a

# reboot
reboot
