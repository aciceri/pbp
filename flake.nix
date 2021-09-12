{
  description = "Pinebook Pro (pnp) configuration";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixpkgs-unstable";
    };
    nixpkgs-with-linux-5-12 = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "755db9a1e9a35c185f7d6c0463025e94ef44622e";
    };
    pinebook-pro = {
      type = "github";
      owner = "samueldr";
      repo = "wip-pinebook-pro";
      ref = "7df87f4f3baecccba79807c291b3bbd62ac61e0f";
      flake = false;
    };
    home-manager = {
      type = "github";
      owner = "rycee";
      repo = "home-manager";
      ref = "master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-with-linux-5-12, pinebook-pro, home-manager, ... }@inputs: {
    nixosConfigurations.pbp =
      let
        system = "aarch64-linux";

      in

      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs =
          {
            pbpKernelLatest = (import nixpkgs-with-linux-5-12 {
              inherit system;
              overlays = [
                (import "${pinebook-pro}/overlay.nix")
              ];
              config.allowUnfree = true;
            }).pkgs.linuxPackages_pinebookpro_latest;
          };

        modules = [
          "${pinebook-pro}/pinebook_pro.nix"
          ./hardware-configuration.nix
          ./system.nix
          ./services.nix
          home-manager.nixosModules.home-manager
          ./home.nix
        ];

      };
  };
}

