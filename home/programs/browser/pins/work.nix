let
  position = 100;
in {
  programs.zen-browser.profiles.default = {
    pins = {
      "Merge Requests" = {
        id = "essential_gitlab_netatmo";
        url = "https://gitlab.corp.netatmo.com/dashboard/merge_requests";
        position = 1;
        isEssential = true;
      };
      "Kanban" = {
        id = "essential_jira_kanban";
        url = "https://netatmo.atlassian.net/jira/software/c/projects/CWN/boards/947";
        position = 2;
        isEssential = true;
      };
      "Teams" = {
        id = "essential_work_chat";
        url = "https://teams.microsoft.com/v2/";
        position = 3;
        isEssential = true;
      };
    };

    spaces.general.pins."Work" = {
      inherit position;
      id = "work_group";
      isFolderCollapsed = true;
      pins = {
        "Merge Requests" = {
          id = "gitlab_netatmo";
          url = "https://gitlab.corp.netatmo.com/dashboard/merge_requests";
          position = position + 1;
        };
        "Kanban" = {
          id = "jira_kanban";
          url = "https://netatmo.atlassian.net/jira/software/c/projects/CWN/boards/947";
          position = position + 2;
        };
        "Teams" = {
          id = "work_chat";
          url = "https://teams.microsoft.com/v2/";
          position = position + 3;
        };
      };
    };
  };
}
