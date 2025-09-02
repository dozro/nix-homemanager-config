{ config, pkgs, nixgl, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "yu";
  home.homeDirectory = "/home/yu";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  nixGL.packages = nixgl.packages;
  nixGL.defaultWrapper = "mesa";
  nixGL.offloadWrapper = "nvidiaPrime";
  nixGL.installScripts = [ "mesa" "nvidiaPrime" ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # Fonts
    nerd-fonts.fira-code
  
    # Dev tools
    nixd # Nix
    nil
    nixfmt-rfc-style
    #gcc # C/C++
    gnumake
    cmake
    doxygen
    llvm
    clang
    clang-tools
    python3 # Python
    openjdk # Java
    jdt-language-server # Java LSP
    gradle
    (fenix.stable.withComponents [
      # Rust
      "cargo"
      "clippy"
      "rustc"
      "rustfmt"
    ])
    rust-analyzer
    cargo-generate
    cargo-make
    markdown-oxide # Markdown LSP
    espflash # ESP
    dbeaver-bin # Database
    rstudio # R lang IDE

    # Misc
    git-credential-keepassxc
    nix-index
    wget
    git
    git-lfs
    git-credential-keepassxc
    rsync
    jq
    gnupg
    minicom
    screen
    ghostscript
    tldr
    guix
    nvme-cli
    debootstrap
    ncdu

    # Terminal applications
    fastfetch # Fetch system info
    helix # Editor
    htop # System monitor
    depotdownloader # Steam depot downloader

    # Standard desktop applications
    #(config.lib.nixGL.wrappers.mesa kdePackages.dolphin) # File browser
    (config.lib.nixGL.wrappers.mesa kdePackages.ark) # Archive
    #(config.lib.nixGL.wrappers.mesa kdePackages.okular) # Pdf
    (config.lib.nixGL.wrappers.mesa kdePackages.gwenview) # Images
    (config.lib.nixGL.wrappers.mesa mpv) # Video/Audio
    (config.lib.nixGL.wrappers.mesa kdePackages.elisa) # Audio
    #(config.lib.nixGL.wrappers.mesa kdePackages.kcalc) # Calculator
    #(config.lib.nixGL.wrappers.mesa kdePackages.kate) # Editor
    (config.lib.nixGL.wrappers.mesa thunderbird) # E-mail
    (config.lib.nixGL.wrappers.mesa gparted) # Disk partitioning

    # Browser)
    (config.lib.nixGL.wrappers.mesa firefox)
    (config.lib.nixGL.wrappers.mesa vivaldi)
    (config.lib.nixGL.wrappers.mesa vivaldi-ffmpeg-codecs)

    # Graphics
    (config.lib.nixGL.wrappers.mesa gimp)
    (config.lib.nixGL.wrappers.mesa inkscape)
    (config.lib.nixGL.wrappers.mesa krita)

    # Writing / Notes
    (config.lib.nixGL.wrappers.mesa onlyoffice-desktopeditors)
    (config.lib.nixGL.wrappers.mesa libreoffice-qt6)
    (config.lib.nixGL.wrappers.mesa obsidian)

    # Coding
    #jetbrains.clion
    #jetbrains.idea-ultimate
    #vscodium
    (config.lib.nixGL.wrappers.mesa zed-editor)

    # More dekstop applications
    (config.lib.nixGL.wrappers.mesa keepassxc)
    (config.lib.nixGL.wrappers.mesa discord)
    (config.lib.nixGL.wrappers.mesa beeper)
    (config.lib.nixGL.wrappers.mesa glmark2)
    (config.lib.nixGL.wrappers.mesa dolphin-emu)
    (config.lib.nixGL.wrappers.mesa ausweisapp)
    (config.lib.nixGL.wrappers.mesa ausweiskopie)
    (config.lib.nixGL.wrappers.mesa blanket)
    (config.lib.nixGL.wrappers.mesa diebahn)
  ];

  #programs.firefox.nativeMessagingHosts.packages = [
  #  pkgs.kdePackages.plasma-browser-integration
  #q];

  programs.kitty = {
    # Terminal emulator
    enable = true;
    package = config.lib.nixGL.wrappers.mesa pkgs.kitty;
    font.name = "FiraCode Nerd Font";
    font.size = 12;
    themeFile = "Catppuccin-Mocha";
    shellIntegration.enableFishIntegration = true;
    extraConfig = "
            modify_font cell_height 120%
            startup_session startup.session
        ";
  };
  xdg.configFile."kitty/startup.session".text = "
        launch fish
    ";

  programs.fish = { 
    # Shell
    enable = true;
    interactiveShellInit = "
            starship init fish | source
            hyfetch
        ";
  };

  programs.starship = {
    # Shell prompt
    enable = true;
    enableFishIntegration = true;
  };
  xdg.configFile."starship.toml".source = /home/yu/.config/home-manager/starship/pastel-powerline.toml;

  programs.hyfetch = {
    # Fetch system info
    enable = true;
    settings = {
      preset = "nonbinary";
      mode = "rgb";
      lightness = 0.65;
      color_align.mode = "horizontal";
      backend = "fastfetch";
      pride_month_disable = false;
    };
  };

  systemd.user.services.keepassxc-secret-service =
    let
      binPath = "${pkgs.keepassxc}/bin/keepassxc";
    in
    {
      Unit = {
        AssertFileIsExecutable = "${binPath}";
      };
      Service = {
        Type = "dbus";
        ExecStart = "${binPath}";
        BusName = "org.freedesktop.secrets";
        #Name = "org.freedesktop.secrets";
      };
    };
  xdg.dataFile."dbus-1/services/org.freedesktop.secrets.service".source =
    "/home/yu/.config/systemd/user/keepassxc-secret-service.service";
    
  systemd.user.services.ssh-agent = {
    Service = {
      Type = "simple";
      Environment = "SSH_AUTH_SOCK=%t/ssh-agent.socket";
      ExecStart = "/usr/bin/ssh-agent -D -a $SSH_AUTH_SOCK";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  /*
    systemd.user.services.actual-server = {
      enable = true;
      #after = "network.target";
      wantedBy = [ "multi-user.target" ];
      #description = "Actual server";
      serviceConfig = {
        Type = "simple";
        ExecStart = ''ACTUAL_DATA_DIR=/home/yu/.config/actual-server/data ${pkgs.actual-server}/bin/actual-server --config /home/yu/.config/actual-server/config.json'';
      };
    };
  */
  xdg.configFile."actual-server/config.json".source = /home/yu/.config/home-manager/actual-server/config.json;
  xdg.configFile."actual-server/data/.mkdir".text = "";

  home.sessionVariables = {
    #LIBCLANG_PATH = "/home/yu/.rustup/toolchains/esp/xtensa-esp32-elf-clang/esp-17.0.1_20240419/esp-clang/lib";
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent.socket";

  };
  home.sessionPath = [
    "/home/yu/.cargo/bin"
    "/home/yu/.rustup/toolchains/esp/xtensa-esp-elf/esp-13.2.0_20230928/xtensa-esp-elf/bin"
  ];
  /*
    home.activation = {
        gitCredentialKeepassxc = lib.hm.dag.entryAfter ["writeBoundary"] ''
            run git-credential-keepassxc caller add --uid "$(id -u)" --gid "$(id -g)" "$(command -v git)"
        '';
    };
  */

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/yu/etc/profile.d/hm-session-vars.sh
  #

  # Make programs avaible to the foreign system
  programs.bash.enable = true;
  targets.genericLinux.enable = true;
  
  fonts.fontconfig.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
