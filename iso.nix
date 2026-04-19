{ config, pkgs, ... }:
let
  # Paul Linux Themer's "PRO Dark XFCE Edition" (4.14 variant), fetched
  # direct from GitHub since it isn't in nixpkgs. The repo contains three
  # variants in subdirectories; we install only the XFCE 4.14 one as a
  # theme named "PRO-dark-XFCE-4.14" under $out/share/themes/.
  proDarkXfceTheme = pkgs.stdenvNoCC.mkDerivation {
    pname = "pro-dark-xfce-edition";
    version = "4.14-unstable-2019-10-28";
    src = pkgs.fetchFromGitHub {
      owner = "paullinuxthemer";
      repo = "PRO-Dark-XFCE-Edition";
      rev = "4b3f32f050f6504663a7e8f4038c33818557581a";
      sha256 = "06cw40p52k7qird5g2d74wc8fdsd87fm1jg9dn1dkq42gr6mbbmm";
    };
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/themes
      cp -r "PRO-dark-XFCE-4.14" "$out/share/themes/PRO-dark-XFCE-4.14"

      # The original theme has tiny/missing border images, so windows can
      # only be resized from the top (title bar area).  Create 4px borders
      # on all sides in a matching dark colour so resize handles work
      # everywhere while keeping the dark look.
      XFWM="$out/share/themes/PRO-dark-XFCE-4.14/xfwm4"
      for img in bottom-active bottom-inactive; do
        cat > "$XFWM/$img.xpm" <<'XPM'
/* XPM */
static char *img[] = {
"1 4 1 1",
". c #2d2d2d",
".",".",".","."};
XPM
      done
      for img in left-active left-inactive right-active right-inactive; do
        cat > "$XFWM/$img.xpm" <<'XPM'
/* XPM */
static char *img[] = {
"4 1 1 1",
". c #2d2d2d",
"...."};
XPM
      done
      for img in bottom-left-active bottom-left-inactive bottom-right-active bottom-right-inactive; do
        cat > "$XFWM/$img.xpm" <<'XPM'
/* XPM */
static char *img[] = {
"4 4 1 1",
". c #2d2d2d",
"....","....","....","...."};
XPM
      done
    '';
  };

  # Panel layout:
  #   Panel 1 (top): app-menu | chrome-launcher | tasklist(expand) | systray | clock | session-menu
  #   Panel 2 (bottom dock): <expand> | show-desktop | terminal | files | chrome | appfinder | btop | <expand>
  xfcePanelXml = pkgs.writeText "xfce4-panel.xml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <channel name="xfce4-panel" version="1.0">
      <property name="configver" type="sint" value="2"/>
      <property name="panels" type="array">
        <value type="uint" value="1"/>
        <value type="uint" value="2"/>
      </property>
      <property name="panel-1" type="empty">
        <property name="position" type="string" value="p=6;x=0;y=0"/>
        <property name="length" type="uint" value="100"/>
        <property name="position-locked" type="bool" value="true"/>
        <property name="size" type="uint" value="28"/>
        <property name="plugin-ids" type="array">
          <value type="sint" value="1"/>
          <value type="sint" value="2"/>
          <value type="sint" value="4"/>
          <value type="sint" value="5"/>
          <value type="sint" value="6"/>
          <value type="sint" value="7"/>
        </property>
      </property>
      <property name="panel-2" type="empty">
        <property name="position" type="string" value="p=10;x=0;y=0"/>
        <property name="length" type="uint" value="100"/>
        <property name="position-locked" type="bool" value="true"/>
        <property name="size" type="uint" value="40"/>
        <property name="plugin-ids" type="array">
          <value type="sint" value="10"/>
          <value type="sint" value="11"/>
          <value type="sint" value="12"/>
          <value type="sint" value="13"/>
          <value type="sint" value="14"/>
          <value type="sint" value="15"/>
          <value type="sint" value="16"/>
          <value type="sint" value="17"/>
        </property>
      </property>
      <property name="plugins" type="empty">
        <property name="plugin-1" type="string" value="applicationsmenu"/>
        <property name="plugin-2" type="string" value="launcher">
          <property name="items" type="array">
            <value type="string" value="codeclub-chrome.desktop"/>
          </property>
        </property>
        <property name="plugin-4" type="string" value="tasklist">
          <property name="flat-buttons" type="bool" value="true"/>
          <property name="show-handle" type="bool" value="false"/>
          <property name="grouping" type="uint" value="1"/>
          <property name="expand" type="bool" value="true"/>
        </property>
        <property name="plugin-5" type="string" value="systray"/>
        <property name="plugin-6" type="string" value="clock"/>
        <property name="plugin-7" type="string" value="actions">
          <property name="appearance" type="uint" value="1"/>
        </property>
        <property name="plugin-10" type="string" value="separator">
          <property name="expand" type="bool" value="true"/>
          <property name="style" type="uint" value="0"/>
        </property>
        <property name="plugin-11" type="string" value="showdesktop"/>
        <property name="plugin-12" type="string" value="launcher">
          <property name="items" type="array">
            <value type="string" value="terminal.desktop"/>
          </property>
        </property>
        <property name="plugin-13" type="string" value="launcher">
          <property name="items" type="array">
            <value type="string" value="thunar.desktop"/>
          </property>
        </property>
        <property name="plugin-14" type="string" value="launcher">
          <property name="items" type="array">
            <value type="string" value="codeclub-chrome.desktop"/>
          </property>
        </property>
        <property name="plugin-15" type="string" value="launcher">
          <property name="items" type="array">
            <value type="string" value="appfinder.desktop"/>
          </property>
        </property>
        <property name="plugin-16" type="string" value="launcher">
          <property name="items" type="array">
            <value type="string" value="btop.desktop"/>
          </property>
        </property>
        <property name="plugin-17" type="string" value="separator">
          <property name="expand" type="bool" value="true"/>
          <property name="style" type="uint" value="0"/>
        </property>
      </property>
    </channel>
  '';

  # Custom Chrome launcher with CodeClub homepage.
  # Uses a UNIQUE filename (codeclub-chrome.desktop) so it doesn't collide
  # with the system google-chrome.desktop that XDG lookup would find first.
  codeclubChromeLauncher = pkgs.writeText "codeclub-chrome.desktop" ''
    [Desktop Entry]
    Name=Google Chrome
    Comment=Open CodeClub website
    Exec=${pkgs.google-chrome}/bin/google-chrome-stable --disable-fre --no-default-browser-check --no-first-run --hide-crash-restore-bubble --password-store=basic --start-maximized --new-window https://kimptoc.github.io/CodeClubNixLiveCD/
    Icon=google-chrome
    Type=Application
    StartupNotify=true
    Terminal=false
  '';

  # Override for the system google-chrome.desktop (in ~/.local/share/applications,
  # which takes precedence over /nix/store). This makes the Applications menu's
  # "Google Chrome" entry also open the CodeClub homepage.
  chromeXdgOverride = pkgs.writeText "google-chrome.desktop" ''
    [Desktop Entry]
    Name=Google Chrome
    Comment=Open CodeClub website
    Exec=${pkgs.google-chrome}/bin/google-chrome-stable --disable-fre --no-default-browser-check --no-first-run --hide-crash-restore-bubble --password-store=basic --start-maximized --new-window https://kimptoc.github.io/CodeClubNixLiveCD/
    Icon=google-chrome
    Type=Application
    StartupNotify=true
    Terminal=false
    Categories=Network;WebBrowser;
  '';

  terminalLauncher = pkgs.writeText "terminal-launcher.desktop" ''
    [Desktop Entry]
    Name=Terminal
    Exec=${pkgs.xfce.xfce4-terminal}/bin/xfce4-terminal
    Icon=utilities-terminal
    Type=Application
    Terminal=false
  '';

  thunarLauncher = pkgs.writeText "thunar-launcher.desktop" ''
    [Desktop Entry]
    Name=Files
    Exec=${pkgs.xfce.thunar}/bin/thunar
    Icon=system-file-manager
    Type=Application
    Terminal=false
  '';

  appfinderLauncher = pkgs.writeText "appfinder-launcher.desktop" ''
    [Desktop Entry]
    Name=App Finder
    Exec=${pkgs.xfce.xfce4-appfinder}/bin/xfce4-appfinder
    Icon=xfce4-appfinder
    Type=Application
    Terminal=false
  '';

  # XFCE preferred-application helper (for exo-open --launch WebBrowser,
  # which is what the "Web Browser" entry in the Applications menu uses).
  # We point helpers.rc at this custom helper so the generic Web Browser
  # launcher opens Chrome with the CodeClub URL and our flags.
  codeclubWebBrowserHelper = pkgs.writeText "codeclub-webbrowser.desktop" ''
    [Desktop Entry]
    Version=1.0
    Encoding=UTF-8
    Type=X-XFCE-Helper
    NoDisplay=true
    X-XFCE-Category=WebBrowser
    X-XFCE-Commands=${pkgs.google-chrome}/bin/google-chrome-stable --disable-fre --no-default-browser-check --no-first-run --hide-crash-restore-bubble --password-store=basic --start-maximized --new-window https://kimptoc.github.io/CodeClubNixLiveCD/
    X-XFCE-CommandsWithParameter=${pkgs.google-chrome}/bin/google-chrome-stable --disable-fre --no-default-browser-check --no-first-run --hide-crash-restore-bubble --password-store=basic --start-maximized --new-window "%s"
    X-XFCE-Binaries=${pkgs.google-chrome}/bin/google-chrome-stable
    Icon=google-chrome
    Name=Google Chrome (CodeClub)
    Comment=Open CodeClub website
  '';

  btopPanelLauncher = pkgs.writeText "btop-panel-launcher.desktop" ''
    [Desktop Entry]
    Name=System Monitor (btop)
    Comment=Show CPU, memory, disk, network and processes
    Exec=${pkgs.xfce.xfce4-terminal}/bin/xfce4-terminal --title=System-Monitor --command=${pkgs.btop}/bin/btop
    Icon=utilities-system-monitor
    Type=Application
    Terminal=false
  '';
