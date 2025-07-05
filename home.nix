{ config, pkgs, ... }:

{
	home.username = "oleg";
	home.homeDirectory = "/home/oleg";

	home.packages = with pkgs; [
		# Core
		neofetch
		ripgrep
		jq
		fzf
		which
		gh
		libva-utils # For checking hardware video acceleration (vainfo)

		# Hyprland ecosystem
		foot
		anyrun
		waybar
		pavucontrol # Volume control for waybar
		networkmanagerapplet
		dconf
		hyprshot

		# CLI Tools
		gemini-cli

		# archives
		zip
		xz
		unzip
		p7zip

		# Note-taking
		xournalpp

		# Media
		imv
		mpv
	];

	home.stateVersion = "25.05";

	programs.home-manager.enable = true;

	programs.chromium = {
	  enable = true;
	  extensions = [
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # DarkReader
	  ];
	};

	programs.git = {
		enable = true;
		userName = "Oleg Morfiianets";
		userEmail = "1759220+olegdotcom@users.noreply.github.com";
	};

	programs.gh = {
		enable = true;
		gitCredentialHelper.enable = true;
	};

	# Set the system-wide color scheme preference to dark.
	# This is the modern way to signal dark mode to apps like Chromium.
	dconf.settings = {
		"org/gnome/desktop/interface" = {
			"color-scheme" = "prefer-dark";
		};
	};

	# Declaratively manage config files
	xdg.configFile = {
		"hypr/hyprland.conf".source = ./dotfiles/hypr/hyprland.conf;
		"foot/foot.ini".source = ./dotfiles/foot/foot.ini;
		"anyrun/config.ron".source = ./dotfiles/anyrun/config.ron;
		"anyrun/style.css".source = ./dotfiles/anyrun/style.css;
		"waybar/config".source = ./dotfiles/waybar/config;
		"waybar/style.css".source = ./dotfiles/waybar/style.css;
	};

	programs.nushell = {
	  enable = true;
	  environmentVariables = {
	    EDITOR = "nvim";
	  };
	};
}
