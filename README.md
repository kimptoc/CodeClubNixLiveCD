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

* focus gnome on chrome app, not in activities overview view (or whatever its called)
* add printer support


DONE
* use direct github pages link and not via bit.ly
* start chrome maximized, I think
* add in the max/min top right window buttons
* * https://www.reddit.com/r/NixOS/comments/wag1ve/recently_installed_nixos_gnome_windows_only_have/
* NOT DONE startup sound on boot? Nice to have, might be annoying...
* NOT DONE system monitor not starting on boot
* NOT DONE pin gnome-system-monitor - tried but not working
* NOT DONE - no wifi on mac, not issue for CC, just me.
* resolution ok - test on CC PCs?  seems ok
* python
* add other browsers - opera, edge
* disable gnome tour
* install nmap for investigations
* chrome installed/pinned
* set timezone. Europe London not utc
* wrong keymap: " (quote), hash and @ sign in wrong places - maybe just a mac issue? SEEMS fixed, checkin keymap changes.
* turn off auto suspend
* make pinned work same as autostart one. use same desktop file
* skip chrome intro, max window, etc, start on boot, open scratch page and maybe others - done, I think
  * https://discourse.nixos.org/t/automatic-program-start-up-on-login-with-xorg/34261/2
  * https://www.reddit.com/r/NixOS/comments/rezf0s/how_to_run_script_on_startup/
* browser home pages. scratch, CC projects etc. public start me page? https://bit.ly/codeclubnxl  (eg xdg-open)  or use github/jekyll pages 




Jekyll site/notes
* bundle exec jekyll serve --baseurl="" --livereload 
* bundle info --path jekyll-theme-minimal
* https://tomcam.github.io/least-github-pages/adding-assets-directory-github-pages.html
* https://docs.github.com/en/pages
* analog clock - https://codepen.io/vaskopetrov/pen/yVEXjz
