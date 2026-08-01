let
  homelabDomain = "pierr.re";
  position = 700;
in
{
  programs.zen-browser.profiles.default.spaces.general.pins."Money" = {
    inherit position;
    id = "money_group";
    isFolderCollapsed = true;
    pins = {
      "Budget" = {
        id = "homelab_budgeting_tool";
        url = "https://budget.${homelabDomain}/budget";
        position = position + 1;
      };
      "Boursobank" = {
        id = "boursobank";
        url = "https://clients.boursobank.com/";
        position = position + 2;
      };
      "Bourso Tradingboard" = {
        id = "bourso_trading";
        url = "https://tradingboard.boursobank.com/";
        position = position + 3;
      };
      "Revolut" = {
        id = "revolut";
        url = "https://app.revolut.com/home";
        position = position + 4;
      };
      "Crédit Agricole" = {
        id = "ca_paris";
        url = "https://espace-client.credit-agricole.fr/ca-paris/particulier/synthese#compte";
        position = position + 5;
      };
      "BNP Paribas Legrand" = {
        id = "bnp_legrand";
        url = "https://monepargne.ere.bnpparibas/accueil";
        position = position + 6;
      };
    };
  };
}
