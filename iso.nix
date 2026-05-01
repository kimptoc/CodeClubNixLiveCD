{ config, pkgs, lib, ... }:
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

  # We accept xfce4-panel's first-start default layout (apps menu, tasklist,
  # separators, pager, systray, clock, actions, showdesktop + auto-hide
  # bottom dock) and tweak only specific plugins at runtime via
  # xfconf-query (see systemd.user.services.myautostart below). An earlier
  # iteration wrote a full ~/.config/xfce4/xfconf/xfce-perchannel-xml/
  # xfce4-panel.xml, but xfconfd on this live-CD never loaded it
  # (`/panel-1/plugin-ids` stayed absent on the channel even with the file
  # in place) — root cause unknown, pivoted to "accept defaults, patch
  # live" instead.

  # Wrapper for every path that launches Chrome (top-bar launcher, Apps
  # menu's Google Chrome entry, bottom dock's Web Browser button via
  # exo-open). If a Chrome window already exists, focus it instead of
  # opening another window — stops kids flooding the screen with Chrome
  # windows by re-clicking the browser icon.
  #
  # Optional argument $1 = URL (used by exo-open's CommandsWithParameter
  # when the caller is a "%s" invocation — e.g. opening a link from another
  # app). If given AND Chrome is running, we open that URL as a new tab in
  # the focused window. If no URL and Chrome is running, we just focus.
  chromeFocusOrLaunch = pkgs.writeShellScript "chrome-focus-or-launch" ''
    URL="''${1:-https://kimptoc.github.io/CodeClubNixLiveCD/}"
    if ${pkgs.wmctrl}/bin/wmctrl -l 2>/dev/null | grep -iq 'google chrome'; then
      ${pkgs.wmctrl}/bin/wmctrl -a 'Google Chrome' || true
      if [ -n "$1" ]; then
        exec ${pkgs.google-chrome}/bin/google-chrome-stable "$URL"
      fi
      exit 0
    fi
    exec ${pkgs.google-chrome}/bin/google-chrome-stable \
      --disable-fre --no-default-browser-check --no-first-run \
      --hide-crash-restore-bubble --password-store=basic \
      --start-maximized --new-window "$URL"
  '';

  # Custom Chrome launcher with CodeClub homepage.
  # Uses a UNIQUE filename (codeclub-chrome.desktop) so it doesn't collide
  # with the system google-chrome.desktop that XDG lookup would find first.
  codeclubChromeLauncher = pkgs.writeText "codeclub-chrome.desktop" ''
    [Desktop Entry]
    Name=Google Chrome
    Comment=Open CodeClub website
    Exec=${chromeFocusOrLaunch}
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
    Exec=${chromeFocusOrLaunch}
    Icon=google-chrome
    Type=Application
    StartupNotify=true
    Terminal=false
    Categories=Network;WebBrowser;
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
    X-XFCE-Commands=${chromeFocusOrLaunch}
    X-XFCE-CommandsWithParameter=${chromeFocusOrLaunch} "%s"
    X-XFCE-Binaries=${pkgs.google-chrome}/bin/google-chrome-stable
    Icon=google-chrome
    Name=Google Chrome (CodeClub)
    Comment=Open CodeClub website
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
  image.fileName = "codeclub.iso";
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
    initialHashedPassword = lib.mkForce null;
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
setxkbmap us
cat ~/myautostart.log | nc termbin.com 9999
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

      # launcher-4 is the only panel-launcher dir we need — plugin-4 is
      # retyped from pager → launcher at runtime (see myautostart) with
      # items pointing at codeclub-chrome.desktop. xfce4-panel looks up the
      # .desktop file in ~/.config/xfce4/panel/launcher-N/ first, then XDG.
      mkdir -p "$H/.config/xfce4/panel/launcher-4"
      chmod 755 "$H/.config/xfce4" \
                "$H/.config/xfce4/panel" \
                "$H/.config/xfce4/panel/launcher-4"

      cp ${codeclubChromeLauncher} "$H/.config/xfce4/panel/launcher-4/codeclub-chrome.desktop"
      chmod 644 "$H/.config/xfce4/panel/launcher-4/codeclub-chrome.desktop"

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
    wmctrl
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

      # Panel layout is driven entirely by the static xfce4-panel.xml written
      # at activation time (see xfcePanelConfig), which xfconfd reads before
      # xfce4-panel starts. Runtime xfconf-query manipulation on the
      # xfce4-panel channel was racy against the live panel process (popup
      # "plugin '(null)' could not be loaded", plugin types silently reverting
      # to xfce4-panel's first-start defaults) and has been removed.
      #
      # The xsettings/xfwm4/xfce4-desktop channels below are a different
      # matter — those daemons (xfsettingsd, xfwm4, xfdesktop) accept live
      # xfconf updates without the reload/type-reassertion issues the panel
      # has, so keeping runtime sets for them is fine.
      echo "Applying theme + desktop-icons settings..." >> $MYLOG
      sleep 5  # let xfconfd and xfsettingsd fully start

      XQ="${pkgs.xfce.xfconf}/bin/xfconf-query"

      # Accept xfce4-panel's first-start defaults (the xfce4-panel.xml we
      # drop at activation isn't being loaded by xfconfd on this live CD —
      # reason TBD; /panel-1/plugin-ids doesn't exist on the channel even
      # though our XML file is in place). The defaults are:
      #   1 apps | 2 tasklist | 3 sep | 4 pager | 5 sep | 6 systray |
      #   7 sep | 8 clock | 9 sep | 10 actions | 11 showdesktop | 12 sep
      # We tweak only:
      #   - plugin-4: pager → chrome launcher (pager is useless with a
      #     single workspace; repurposing the slot keeps plugin-2's tasklist
      #     intact so kids can still see open apps)
      #   - plugin-8 clock: time-only HH:MM:SS (default shows date+no seconds)
      #   - plugin-10 actions: appearance=1 (username dropdown, already
      #     looks right in the default but set it defensively)
      # These are value/sub-property writes on existing plugins — no -R -r
      # deletes, no plugin-ids changes — so no "(null) plugin" popup.

      $XQ -c xfce4-panel -p /plugins/plugin-4 -s "launcher" 2>>$MYLOG \
        && echo "plugin-4 pager→launcher" >> $MYLOG
      $XQ -c xfce4-panel -p /plugins/plugin-4/items \
        -n --force-array -t string -s "codeclub-chrome.desktop" 2>>$MYLOG \
        && echo "plugin-4/items set" >> $MYLOG

      $XQ -c xfce4-panel -p /plugins/plugin-8/mode                -n -t uint   -s 2          2>>$MYLOG
      $XQ -c xfce4-panel -p /plugins/plugin-8/digital-layout      -n -t uint   -s 3          2>>$MYLOG
      $XQ -c xfce4-panel -p /plugins/plugin-8/digital-time-format -n -t string -s "%H:%M:%S" 2>>$MYLOG
      $XQ -c xfce4-panel -p /plugins/plugin-8/digital-date-format -n -t string -s ""         2>>$MYLOG
      $XQ -c xfce4-panel -p /plugins/plugin-8/digital-format      -n -t string -s "%H:%M:%S" 2>>$MYLOG \
        && echo "plugin-8 clock HH:MM:SS" >> $MYLOG

      $XQ -c xfce4-panel -p /plugins/plugin-10/appearance -n -t uint -s 1 2>>$MYLOG \
        && echo "plugin-10 actions/appearance=1" >> $MYLOG

      # Bottom dock (panel-2) auto-hide: 2 = always hidden, shown on
      # mouse-over. Keeps the desktop uncluttered for kids.
      $XQ -c xfce4-panel -p /panel-2/autohide-behavior -n -t uint -s 2 2>>$MYLOG \
        && echo "panel-2 autohide=2" >> $MYLOG

      # Nudge the panel so plugin-4 picks up its new type and the clock its
      # new format. xfce4-panel --restart talks to the panel over D-Bus
      # (bus name "org.xfce.Panel"); on slow USB boots this myautostart
      # service can run before xfce4-panel has registered that name, and
      # the --restart pops a GTK error dialog "name org.xfce.Panel was not
      # provided by any .service files" (D-Bus has no fallback activation
      # for it — xfce4-session starts the panel, not D-Bus). Wait for the
      # bus name first, and skip --restart if it never appears (the panel
      # will read our xfconf changes when it eventually starts).
      PANEL_READY=0
      for i in $(seq 1 30); do
        if ${pkgs.dbus}/bin/dbus-send --session --print-reply \
             --dest=org.freedesktop.DBus /org/freedesktop/DBus \
             org.freedesktop.DBus.NameHasOwner string:org.xfce.Panel \
             2>/dev/null | grep -q 'boolean true'; then
          PANEL_READY=1
          echo "xfce4-panel D-Bus ready after ~''${i}s" >> $MYLOG
          break
        fi
        sleep 1
      done
      if [ "$PANEL_READY" = 1 ]; then
        ${pkgs.xfce.xfce4-panel}/bin/xfce4-panel --restart >> $MYLOG 2>&1 || true
      else
        echo "xfce4-panel D-Bus not ready after 30s; skipping --restart" >> $MYLOG
      fi

      # Hide all desktop icons (no Home / Filesystem / removable media
      # clutter on the live-CD desktop). style=0 means no icons at all.
      $XQ -c xfce4-desktop -p /desktop-icons/style -n -t int -s 0 2>>$MYLOG \
        && echo "desktop-icons/style=0 set" >> $MYLOG
      ${pkgs.xfce.xfdesktop}/bin/xfdesktop --reload >> $MYLOG 2>&1 || true

      # Apply PRO Dark XFCE theme (GTK + xfwm4 window decorations).
      $XQ -c xsettings -p /Net/ThemeName -n -t string -s "PRO-dark-XFCE-4.14" 2>>$MYLOG \
        && echo "xsettings ThemeName set" >> $MYLOG
      $XQ -c xsettings -p /Gtk/ApplicationPreferDarkTheme -n -t bool -s true 2>>$MYLOG \
        && echo "Gtk ApplicationPreferDarkTheme=true set" >> $MYLOG
      $XQ -c xfwm4 -p /general/theme -n -t string -s "PRO-dark-XFCE-4.14" 2>>$MYLOG \
        && echo "xfwm4 theme set" >> $MYLOG

      # Single workspace
      $XQ -c xfwm4 -p /general/workspace_count -s 1 2>>$MYLOG || true

      # Fetch Bing's daily wallpaper and set it as the desktop background.
      # Bing rotates the image at 00:00 UTC so every CodeClub machine booted
      # on the same day ends up with the same picture. Runs in a background
      # subshell with retries so a slow network doesn't block Chrome launch.
      (
        # Wait for xrandr to enumerate outputs. graphical-session.target can
        # fire before xfce4-session has finished wiring up X outputs, so
        # xrandr may briefly return an empty list — retry for up to ~30s.
        MONITORS=""
        USED_FALLBACK=0
        for w in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
          MONITORS=$(${pkgs.xorg.xrandr}/bin/xrandr --listactivemonitors 2>/dev/null | awk 'NR>1 {print $NF}')
          [ -n "$MONITORS" ] && break
          sleep 2
        done
        # Fall back to a list of common names if xrandr never came up —
        # xfdesktop will just ignore any that don't match a real output.
        if [ -z "$MONITORS" ]; then
          MONITORS="Virtual-1 Virtual1 0 VGA-1 VGA1 HDMI-1 HDMI1 eDP-1 eDP1 DP-1 DP1 LVDS-1 LVDS1"
          USED_FALLBACK=1
        fi
        echo "wallpaper: monitors = [$MONITORS] (fallback=$USED_FALLBACK)" >> $MYLOG
        echo "wallpaper: xrandr --listactivemonitors:" >> $MYLOG
        ${pkgs.xorg.xrandr}/bin/xrandr --listactivemonitors >> $MYLOG 2>&1 || true

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
              # --reload doesn't pick up new /backdrop/*/last-image after
              # xfdesktop has already started with its default (solid colour)
              # — kill and respawn to force a fresh read of xfconf.
              ${pkgs.procps}/bin/pkill -x xfdesktop 2>/dev/null || true
              sleep 2
              ${pkgs.xfce.xfdesktop}/bin/xfdesktop >> $MYLOG 2>&1 &
              echo "wallpaper: set from $WALL_URL (monitors: $MONITORS)" >> $MYLOG
              # Dump final xfconf state for diagnostics — if the wallpaper
              # doesn't show on a real CC PC, this tells us which monitor
              # name xfdesktop is actually using vs what we wrote to.
              sleep 3
              echo "wallpaper: post-restart xrandr:" >> $MYLOG
              ${pkgs.xorg.xrandr}/bin/xrandr --listactivemonitors >> $MYLOG 2>&1 || true
              echo "wallpaper: final /backdrop last-image values:" >> $MYLOG
              for prop in $(${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-desktop -l 2>/dev/null | grep 'last-image$'); do
                val=$(${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-desktop -p "$prop" 2>/dev/null)
                echo "  $prop = $val" >> $MYLOG
              done
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
