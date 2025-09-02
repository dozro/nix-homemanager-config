{
  description = "Home Manager configuration of yu";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nixgl.url = "github:nix-community/nixGL";
    
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, nixgl, fenix, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.x86_64-linux.default = fenix.packages.x86_64-linux.minimal.toolchain;
      homeConfigurations."yu" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        
        #backupFileExtension = "backup";

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ 
	  {
	    nixpkgs = {
	      config = {
		allowUnfree = true;
	      };
	    };
	  }
        
	  { nixpkgs.overlays = [ fenix.overlays.default ]; }
        
	  ./home.nix   
	];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = { inherit nixgl; };
      };
    };
}
