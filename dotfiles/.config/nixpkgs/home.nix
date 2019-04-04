{ config, pkgs, ... }:
let
  # for installation, fetch from a url
  dotfiles = /home/jlucas/Dev/nixos/dotfiles;
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
      source = dotfiles + /.config/fish;
      recursive = true; # recursively create subfolders and copy config files
    };
    ".config/i3/config".source = dotfiles + /.config/i3/config;
    ".gitconfig".source = dotfiles + /.gitconfig;
    # user face image (used at least in lightdm prompt)
    ".face".source = dotfiles + /.face;
  };
}
