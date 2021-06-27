let
home-manager = builtins.fetchGit {
  url = "https://github.com/rycee/home-manager.git";
  rev = "8d3b273afef0e6c3d6d6e4239c9c9d79b1ab6ed7";
  ref = "master";
};
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];
  home-manager.users.seppel = {
    programs.git = {
      enable = true;
      userName = "Sebastian Widua";
      userEmail = "seppel3210@gmail.com";
      delta.enable = true;
      extraConfig = {
        init.defaultBranch = "main";
      };
    };
  };
}
