{ config, pkgs, lib, ... }:
let
  home = config.home.homeDirectory;
  repo = "${home}/normal-shell";
  link = path: config.lib.file.mkOutOfStoreSymlink "${repo}/${path}";
in
{
  systemd.user.targets.wayfire-session = {
    Unit = {
      Description = "Wayfire session";
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };
  };

  xdg.configFile."wayfire/edge-focus.lua".source = link "compositor/edge-focus.lua";
  xdg.configFile."wayfire/workspace-watch.lua".source = link "compositor/workspace-watch.lua";
  xdg.configFile."wayfire/window.lua".source = link "compositor/window.lua";
  xdg.configFile."wayfire/wfipc.lua".source = link "compositor/wfipc.lua";
  xdg.configFile."wayfire.ini".text =
    builtins.replaceStrings [ "@home@" ] [ home ] (builtins.readFile ../compositor/wayfire.ini);

  xdg.configFile."quickshell/panel".source = link "quickshell";
  xdg.configFile."quickshell/theme.json".source = link "quickshell/theme.json";

  xdg.configFile."xdg-desktop-portal-wlr/config".text = ''
    [screencast]
    chooser_type=dmenu
    chooser_cmd=${home}/.config/quickshell/panel/modules/screencast/portal-pick
  '';
  xdg.configFile."systemd/user/xdg-desktop-portal-wlr.service.d/quickshell-picker.conf".text = ''
    [Service]
    ExecStart=
    ExecStart=${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr --config=%h/.config/xdg-desktop-portal-wlr/config
  '';

  services.cliphist.enable = true;
  services.polkit-gnome.enable = true;

  services.swayidle = {
    enable = true;
    timeouts = [
      { timeout = 300; command = "${pkgs.quickshell}/bin/quickshell -c panel ipc call lock lock"; }
      { timeout = 600; command = "${pkgs.systemd}/bin/systemctl suspend"; }
    ];
    events.before-sleep = "${pkgs.quickshell}/bin/quickshell -c panel ipc call lock lock";
  };

  systemd.user.services.swaybg = {
    Unit = {
      Description = "Wallpaper";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${home}/Pictures/wallpaper.jpg -m fill";
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  home.packages = with pkgs; [
    quickshell
    (lua5_4.withPackages (ps: [ ps.luasocket ps.cjson ]))
    papirus-icon-theme
    thunar
    foot
    brightnessctl
    networkmanagerapplet
    grim
    slurp
    swappy
    wlr-randr
    pulseaudio
  ];
}
