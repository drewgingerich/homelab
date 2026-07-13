{ inputs, ... }:
{
  flake.homeModules.qutebrowser =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      qutebrowser = pkgs.qutebrowser.override {
        enableWideVine = true;
      };
    in
    {
      options.custom.qutebrowser.enable = lib.mkEnableOption "Qutebrowser";

      config = lib.mkIf config.custom.qutebrowser.enable {
        programs.qutebrowser = {
          enable = true;
          package = qutebrowser;
          searchEngines = {
            DEFAULT = "https://kagi.com/search?q={}";
            udm14 = "https://www.google.com/search?udm=14&q={}";
            ddg = "https://duckduckgo.com/?q={}";
            wp = "https://en.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1";
          };
          settings = {
            url.default_page = "about:blank";
            url.start_pages = "https://smallweb.cc";
            input.insert_mode.auto_load = true;
            tabs.last_close = "startpage";
            content.notifications.enabled = false;
            content.geolocation = false;
            content.media.audio_video_capture = false;
          };
          perDomainSettings = {
            "cbbpdx.civicrm.org" = {
              input.mode_override = "passthrough";
            };
            "cbbpdx.org" = {
              input.mode_override = "passthrough";
            };
            "video.simplepractice.com" = {
              content.media.audio_video_capture = true;
              input.mode_override = "passthrough";
            };
            "principlemind.intakeq.com" = {
              content.media.audio_video_capture = true;
              input.mode_override = "passthrough";
            };
          };
          keyBindings = {
            normal = {
              J = "tab-prev";
              K = "tab-next";
            };
          };
        };
      };
    };

  flake.nixosModules.qutebrowser =
    { ... }:
    {
      home-manager.sharedModules = [ inputs.self.homeModules.qutebrowser ];
    };
}
