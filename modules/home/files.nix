{
  # Keep the legacy tree deployed as before while its contents remain untouched.
  home.file."tilde" = {
    source = ./tilde;
    recursive = true;
  };
}
