self: super: with super; {
  boseqc35 = pkgs.stdenv.mkDerivation rec { 
    version = "1.0";
    name = "boseqc35-${version}";
    builder = builtins.toFile "builder.sh" ''
        source $stdenv/setup
        mkdir -p $out/bin
        install $src $out/bin/connect_boseQC35
      '';
    src = fetchurl { 
      url = https://raw.githubusercontent.com/JosephLucas/nixos/master/scripts/connect_boseQC35;
      sha256 = "1d00pfalpx6bj2qblxakipd6p6pjlfp8amf0phrcfmxyb47f695i";
    };
  };
}
