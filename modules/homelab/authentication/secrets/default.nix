{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.authentication;
  s = file: {
    inherit file;
    owner = "authelia-main";
  };
in
{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  config = mkIf cfg.enable {
    age.secrets = {
      oidc-clients = s ./age/oidc/clients.age;
      oidc-hmac = s ./age/oidc/hmac.age;
      oidc-jwks = s ./age/oidc/jwks.age;
      jwt = s ./age/jwt.age;
      session = s ./age/session.age;
      storage-key = s ./age/storage-key.age;
      users = s ./age/users.age;
    };
  };
}