in
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  # Set the boot label to "codeclub"
  isoImage.isoName = "codeclub.iso";
  isoImage.volumeID = "CODECLUB";
  isoImage.appendToMenuLabel = " CodeClub";

  isoImage.squashfsCompression = "xz";

  # VM-test disk size. This option comes from the qemu-vm module, which is
  # only imported by `nixos-rebuild build-vm` — for the actual ISO build it
  # is a harmless no-op. The default 1 GiB is too small for us (zsh compinit
  # runs, Chrome writes its profile, etc. → "no space left on device" errors
  # in the VM), so bump it to 4 GiB for iteration testing.
  virtualisation.diskSize = 4096;

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  # XFCE desktop with LightDM, auto-login the live CD user.
  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  # No screensaver/lock on a live CD — kids shouldn't be locked out.
  services.xserver.desktopManager.xfce.enableScreensaver = false;
  services.displayManager.defaultSession = "xfce";
  services.xserver.displayManager.lightdm.enable = true;
  services.displayManager.autoLogin = {
    enable = true;
    user = "codeclub";
  };

  # Disable screen blanking and DPMS for the live CD.
  services.xserver.serverFlagsSection = ''
    Option "BlankTime" "0"
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime" "0"
  '';

  # Rename the live CD user from nixos to codeclub.
  users.users.nixos = {
    name = "codeclub";
    home = "/home/codeclub";
    initialPassword = "codeclub";
  };

  # Disable gnome-keyring to prevent wallet prompts (e.g. for wifi passwords).
  services.gnome.gnome-keyring.enable = false;
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  services.xserver = {
    xkb.layout = "gb";
    xkb.variant = "";
  };

  console.keyMap = "uk";

  nixpkgs.config.allowUnfree = true;

  programs.nix-ld.enable = true;

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Create .zshrc for the codeclub user to suppress zsh new-user-install prompt,
  # and seed .zsh_history with a handful of useful commands so kids can
  # up-arrow to them without typing.
  system.activationScripts.nixosZshrc = ''
    if [ ! -f /home/codeclub/.zshrc ]; then
      mkdir -p /home/codeclub
      touch /home/codeclub/.zshrc
    fi
    cat > /home/codeclub/.zsh_history <<'HISTEOF'
