self: super: with super; {
  overlayed-pidgin-with-plugins = pkgs.pidgin-with-plugins.override {
    plugins = [ purple-facebook telegram-purple pidgin-opensteamworks ];
  };
}
