let
  position = 600;
in
{
  programs.zen-browser.profiles.default.spaces.general.pins."Chat" = {
    inherit position;
    id = "chat_group";
    isFolderCollapsed = true;
    pins = {
      "Discord" = {
        id = "discord_app";
        url = "https://discord.com/channels/@me";
        position = position + 1;
      };
      "Whatsapp" = {
        id = "whatsapp_app";
        url = "https://web.whatsapp.com/";
        position = position + 2;
      };
      "Slack" = {
        id = "slack";
        url = "https://app.slack.com/client/T050TGUED/C050TGUJH";
        position = position + 3;
      };
      "Telegram" = {
        id = "telegram";
        url = "https://web.telegram.org/a/#777000";
        position = position + 4;
      };
      "Linkedin" = {
        id = "linkedin";
        url = "https://www.linkedin.com/mynetwork/grow/";
        position = position + 5;
      };
    };
  };
}
