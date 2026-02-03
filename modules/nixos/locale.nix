let
  locale = import ../../lib/locale.nix;
in
{
  i18n.defaultLocale = locale;
  i18n.extraLocaleSettings.LC_MONETARY = locale;
}
