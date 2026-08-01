# Per-project dev environment: node + pnpm + postgres + redis.
# `direnv allow` loads the shell; `devenv up` starts the services with
# per-project state under .devenv/state/ (this replaces global brew services).
{ pkgs, ... }:

{
  languages.javascript = {
    enable = true;
    package = pkgs.nodejs_24;
    pnpm.enable = true;
  };

  services.postgres = {
    enable = true;
    # Fall back to postgresql_17 if 18 is not in devenv-nixpkgs rolling yet.
    package = pkgs.postgresql_18;
    initialDatabases = [ { name = "app"; } ];
    listen_addresses = "127.0.0.1";
  };

  services.redis.enable = true;

  env.DATABASE_URL = "postgres://127.0.0.1:5432/app";
  env.REDIS_URL = "redis://127.0.0.1:6379";
}
