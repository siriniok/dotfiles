{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "zsh-lint";
  version = "1.3.0";
  src = fetchFromGitHub {
    owner = "z-shell";
    repo = "zsh-lint";
    rev = "999cb76cc65ef6af56c0ae65ab0f3622eb527944";
    hash = "sha256-2RmYvJlJdfGcreR5rlZJUfEMSUKy1NnxXnrVuJsOnRY=";
  };
  vendorHash = "sha256-stNMcDQBKxkxvS/9sY3vbYkcB+RKka5FfmiQIOx1bTw=";
  subPackages = [ "cmd/zsh-lint" ];
  meta = {
    description = "Static analysis for Zsh scripts";
    homepage = "https://github.com/z-shell/zsh-lint";
    license = lib.licenses.gpl3Only;
    mainProgram = "zsh-lint";
    platforms = lib.platforms.unix;
  };
}
