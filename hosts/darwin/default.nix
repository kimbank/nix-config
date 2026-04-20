{ pkgs, ... }:

let
  loginUser = "kimbank";
in
{
  imports = [
    ../../modules/darwin/pf.nix
    ../../modules/darwin/home-manager.nix
    ../../modules/shared
  ];

  local.vncFirewall = {
    enable = true;
    allowedCidrs = [
      "100.0.0.0/8"
      "192.168.99.0/24"
    ];
  };

  programs._1password.enable = true;
  programs._1password-gui.enable = false;

  nix = {
    package = pkgs.nix;

    settings = {
      trusted-users = [
        "@admin"
        "${loginUser}"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      substituters = [ "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    };

    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 14d";
    };
  };

  environment.systemPackages = import ../../modules/shared/packages.nix { inherit pkgs; };

  fonts.packages = [
    pkgs."jetbrains-mono"
  ];

  power.sleep.display = 60;

  # 맥북 시작음(boot chime) 음소거 — NVRAM 기반 설정
  system.activationScripts.postActivation.text = ''
    nvram StartupMute=%01
  '';

  system = {
    checks.verifyNixPath = false;
    primaryUser = loginUser;
    stateVersion = 5;

    defaults = {
      LaunchServices = {
        LSQuarantine = false;
      };

      NSGlobalDomain = {
        # AppleEnableMouseSwipeNavigateWithScrolls = false;
        AppleEnableSwipeNavigateWithScrolls = false;
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;
        KeyRepeat = 2;
        InitialKeyRepeat = 15;
        NSAutomaticPeriodSubstitutionEnabled = false;
        "com.apple.sound.beep.volume" = 0.5;
        "com.apple.keyboard.fnState" = true; # F1, F2, ... 키를 기본 기능으로 사용
      };

      CustomUserPreferences = {
        NSGlobalDomain = {
          # Undocumented macOS preference that enables:
          # "Use the Caps Lock key to switch to and from the last used Latin input source".
          # TISRomanSwitchState = 1; # for change input source
        };
        "com.apple.finder" = {
          DesktopViewSettings = {
            IconViewSettings = {
              arrangeBy = "name";
            };
          };
          StandardViewSettings = {
            IconViewSettings = {
              arrangeBy = "name";
            };
          };
          FK_StandardViewSettings = {
            IconViewSettings = {
              arrangeBy = "name";
            };
          };
        };
        "com.apple.WindowManager" = {
          # Controls "Click wallpaper to reveal desktop" on newer macOS releases.
          EnableStandardClickToShowDesktop = false;
        };
        "com.apple.controlcenter" = {
          # Hides the Battery menu bar item while keeping battery prefs declarative.
          "NSStatusItem Visible Battery" = false;
        };
        # Leave Keyboard > Text Input > "Show Input menu in menu bar"
        # unmanaged so manual toggles are not overwritten on rebuild or boot.
      };

      dock = {
        autohide = true;
        show-recents = false;
        orientation = "bottom";
        tilesize = 40;
        wvous-bl-corner = 4; # show desktop
        wvous-br-corner = 1; # Default: do nothing
      };

      controlcenter = {
        BatteryShowPercentage = false;
      };

      finder = {
        # 창 아래 경로 바 표시
        ShowPathbar = true;
        # 하단 상태바 표시
        ShowStatusBar = false;
        #기본 보기 모드: Nlsv = 리스트, clmv = 컬럼, icnv = 아이콘, Flwv = 갤러리
        FXPreferredViewStyle = "clmv";
        # 검색 기본 범위를 “현재 폴더”로
        FXDefaultSearchScope = "SCcf";
        # 새 Finder 창 기본 위치: 바탕화면
        NewWindowTarget = "Desktop";
        # 창 제목에 전체 경로 표시
        _FXShowPosixPathInTitle = true;
        # 이름순 정렬 시 폴더를 위로
        _FXSortFoldersFirst = true;
        # 바탕화면에서도 폴더 먼저
        _FXSortFoldersFirstOnDesktop = true;
        # 숨김 파일 항상 표시
        AppleShowAllFiles = true;
        # 휴지통 30일 후 자동 비움
        # FXRemoveOldTrashItems = true;
        # Finder 종료 메뉴 허용
        QuitMenuItem = true;
      };

      menuExtraClock = {
        IsAnalog = true;
        Show24Hour = true;
        ShowAMPM = false;
        ShowDate = 2;
        ShowDayOfMonth = false;
        ShowDayOfWeek = false;
        ShowSeconds = false;
      };

      trackpad = {
        Clicking = false;
        TrackpadThreeFingerDrag = true;
      };

    };

    keyboard = {
      enableKeyMapping = true;
      # remapCapsLockToControl = true; # for leader vim, wezterm etc.
    };
  };
}
