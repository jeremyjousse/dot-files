{
  description = "GrM's nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            pkgs.neovim
            pkgs.helix
            pkgs.eza
            pkgs.mas
            pkgs.nixfmt-rfc-style
            pkgs.zoxide
          ];

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          system.defaults = {
            # dock.autohide = true;
            # dock.mru-spaces = false;
            # finder.AppleShowAllExtensions = true;
            # finder.FXPreferredViewStyle = "clmv";
            # loginwindow.LoginwindowText = "devops-toolbox";
            screencapture.location = "~/Pictures/screenshots";
            # screensaver.askForPasswordDelay = 10;
          };

          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 5;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";

          homebrew = {
            enable = true;
            brews = [
              "cowsay"
            ];
          };
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#$(scutil --get LocalHostName)
      darwinConfigurations."FRL-Y65NQL4JTG" = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
      };
      darwinConfigurations."MacBook-Pro-de-Jeremy" = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
      };
    };
}
