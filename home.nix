{ config, pkgs, lib, ... }:


{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  users.defaultUserShell = pkgs.zsh;
  users.users.andrea = {
    uid = 1000;
    isNormalUser = true;
    home = "/home/andrea";
    description = "Andrea Ciceri";
    extraGroups = [ "wheel" "networkmanager" "video" ];
  };

  home-manager.users.andrea = {
    home.packages = import ./packages.nix { inherit pkgs; };

    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      autocd = true;
      plugins = [
        {
          name = "nix-zsh-completions";
          src = pkgs.nix-zsh-completions;
        }
        {
          name = "spaceship";
          src = pkgs.spaceship-prompt;
          file = "share/zsh/themes/spaceship.zsh-theme";
        }
        {
          name = "zsh-syntax-highlighting";
          src = pkgs.zsh-syntax-highlighting;
          file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
        }
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.zsh-nix-shell;
        }
      ];
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "sudo"
          "command-not-found"
          "colored-man-pages"
          "colorize"
        ];
      };
      shellAliases = with pkgs; {
        # "ls" = "${exa}/bin/exa -l";
        "webcam-gphoto2" = "${gphoto2}/bin/gphoto2 --stdout --capture-movie | ffmpeg -i - -vcodec rawvideo -pix_fmt yuv420p -threads 0 -f v4l2 /dev/video0"; # to use my digital camera as a webcam
        "screenshot" = "${scrot}/bin/scrot '~/%F_%T_$wx$h.png' -e 'xclip -selection clipboard -target image/png -i $f' -s";
      };
      localVariables = {
        SPACESHIP_TIME_SHOW = "true";
        SPACESHIP_USER_SHOW = "always";
        SPACESHIP_HOST_SHOW = "always";
        EDITOR = "vim";
        NIX_BUILD_SHELL = "${pkgs.zsh-nix-shell}/scripts/buildShellShim.zsh";
        PROMPT = "\\\${IN_NIX_SHELL:+[nix-shell] }$PROMPT";
      };
    };

    wayland = {
      windowManager.sway =
        let
          modifier = "Mod4";
        in
        {
          enable = true;
          config = {
            inherit modifier;
            keybindings = lib.mkOptionDefault
              {
                "${modifier}+a" = "exec ${pkgs.light}/bin/light -A 5";
                "${modifier}+s" = "exec ${pkgs.light}/bin/light -U 5";
              };
            menu = "${pkgs.bemenu}/bin/bemenu-run -b -m 1";
            fonts = {
              names = [ "Font Awesome" "Fira Code" ];
              size = 11.0;
            };
            terminal = "LIBGL_ALWAYS_SOFTWARE=1 alacritty";
            bars = [{
              command = "${pkgs.waybar}/bin/waybar";
            }];
            startup = [{
              command = "systemctl --user restart redshift";
              always = true;
            }];
            floating = {
              criteria = [
                { title = "MetaMask Notification.*"; }
              ];
            };
          };

          extraConfig = ''
            bindsym ${modifier}+p move workspace to output right
            exec systemctl --user import-environment
            exec systemctl --user start graphical-session.target
            set $laptop "eDP-1"
            bindswitch --reload --locked lid:on output $laptop disable
            bindswitch --reload --locked lid:off output $laptop enable

          '';
          xwayland = true;
          systemdIntegration = false;
        };
    };

    programs.alacritty = {
      enable = true;
      settings = {
        font.normal.family = "Fira Code";
        background_opacity = 0.85;
      };
    };

    programs.firefox = {
      enable = true;
      profiles.andrea = {
        id = 0; # implies isDefault = true
        settings = {
          "browser.startup.homepage" = "https://google.it";
          "browser.search.region" = "IT";
          "browser.search.isUS" = false;
          "distribution.searchplugins.defaultLocale" = "it-IT";
          "general.useragent.locale" = "it-IT";
          "browser.bookmarks.showMobileBookmarks" = true;
          "browser.download.folderList" = 2;
          "browser.download.lastDir" = "/home/andrea/downloads/";
        };
        userChrome = ''
          /* Hide tab bar in FF Quantum * /
          @-moz-document url("chrome://browser/content/browser.xul") {
            #TabsToolbar {
            visibility: collapse !important;
              margin-bottom: 21px !emportant;
            }

            #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
             visibility: collapse !important;
            }
          }
        '';
        userContent = "";
      };
    };

    programs.ssh = {
      enable = true;
      extraConfig = ''
        Host *
        KexAlgorithms +diffie-hellman-group1-sha1
      '';
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      sshKeys = [ "CE2FD0D9BECBD8876811714925066CC257413416" ];
    };

    programs.gpg = {
      enable = true;
    };

    programs.vscode = {
      enable = true;
    };

    programs.fzf = {
      enable = true;
    };

    programs.exa = {
      enable = true;
      enableAliases = true;
    };

    programs.git = rec {
      enable = true;
      userName = "aciceri";
      userEmail = "andrea.ciceri@autistici.org";
      signing = {
        signByDefault = true;
        key = userEmail;
      };
      extraConfig = {
        url = {
          "ssh://git@github.com/" = { insteadOf = https://github.com/; };
        };
      };
    };

    programs.mpv = {
      enable = true;
      config = {
        hwdec = "rkmpp";
        ytdl-format = "bestvideo[height<=1080]+bestaudio/best[height<=1080]";
      };
    };

    programs.zathura = {
      enable = true;
    };

    programs.qutebrowser = {
      enable = true;
      keyBindings = {
        normal = {
          "<Ctrl-v>" = "spawn mpv {url}";
          ",p" = "spawn --userscript qute-pass";
          ",l" = ''config-cycle spellcheck.languages ["en-US"] ["it-IT"]'';
        };
        prompt = {
          "<Ctrl-y>" = "prompt-yes";
        };
      };
    };

    services.gnome-keyring = {
      enable = true;
    };

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      XDG_CURRENT_DESKTOP = "sway";
      XDG_SESSION_TYPE = "wayland";
    };
  };
}
