{ ageSecrets, config, ... }:

{
  age.secrets.pixelfed-api = ageSecrets.pixelfed-api;
  
  services.pixelfed = {
    enable = true;
    domain = "photo.piergabory.net";
    maxUploadSize = "32M";
    secretFile = config.age.secrets.pixelfed-api.path;
    nginx = {
      forceSSL = true;
      enableACME = true;
    };
    settings = {
      EXP_LOOPS = true;
      PF_NETWORK_TIMELINE = true;
      INSTANCE_DISCOVER_PUBLIC = true;
      INSTANCE_PUBLIC_LOCAL_TIMELINE = true;
      INSTANCE_PUBLIC_HASHTAGS = true;
    };
  };
}
