{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.howdy;
  configINI = pkgs.runCommand "config.ini" {} ''
    cat ${cfg.package}/lib/security/howdy/config.ini > $out
    substituteInPlace $out --replace 'device_path = none' 'device_path = ${cfg.device}'
  '';
in


{

  ###### interface

  options = {

    services.howdy = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable howdy and PAM module for face recognition.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.howdy;
        defaultText = "pkgs.howdy";
        description = ''
          Howdy package to use.
        '';
      };

      device = mkOption {
        type = types.path;
        default = "/dev/video0";
        description = ''
          Device file connected to the IR sensor.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];
    environment.etc."howdy/config.ini".source = configINI;

  };

}
