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
		hyprland
		foot
		anyrun
		waybar
		pavucontrol # Volume control for waybar

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

	# Declaratively manage config files
	xdg.configFile = {
		"hypr/hyprland.conf".text = ''
			# Basic Hyprland configuration
			# See https://wiki.hyprland.org/Configuring/Keywords/

			# Set programs
			$terminal = foot
			$launcher = anyrun

			# Set monitor and scaling for HiDPI
			monitor=,preferred,auto,2

			# Autostart
			exec-once = waybar &

			# Input settings
			input {
					kb_layout = us
					kb_options = caps:escape
					follow_mouse = 1
			}

			# General settings
			general {
					gaps_in = 5
					gaps_out = 10
					border_size = 2
					col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
					col.inactive_border = rgba(595959aa)
					layout = dwindle
			}

			# Decoration
			decoration {
					rounding = 5
			}

			# Animations
			animations {
					enabled = yes
					bezier = myBezier, 0.05, 0.9, 0.1, 1.05
					animation = windows, 1, 7, myBezier
					animation = border, 1, 10, default
					animation = fade, 1, 7, default
					animation = workspaces, 1, 6, default
			}

			# Keybindings
			# See https://wiki.hyprland.org/Configuring/Binds/
			$mainMod = ALT

			# Launchers
			bind = $mainMod, RETURN, exec, $terminal
			bind = $mainMod, D, exec, $launcher

			# Window management
			bind = $mainMod, Q, killactive,
			bind = $mainMod, M, exit, # Exit Hyprland

			# Move focus
			bind = $mainMod, left, movefocus, l
			bind = $mainMod, right, movefocus, r
			bind = $mainMod, up, movefocus, u
			bind = $mainMod, down, movefocus, d

			# Switch workspaces
			bind = $mainMod, 1, workspace, 1
			bind = $mainMod, 2, workspace, 2
			bind = $mainMod, 3, workspace, 3
			bind = $mainMod, 4, workspace, 4
			bind = $mainMod, 5, workspace, 5

			# Move active window to a workspace
			bind = $mainMod SHIFT, 1, movetoworkspace, 1
			bind = $mainMod SHIFT, 2, movetoworkspace, 2
			bind = $mainMod SHIFT, 3, movetoworkspace, 3
			bind = $mainMod SHIFT, 4, movetoworkspace, 4
			bind = $mainMod SHIFT, 5, movetoworkspace, 5

			# Move/resize windows with mainMod + LMB/RMB and dragging
			bindm = $mainMod, mouse:272, movewindow
			bindm = $mainMod, mouse:273, resizewindow
		'';

		"foot/foot.ini".text = ''
			# Minimal foot terminal config
			font=monospace:size=14
			term=xterm-256color
		'';

		"anyrun/config.ron".text = ''
			Config(
				plugins: [
					"libapplications.so",
					"librink.so",
				]
			)
		'';

		"anyrun/style.css".text = ''
			/* Minimal anyrun style */
			* {
				font-family: monospace;
			}

			#window {
				background-color: #2e3440;
				border-radius: 8px;
				border: 2px solid #4c566a;
			}

			#input {
				background-color: #3b4252;
				color: #d8dee9;
				border-radius: 4px;
				margin: 10px;
			}

			#match-box {
				margin: 0px 10px 10px 10px;
			}

			#match.selected {
				background-color: #434c5e;
				color: #eceff4;
				border-radius: 4px;
			}

			#match {
				color: #d8dee9;
				padding: 5px;
			}

			#match-text {
				padding-left: 5px;
			}
		'';

		"waybar/config".text = ''
			{
				"layer": "top",
				"position": "top",
				"height": 35,
				"modules-left": ["hyprland/workspaces"],
				"modules-center": [],
				"modules-right": ["pipewire", "network", "clock"],
				"hyprland/workspaces": {
						"disable-scroll": true,
						"all-outputs": true,
						"format": "{name}",
						"on-click": "activate"
				},
				"pipewire": {
						"format": "{volume}% {icon}",
						"format-muted": "Muted ",
						"on-click": "pavucontrol",
						"tooltip": false,
						"icons": ["", "", ""]
				},
				"network": {
						"format-wifi": "{essid} ({signalStrength}%) ",
						"format-ethernet": "{ifname} ",
						"format-disconnected": "Disconnected ⚠",
						"tooltip-format": "{ifname} via {gwaddr} ",
						"on-click": "nm-connection-editor"
				},
				"clock": {
						"tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
						"format-alt": "{:%Y-%m-%d}",
						"format": "{:%a %b %d %H:%M}"
				}
			}
		'';

		"waybar/style.css".text = ''
			* {
					border: none;
					border-radius: 0;
					font-family: monospace;
					font-size: 16px;
					min-height: 0;
			}

			window#waybar {
					background: rgba(46, 52, 64, 0.8);
					color: #eceff4;
			}

			#workspaces button {
					padding: 0 10px;
					background: transparent;
					color: #eceff4;
					border-bottom: 2px solid transparent;
			}

			#workspaces button.active {
					border-bottom: 2px solid #88c0d0;
			}

			#workspaces button:hover {
					background: #4c566a;
			}

			#pulseaudio, #network, #clock {
					padding: 0 10px;
			}
		'';
	};
}