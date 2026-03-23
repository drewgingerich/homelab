{ config, pkgs, lib, ... }:
let
  qutebrowser = pkgs.qutebrowser.override {
      enableWideVine = true;
  };
in
{
  options.custom.qutebrowser.enable = lib.mkEnableOption "Configure Qutebrowser for this user";

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
      };
      keyBindings = {
        normal = {
          J = "tab-prev";
          K = "tab-next";
      };
      };
    };
  };
}
