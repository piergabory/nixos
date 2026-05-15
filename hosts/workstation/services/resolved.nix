# Disabling the DNS server to avoid conflict with PiHole

{ ... }:
{
  services.resolved.enable = false;
}
