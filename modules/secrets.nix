{ ... }:

{
  age.secrets = {
    samba-piergabory-homeserver.file = ../secrets/samba-piergabory-homeserver.age;
    # secret_name.file = ../secrets/secrets.age;
  };

  # Then
  # config.age.secrets.secret_name.path
  # Don't evaluate the secret file in nix, always use a password file
}
