# CodeClub NixOS LiveCD/USB

A Nix based live CD/USB drive for use in CodeClub sessions.
The windows installs on the PCs are locked down - no headphone support. Also on a timer.  
The live CD means that those things are working.

Steps
* follow NixOS Live CD link below to create the ISO
* remember to switch to using the graphical gnome template.
* copy generated ISO to your USB using this command:
* sudo dd bs=4M if={path to generated ISO} of=/dev/sd{flash drive} status=progress oflag=sync

Useful links
* LiveCD how to - https://nixos.wiki/wiki/Creating_a_NixOS_live_CD
* Live CD variations - https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix
* packages - https://search.nixos.org/

TODO
* python
* wrong keymap: " (quote), hash and @ sign in wrong places
* no wifi on mac, not issue for CC, just me.
* skip chrome intro, max window, etc, start on boot, open scratch page and maybe others
* resolution ok - test on CC PCs?
* startup sound on boot? Nice to have, might be annoying...
* pin gnome-system-monitor - tried but not working

DONE
* add other browsers - opera, edge
* disable gnome tour
* install nmap for investigations
* chrome installed/pinned
