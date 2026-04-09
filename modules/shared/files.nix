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
  ".config/dev-infra".source = configPath "dev-infra";
  ".config/ghostty".source = configPath "ghostty";
  ".config/nvim".source = configPath "nvim";
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
