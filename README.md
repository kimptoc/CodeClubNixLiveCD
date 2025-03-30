# CodeClub NixOS LiveCD/USB

A Nix based live CD/USB drive for use in CodeClub sessions.
The windows installs on the PCs are locked down - no headphone support. Also on a timer.  
The live CD means that those things are working.

Steps
* follow NixOS Live CD link below to create the ISO
* remember to switch to using the graphical gnome template.
* copy generated ISO using this command
* sudo dd bs=4M if={path to generated ISO} of=/dev/sd{flash drive} status=progress oflag=sync

Useful links
* https://nixos.wiki/wiki/Creating_a_NixOS_live_CD
* https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix

