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
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          terraform-provider-spinnaker = pkgs.buildGoModule {
            pname = "terraform-provider-spinnaker";
            version = "0.0.0";

            src = ./.;

            vendorSha256 = "sha256-1Cgbw7Edvut8pN0lrvHO39TwA59vl5Yfv3TSJEBIoVE=";
          };
        });

      defaultPackage = forAllSystems (system: self.packages.${system}.terraform-provider-spinnaker);
    };
}
