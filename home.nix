{ config, pkgs, ... }:

{
	home.username = "oleg";
	home.homeDirectory = "/home/oleg";

	home.packages = with pkgs; [
		neofetch
		ripgrep
		jq
		fzf
		which
		pkgs.gh
		libva-utils # For checking hardware video acceleration (vainfo)

		# archives
		zip
		xz
		unzip
		p7zip
	];

	home.stateVersion = "25.05";

	programs.home-manager.enable = true;

	programs.git = {
		enable = true;
		userName = "Oleg Morfiianets";
		userEmail = "1759220+olegdotcom@users.noreply.github.com";
	};

	programs.gh = {
		enable = true;
		gitCredentialHelper.enable = true;
	};
}
