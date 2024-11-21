{
  description = "A Nix-flake-based anki-sync-server container";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [ anki-sync-server ];
        };
      });

      packages = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.anki-sync-server;
        docker = pkgs.dockerTools.buildImage {
          name = "cbingman/anki-sync-server";
          tag = "latest";
          config = {
            Cmd = [ "${pkgs.anki-sync-server}/bin/anki-sync-server" ];
          };
        };
      });
    };
}
