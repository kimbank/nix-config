{ ... }:

{
  ".config/nvim".source = ./config/nvim;
  ".config/portainer/compose.yaml".source = ./config/portainer/compose.yaml;
  ".config/wezterm".source = ./config/wezterm;
  # Prefer ` over won-sign in Korean input for Cocoa text-system apps.
  "Library/KeyBindings/DefaultKeyBinding.dict".text = ''
    {
      "₩" = ("insertText:", "`");
      "~₩" = ("insertText:", "₩");
    }
  '';
  "Library/Application Support/Code/User/keybindings.json".source = ./config/vscode/keybindings.json;
  "Library/Application Support/Code/User/settings.json".source = ./config/vscode/settings.json;
}
