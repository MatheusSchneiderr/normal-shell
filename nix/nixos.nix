{ pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd /run/current-system/sw/bin/wayfire";
  };
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.swaylock = { };
  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;
  programs.dconf.enable = true;
  services.upower.enable = true;

  programs.wayfire = {
    enable = true;
    plugins = [ pkgs.wayfirePlugins.wayfire-plugins-extra ];
  };

  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  services.printing.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
}
