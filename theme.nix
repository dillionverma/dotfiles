# The Vesper palette, in one place.
#
# Names follow config/vim/vesper.vim, which is the canonical definition. The
# bat theme (config/bat/Vesper.tmTheme) and the oh-my-posh theme
# (config/ohmyposh/vesper.omp.json) carry their own copies because they are
# upstream formats consumed verbatim — this file exists so that colours
# written in Nix are not yet another hand-maintained transcription.
{
  bg = "#101010";
  bgAlt = "#1c1c1c";
  bgFloat = "#232323";
  fg = "#ffffff";
  fgSoft = "#c7c7c7";
  comment = "#7d7d7d";

  mint = "#99ffe4";
  mintSoft = "#a0e9d6";
  orange = "#ffc799";
  red = "#ff8080";
  purple = "#b8a1ff";
  blue = "#8cc2ff";
  yellow = "#ffe6b3";

  # Diff backgrounds: tints of bg dark enough to read syntax highlighting on
  # top of. Only delta uses these.
  diff = {
    minusBg = "#201313";
    minusEmphBg = "#3a1f1f";
    plusBg = "#13211d";
    plusEmphBg = "#1d332b";
    zeroBg = "#151515";
    # Gutter grey, carried over from the pre-Vesper delta config.
    lineNumber = "#565f89";
  };
}
