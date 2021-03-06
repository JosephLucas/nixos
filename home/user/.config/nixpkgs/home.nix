{ config, pkgs, ... }:
let
  dotfiles_src_dir = ~/Dev/nixos/home/user;
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  # https://www.reddit.com/r/NixOS/comments/9bb9h9/post_your_homemanager_homenix_file/e53r08g?utm_source=share&utm_medium=web2x
  programs.vim = {
    enable = true;
    plugins = [ "vim-airline" "vim-nix" "latex-box" ];
    settings = { 
      ignorecase = true; # ignore case while searching a word
      number = true; # show line numbers
      mouse ="a"; # enable mouse support
    };
    # FIXME : vim sources this extraConfig but vimdiff doesnt for unknown reason
    # ad hoc fix : re-added this extraConfig by hand in ~/.vimrc 
    extraConfig = ''
      colorscheme darkblue
      if &diff
        colorscheme darkblue
      endif
    '';
  };
  home.file = {
    ".config/fish" = {
      source = dotfiles_src_dir + /.config/fish;
      recursive = true; # recursively create subfolders and copy config files
    };
    ".config/i3/config".source = dotfiles_src_dir + /.config/i3/config;
    ".gitconfig".source = dotfiles_src_dir + /.gitconfig;
    ".wallpaper".source = dotfiles_src_dir + /.wallpaper;
  };
}