kilocode
btop
python3
node
nmap 192.168.1.0/24
HISTEOF
    chmod 600 /home/codeclub/.zsh_history
    chown 1000:100 /home/codeclub/.zshrc /home/codeclub/.zsh_history 2>/dev/null || true
  '';

  # Write XFCE panel config and launcher desktop files before any session starts.
  system.activationScripts.xfcePanelConfig = {
    text = ''
      H=/home/codeclub

      # Ensure $H/.config is owned by codeclub (uid 1000, gid 100 "users").
      # We use numeric IDs because name resolution for "codeclub" fails
      # during activation even with deps=["users"] — chown by name leaves
      # the dir root-owned, then Chrome can't create ~/.config/google-chrome
      # and crashpad dies with "--database is required".
      mkdir -p "$H/.config"
      chown 1000:100 "$H/.config"
      chmod 755 "$H/.config"

      mkdir -p "$H/.config/xfce4/xfconf/xfce-perchannel-xml"
      mkdir -p "$H/.config/xfce4/panel/launcher-2"
      mkdir -p "$H/.config/xfce4/panel/launcher-12"
      mkdir -p "$H/.config/xfce4/panel/launcher-13"
      mkdir -p "$H/.config/xfce4/panel/launcher-14"
      mkdir -p "$H/.config/xfce4/panel/launcher-15"
      mkdir -p "$H/.config/xfce4/panel/launcher-16"
      chmod 755 "$H/.config/xfce4" \
                "$H/.config/xfce4/xfconf" \
                "$H/.config/xfce4/xfconf/xfce-perchannel-xml" \
                "$H/.config/xfce4/panel" \
                "$H/.config/xfce4/panel/launcher-2" \
                "$H/.config/xfce4/panel/launcher-12" \
                "$H/.config/xfce4/panel/launcher-13" \
                "$H/.config/xfce4/panel/launcher-14" \
                "$H/.config/xfce4/panel/launcher-15" \
                "$H/.config/xfce4/panel/launcher-16"

      cp ${xfcePanelXml} "$H/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
      chmod 644 "$H/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"

      cp ${codeclubChromeLauncher} "$H/.config/xfce4/panel/launcher-2/codeclub-chrome.desktop"
      cp ${terminalLauncher}       "$H/.config/xfce4/panel/launcher-12/terminal.desktop"
      cp ${thunarLauncher}         "$H/.config/xfce4/panel/launcher-13/thunar.desktop"
      cp ${codeclubChromeLauncher} "$H/.config/xfce4/panel/launcher-14/codeclub-chrome.desktop"
      cp ${appfinderLauncher}      "$H/.config/xfce4/panel/launcher-15/appfinder.desktop"
      cp ${btopPanelLauncher}      "$H/.config/xfce4/panel/launcher-16/btop.desktop"
      chmod 644 "$H/.config/xfce4/panel/launcher-2/codeclub-chrome.desktop" \
                "$H/.config/xfce4/panel/launcher-12/terminal.desktop" \
                "$H/.config/xfce4/panel/launcher-13/thunar.desktop" \
                "$H/.config/xfce4/panel/launcher-14/codeclub-chrome.desktop" \
                "$H/.config/xfce4/panel/launcher-15/appfinder.desktop" \
                "$H/.config/xfce4/panel/launcher-16/btop.desktop"

      # Point XFCE preferred-app Web Browser at our custom helper (defined
      # below) — the "Web Browser" entry in the Applications menu runs
      # exo-open --launch WebBrowser, which reads this file to decide which
      # helper to invoke.
      echo "WebBrowser=codeclub-webbrowser" > "$H/.config/xfce4/helpers.rc"
      chmod 644 "$H/.config/xfce4/helpers.rc"

      chown -R 1000:100 "$H/.config/xfce4"

      # ~/.local/share/applications overrides so Applications menu + XDG lookup
      # find our custom Chrome launcher (with CodeClub URL) first.
      mkdir -p "$H/.local/share/applications"
      cp ${chromeXdgOverride}      "$H/.local/share/applications/google-chrome.desktop"
      cp ${codeclubChromeLauncher} "$H/.local/share/applications/codeclub-chrome.desktop"
      chmod 644 "$H/.local/share/applications/google-chrome.desktop" \
                "$H/.local/share/applications/codeclub-chrome.desktop"

      # Custom XFCE helper for the Web Browser preferred-app launcher.
      # exo-open looks up helper files in ~/.local/share/xfce4/helpers/ (user)
      # then system dirs. Filename (minus .desktop) is the helper ID that
      # helpers.rc references.
      mkdir -p "$H/.local/share/xfce4/helpers"
      cp ${codeclubWebBrowserHelper} "$H/.local/share/xfce4/helpers/codeclub-webbrowser.desktop"
      chmod 644 "$H/.local/share/xfce4/helpers/codeclub-webbrowser.desktop"

      chown -R 1000:100 "$H/.local"

      # Belt-and-braces: ensure entire home dir is owned by codeclub.
      # Other activation scripts/services may create files under .config
      # as root after our earlier chown — this catches them.
      chown -R 1000:100 /home/codeclub
    '';
    deps = [ "users" ];
  };

  services.locate.enable = true;
  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    btop
    xfce.xfce4-terminal
    nodejs
    terminator
    ghostty
    nettools
    python3
    temurin-bin
    prismlauncher
    google-chrome
    chromium
    vim
    git
    wget
    nmap
    findutils
    gnome-mines
    gnome-mahjongg
    iagno
    aisleriot
    proDarkXfceTheme
  ];

  # Chromium policy (same as Chrome): disable built-in password manager
  environment.etc."chromium/policies/managed/disable-password-manager.json".text = ''
  {
    "PasswordManagerEnabled": false
  }
  '';

  # Chrome policy: disable built-in password manager
  environment.etc."opt/chrome/policies/managed/disable-password-manager.json".text = ''
  {
    "PasswordManagerEnabled": false
  }
  '';

  # Set Google Chrome as the default browser.
  xdg.mime.defaultApplications = {
    "text/html" = "google-chrome.desktop";
    "x-scheme-handler/http" = "google-chrome.desktop";
    "x-scheme-handler/https" = "google-chrome.desktop";
    "x-scheme-handler/about" = "google-chrome.desktop";
    "x-scheme-handler/unknown" = "google-chrome.desktop";
  };

  # PATH additions for npm globals (both login and non-login shells).
  environment.extraInit = ''
    export NPM_CONFIG_PREFIX="$HOME/.cache/npm/global"
    export PATH="$PATH:$HOME/.cache/npm/global/bin"
  '';

  programs.zsh.shellInit = ''
    export NPM_CONFIG_PREFIX="$HOME/.cache/npm/global"
    [[ ":$PATH:" != *":$HOME/.cache/npm/global/bin:"* ]] && export PATH="$PATH:$HOME/.cache/npm/global/bin"
  '';

  systemd.user.services.myautostart = {
    description = "myautostart";
    script = ''
      set +e  # don't exit on errors — log them and keep going
      export MYLOG=$HOME/myautostart.log
      echo "MYAUTOSTART" > $MYLOG
      date >> $MYLOG

      mkdir -p $HOME/.config/autostart
      mkdir -p $HOME/.local/share/applications
      mkdir -p $HOME/.local/bin

      # Note: google-chrome.desktop and codeclub-chrome.desktop overrides are
      # now written at system activation time (see xfcePanelConfig script),
      # so they're in place before the Applications menu builds its cache.

      {
        echo '[Desktop Entry]'
        echo 'Name=Firefox'
        echo "Exec=${pkgs.firefox}/bin/firefox https://kimptoc.github.io/CodeClubNixLiveCD/"
        echo 'StartupNotify=true'
        echo 'Terminal=false'
        echo 'Icon=firefox'
        echo 'Type=Application'
      } > $HOME/.local/share/applications/firefox.desktop

      # btop — override system .desktop to remove ConsoleOnly so it shows in the menu
      {
        echo '[Desktop Entry]'
        echo 'Name=System Monitor (btop)'
        echo 'Comment=Show CPU, memory, disk, network and processes'
        echo "Exec=xfce4-terminal --title=System-Monitor -e ${pkgs.btop}/bin/btop"
        echo 'Icon=utilities-system-monitor'
        echo 'Type=Application'
        echo 'Terminal=false'
        echo 'Categories=System;Monitor;'
      } > $HOME/.local/share/applications/btop.desktop

      # KiloCode launcher wrapper (shows a helpful message while installing)
      {
        echo '#!/usr/bin/env bash'
        echo 'KILO_BIN="$HOME/.cache/npm/global/bin/kilocode"'
        echo 'if [ ! -x "$KILO_BIN" ]; then'
        echo '  echo "KiloCode is still being installed in the background."'
        echo '  echo "Check ~/myautostart.log for progress, then try again."'
        echo '  sleep 4'
        echo '  exit 1'
        echo 'fi'
        echo 'export NPM_CONFIG_PREFIX="$HOME/.cache/npm/global"'
        echo 'export PATH="$PATH:$HOME/.cache/npm/global/bin"'
        echo 'exec "$KILO_BIN" "$@"'
      } > $HOME/.local/bin/kilocode-wrapper
      chmod +x $HOME/.local/bin/kilocode-wrapper

      {
        echo '[Desktop Entry]'
        echo 'Name=KiloCode'
        echo 'Comment=AI Coding Assistant'
        echo "Exec=xfce4-terminal -x $HOME/.local/bin/kilocode-wrapper"
        echo 'Icon=utilities-terminal'
        echo 'Type=Application'
        echo 'Terminal=false'
        echo 'Categories=Development;'
      } > $HOME/.local/share/applications/kilocode.desktop

      # Panel-2 dock setup via xfconf-query.
      # We SET properties directly on the running xfconfd, then restart only
      # the panel (not xfconfd) to pick them up. Guarded by a flag so it
      # only runs once per boot.
      PANEL_FLAG=$HOME/.panel-configured
      if [ ! -f "$PANEL_FLAG" ]; then
        echo "Panel setup starting..." >> $MYLOG
        sleep 5  # let xfce4-panel and xfconfd fully start

        XQ="${pkgs.xfce.xfconf}/bin/xfconf-query"

        $XQ -c xfce4-panel -p /panels >> $MYLOG 2>&1 || echo "xfconfd not ready yet, waiting..." >> $MYLOG
        sleep 2

        # Reset plugin-ids first so we can recreate with correct type (int, not sint)
        $XQ -c xfce4-panel -p /panel-2/plugin-ids -r 2>/dev/null || true
        $XQ -c xfce4-panel -p /panel-2/plugin-ids \
          -n -t int -s 10 -t int -s 11 -t int -s 12 -t int -s 13 \
             -t int -s 14 -t int -s 15 -t int -s 16 -t int -s 17 \
          2>>$MYLOG && echo "panel-2/plugin-ids set OK" >> $MYLOG \
                    || echo "panel-2/plugin-ids FAILED" >> $MYLOG

        # plugin-10: left expand separator
        $XQ -c xfce4-panel -p /plugins/plugin-10 -n -t string -s "separator" 2>>$MYLOG
        $XQ -c xfce4-panel -p /plugins/plugin-10/expand -n -t bool -s true 2>>$MYLOG
        $XQ -c xfce4-panel -p /plugins/plugin-10/style  -n -t uint -s 0    2>>$MYLOG

        # plugin-11: show desktop
        $XQ -c xfce4-panel -p /plugins/plugin-11 -n -t string -s "showdesktop" 2>>$MYLOG

        # plugin-12: terminal launcher
        $XQ -c xfce4-panel -p /plugins/plugin-12 -n -t string -s "launcher" 2>>$MYLOG
        $XQ -c xfce4-panel -p /plugins/plugin-12/items \
          -n --force-array -t string -s "terminal.desktop" 2>>$MYLOG

        # plugin-13: file manager launcher
        $XQ -c xfce4-panel -p /plugins/plugin-13 -n -t string -s "launcher" 2>>$MYLOG
        $XQ -c xfce4-panel -p /plugins/plugin-13/items \
          -n --force-array -t string -s "thunar.desktop" 2>>$MYLOG

        # plugin-14: Chrome launcher (uses unique filename so XDG lookup
        # finds OUR custom .desktop, not the system google-chrome.desktop)
        $XQ -c xfce4-panel -p /plugins/plugin-14 -n -t string -s "launcher" 2>>$MYLOG
        $XQ -c xfce4-panel -p /plugins/plugin-14/items \
          -n --force-array -t string -s "codeclub-chrome.desktop" 2>>$MYLOG

        # plugin-15: app finder launcher
        $XQ -c xfce4-panel -p /plugins/plugin-15 -n -t string -s "launcher" 2>>$MYLOG
        $XQ -c xfce4-panel -p /plugins/plugin-15/items \
          -n --force-array -t string -s "appfinder.desktop" 2>>$MYLOG

        # plugin-16: btop launcher
        $XQ -c xfce4-panel -p /plugins/plugin-16 -n -t string -s "launcher" 2>>$MYLOG
        $XQ -c xfce4-panel -p /plugins/plugin-16/items \
          -n --force-array -t string -s "btop.desktop" 2>>$MYLOG

        # plugin-17: right expand separator
        $XQ -c xfce4-panel -p /plugins/plugin-17 -n -t string -s "separator" 2>>$MYLOG
        $XQ -c xfce4-panel -p /plugins/plugin-17/expand -n -t bool -s true 2>>$MYLOG
        $XQ -c xfce4-panel -p /plugins/plugin-17/style  -n -t uint -s 0    2>>$MYLOG

        # Clock config moved to a later stage — see the clock block below
        # that runs AFTER the panel restart, because the live panel-1 layout
        # diverges from our static XML (xfce4-panel auto-inserts tasklist,
        # pager, and extra separators, reshuffling plugin IDs).

        # Hide all desktop icons (no Home / Filesystem / removable media
        # clutter on the live-CD desktop). style=0 means no icons at all.
        $XQ -c xfce4-desktop -p /desktop-icons/style -n -t int -s 0 2>>$MYLOG \
          && echo "desktop-icons/style=0 set" >> $MYLOG
        ${pkgs.xfce.xfdesktop}/bin/xfdesktop --reload >> $MYLOG 2>&1 || true

        # Apply PRO Dark XFCE theme (GTK + xfwm4 window decorations).
        # xfsettingsd watches these xfconf properties and propagates the
        # change to running GTK apps without needing a logout.
        $XQ -c xsettings -p /Net/ThemeName -n -t string -s "PRO-dark-XFCE-4.14" 2>>$MYLOG \
          && echo "xsettings ThemeName set" >> $MYLOG
        $XQ -c xsettings -p /Gtk/ApplicationPreferDarkTheme -n -t bool -s true 2>>$MYLOG \
          && echo "Gtk ApplicationPreferDarkTheme=true set" >> $MYLOG
        $XQ -c xfwm4 -p /general/theme -n -t string -s "PRO-dark-XFCE-4.14" 2>>$MYLOG \
          && echo "xfwm4 theme set" >> $MYLOG

        echo "xfconf-query panel-2 done, restarting panel..." >> $MYLOG

        ${pkgs.procps}/bin/pkill -x xfce4-panel 2>/dev/null || true
        sleep 1
        ${pkgs.xfce.xfce4-panel}/bin/xfce4-panel &
        sleep 3

        # Clock — show time only in HH:MM:SS, no date line.
        # Runs AFTER the panel restart so that xfconf-query sees the live
        # plugin layout. xfce4-panel auto-inserts tasklist/pager/extra
        # separators into panel-1 regardless of our static XML, which
        # reshuffles plugin IDs, so we discover the clock plugin at runtime
        # by iterating all plugin-N entries and matching type == "clock".
        # mode=2 = digital; digital-layout=3 = time-only layout (XFCE 4.16+).
        CLOCK_PID=""
        for i in 1 2 3 4 5 6 7 8 9 18 19 20 21 22 23 24 25; do
          ptype=$($XQ -c xfce4-panel -p /plugins/plugin-$i 2>/dev/null)
          if [ "$ptype" = "clock" ]; then
            CLOCK_PID="plugin-$i"
            break
          fi
        done
        echo "clock plugin id = $CLOCK_PID" >> $MYLOG
        if [ -n "$CLOCK_PID" ]; then
          $XQ -c xfce4-panel -p /plugins/$CLOCK_PID/mode            -n -t uint   -s 2 2>>$MYLOG
          $XQ -c xfce4-panel -p /plugins/$CLOCK_PID/digital-layout  -n -t uint   -s 3 2>>$MYLOG
          $XQ -c xfce4-panel -p /plugins/$CLOCK_PID/digital-time-format -n -t string -s "%H:%M:%S" 2>>$MYLOG
          $XQ -c xfce4-panel -p /plugins/$CLOCK_PID/digital-date-format -n -t string -s ""        2>>$MYLOG
          $XQ -c xfce4-panel -p /plugins/$CLOCK_PID/digital-format      -n -t string -s "%H:%M:%S" 2>>$MYLOG \
            && echo "clock digital-format set on $CLOCK_PID" >> $MYLOG
          # Nudge the panel to re-read plugin config.
          ${pkgs.xfce.xfce4-panel}/bin/xfce4-panel --restart >> $MYLOG 2>&1 || true
        fi

        touch "$PANEL_FLAG"
        echo "Panel setup done" >> $MYLOG
      fi

      # Single workspace
      ${pkgs.xfce.xfconf}/bin/xfconf-query -c xfwm4 \
        -p /general/workspace_count -s 1 2>>$MYLOG || true

      # Fetch Bing's daily wallpaper and set it as the desktop background.
      # Bing rotates the image at 00:00 UTC so every CodeClub machine booted
      # on the same day ends up with the same picture. Runs in a background
      # subshell with retries so a slow network doesn't block Chrome launch.
      (
        # Wait for xrandr to enumerate outputs. graphical-session.target can
        # fire before xfce4-session has finished wiring up X outputs, so
        # xrandr may briefly return an empty list — retry for up to ~30s.
        MONITORS=""
        for w in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
          MONITORS=$(${pkgs.xorg.xrandr}/bin/xrandr --listactivemonitors 2>/dev/null | awk 'NR>1 {print $NF}')
          [ -n "$MONITORS" ] && break
          sleep 2
        done
        # Fall back to a list of common names if xrandr never came up —
        # xfdesktop will just ignore any that don't match a real output.
        if [ -z "$MONITORS" ]; then
          MONITORS="Virtual-1 Virtual1 0 VGA-1 VGA1 HDMI-1 HDMI1 eDP-1 eDP1 DP-1 DP1 LVDS-1 LVDS1"
        fi
        echo "wallpaper: monitors = [$MONITORS]" >> $MYLOG

        # Wait for network connectivity before trying the Bing API.
        # School/CC networks can take 2-5+ minutes to get DHCP + DNS.
        echo "wallpaper: waiting for network..." >> $MYLOG
        for nw in $(seq 1 60); do
          if ${pkgs.curl}/bin/curl -s --max-time 5 -o /dev/null https://www.bing.com/ 2>/dev/null; then
            echo "wallpaper: network ready after ~$((nw * 5))s" >> $MYLOG
            break
          fi
          sleep 5
        done

        for i in 1 2 3 4 5 6 7 8 9 10; do
          WALL_URL=$(${pkgs.curl}/bin/curl -s --max-time 10 \
            'https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-GB' \
            | ${pkgs.python3}/bin/python3 -c 'import sys,json; d=json.load(sys.stdin); print("https://www.bing.com"+d["images"][0]["url"])' 2>/dev/null)
          if [ -n "$WALL_URL" ]; then
            WALL_FILE="$HOME/Pictures/bing-wallpaper.jpg"
            mkdir -p "$HOME/Pictures"
            if ${pkgs.curl}/bin/curl -s --max-time 30 -o "$WALL_FILE" "$WALL_URL"; then
              # xfdesktop stores the wallpaper at
              # /backdrop/screen0/monitor<NAME>/workspace<N>/last-image
              # — create these explicitly since a fresh home has none.
              for mon in $MONITORS; do
                for ws in 0 1 2 3; do
                  ${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-desktop \
                    -p "/backdrop/screen0/monitor$mon/workspace$ws/last-image" \
                    -n -t string -s "$WALL_FILE" 2>>$MYLOG
                  ${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-desktop \
                    -p "/backdrop/screen0/monitor$mon/workspace$ws/image-style" \
                    -n -t int -s 5 2>>$MYLOG
                done
              done
              # Also sweep any last-image properties xfdesktop may have
              # created by the time we got here (defensive).
              for prop in $(${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-desktop -l 2>/dev/null | grep 'last-image$'); do
                ${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-desktop -p "$prop" -s "$WALL_FILE" 2>>$MYLOG
              done
              ${pkgs.xfce.xfdesktop}/bin/xfdesktop --reload >> $MYLOG 2>&1 || true
              echo "wallpaper: set from $WALL_URL (monitors: $MONITORS)" >> $MYLOG
              break
            fi
          fi
          echo "wallpaper: attempt $i failed, retrying in 15s..." >> $MYLOG
          sleep 15
        done
      ) &

      # Launch Chrome directly — the XDG autostart file approach fails on
      # first boot because the session manager scans autostart before this
      # service has created the file.
      sleep 8
      echo "Launching Chrome..." >> $MYLOG
      ${pkgs.google-chrome}/bin/google-chrome-stable \
        --disable-fre --no-default-browser-check --no-first-run \
        --hide-crash-restore-bubble --password-store=basic \
        --start-maximized \
        https://kimptoc.github.io/CodeClubNixLiveCD/ &
      echo "Chrome launched" >> $MYLOG

      # Install kilocode CLI globally via npm.
      # Wait for network first — on school/CC networks DHCP + DNS can take
      # several minutes after graphical login.
      export NPM_CONFIG_PREFIX="$HOME/.cache/npm/global"
      export PATH="${pkgs.nodejs}/bin:${pkgs.bash}/bin:$PATH"
      mkdir -p "$HOME/.cache/npm/global"
      echo "Installing kilocode CLI — waiting for network..." >> $MYLOG
      for nw in $(seq 1 60); do
        if ${pkgs.curl}/bin/curl -s --max-time 5 -o /dev/null https://registry.npmjs.org/ 2>/dev/null; then
          echo "kilocode: network ready after ~$((nw * 5))s" >> $MYLOG
          break
        fi
        sleep 5
      done
      KILO_INSTALLED=false
      for i in $(seq 1 10); do
        if ${pkgs.nodejs}/bin/npm install -g @kilocode/cli >> $MYLOG 2>&1; then
          echo "kilocode CLI install done (attempt $i)" >> $MYLOG
          KILO_INSTALLED=true
          break
        fi
        echo "kilocode CLI install attempt $i failed, retrying in 15s..." >> $MYLOG
        sleep 15
      done
      if [ "$KILO_INSTALLED" = false ]; then
        echo "ERROR: kilocode CLI install failed after 30 attempts" >> $MYLOG
      fi
      export PATH=$PATH:"$HOME/.cache/npm/global/bin"

      echo "MYAUTOSTART end" >> $MYLOG
      date >> $MYLOG
    '';
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      RemainAfterExit = true;
      PassEnvironment = "DISPLAY XAUTHORITY DBUS_SESSION_BUS_ADDRESS";
    };
  };

  programs.firefox = {
    enable = true;
    policies = {
      PasswordManagerEnabled = false;
      DontCheckDefaultBrowser = true;
      DisablePrivacySegmentation = true;
      NewTabPage = false;

      Homepage = {
        URL = "https://kimptoc.github.io/CodeClubNixLiveCD/";
        Locked = true;
        StartPage = "homepage-locked";
      };

      Preferences = {
        "signon.rememberSignons" = false;
        "signon.autofillForms" = false;
        "signon.generation.enabled" = false;

        "datareporting.policy.dataSubmissionPolicyBypassNotification" = true;
        "browser.aboutwelcome.enabled" = false;
        "browser.startup.homepage_override.mstone" = "ignore";
        "browser.startup.page" = 1;
        "browser.startup.homepage" = "about:home";

        "browser.shell.checkDefaultBrowser" = false;
        "browser.sessionstore.resume_session_once" = false;
        "browser.sessionstore.resume_from_crash" = false;
        "browser.sessionstore.max_resumed_crashes" = 0;
        "browser.startup.couldRestoreSession.count" = -1;

        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      };
    };
  };
}
