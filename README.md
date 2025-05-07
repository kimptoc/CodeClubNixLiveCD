# CodeClub NixOS LiveCD/USB

A Nix based live CD/USB drive for use in CodeClub sessions.
The windows installs on the PCs are locked down - no headphone support. Also on a timer.  
The live CD means that those things are working.

Steps
* follow NixOS Live CD link below to create the ISO
* remember to switch to using the graphical gnome template.
* copy generated ISO to your USB using this command:
* $ sudo dd bs=4M if={path to generated ISO} of=/dev/sd{flash drive} status=progress oflag=sync

Test locally in a VM
* $ nixos-rebuild build-vm -I nixos-config=./iso.nix
* $ ./result/bin/run-nixos-vm

Useful links
* LiveCD how to - https://nixos.wiki/wiki/Creating_a_NixOS_live_CD
* Live CD variations - https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix
* packages - https://search.nixos.org/

TODO
* skip chrome intro, max window, etc, start on boot, open scratch page and maybe others
  * https://discourse.nixos.org/t/automatic-program-start-up-on-login-with-xorg/34261/2
  * https://www.reddit.com/r/NixOS/comments/rezf0s/how_to_run_script_on_startup/
* browser home pages. scratch, CC projects etc. public start me page? https://bit.ly/Codeclubck  (eg xdg-open) use git hub pages
* wrong keymap: " (quote), hash and @ sign in wrong places - maybe just a mac issue? SEEMS fixed, checkin keymap changes.
* turn off suspend
* add printer support
* resolution ok - test on CC PCs?  seems ok
* startup sound on boot? Nice to have, might be annoying...
* system monitor not starting on boot
* pin gnome-system-monitor - tried but not working
* no wifi on mac, not issue for CC, just me.

DONE
* python
* add other browsers - opera, edge
* disable gnome tour
* install nmap for investigations
* chrome installed/pinned
* set timezone. Europe London not utc
