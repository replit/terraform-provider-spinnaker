{
  description = "A Terraform provider for Spinnaker";

  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in {
          default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              go 
              gopls
            ];
          };
        });

      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          terraform-provider-spinnaker = pkgs.buildGoModule {
            pname = "terraform-provider-spinnaker";
            version = "0.0.0";

            src = ./.;

            vendorSha256 = "sha256-FiM399YxHM0jhp8RaOqr8cewsxZllk73Rk6U1gkUNhI=";
          };
        });

      defaultPackage = forAllSystems (system: self.packages.${system}.terraform-provider-spinnaker);
    };
}
