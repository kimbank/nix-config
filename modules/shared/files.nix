{
  config,
  repoRoot ? null,
  ...
}:

let
  configPath =
    name:
    if repoRoot == null then
      ./config + "/${name}"
    else
      config.lib.file.mkOutOfStoreSymlink "${repoRoot}/modules/shared/config/${name}";
in
{
  ".config/1Password".source = configPath "1Password";
  ".config/cmux".source = configPath "cmux";
  ".config/dev-infra".source = configPath "dev-infra";
  ".config/git".source = configPath "git";
  ".config/ghostty".source = configPath "ghostty";
  ".config/nvim".source = configPath "nvim";
  ".config/secrets".source = configPath "secrets";
  ".config/ssh".source = configPath "ssh";
  ".config/wezterm".source = configPath "wezterm";
  ".config/worktrunk".source = configPath "worktrunk";
  # Prefer ` over won-sign in Korean input for Cocoa text-system apps.
  "Library/KeyBindings/DefaultKeyBinding.dict".text = ''
    {
      "₩" = ("insertText:", "`");
      "~₩" = ("insertText:", "₩");
    }
  '';
  "Library/Application Support/Code/User".source = configPath "vscode";
}
