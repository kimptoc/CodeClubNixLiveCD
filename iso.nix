{ config, pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  services.xserver.desktopManager.gnome = {
    # Add Firefox and other tools useful for installation to the launcher
    favoriteAppsOverride = ''
      [org.gnome.shell]
      favorite-apps=[ 'google-chrome.desktop', 'gnome-system-monitor-kde.desktop', 'firefox.desktop', 'nixos-manual.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop' ]
    '';
    enable = true;
  };

  services.locate.enable = true;
 
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
 
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [  
  terminator
  zsh
  nettools
  python3
  google-chrome
  microsoft-edge
  opera
  vim
  git
  wget
  nmap
  pkgs.gnome-tweaks
  findutils
  ];

  environment.gnome.excludePackages = [ pkgs.gnome-tour ];
}
