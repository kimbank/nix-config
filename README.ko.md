[English](README.md) | 한국어

# Kimbank Nix Config

macOS 우선 Nix 설정으로, `nixos-config` 참고 레포지토리와 동일한 상위 레이아웃을 따릅니다.

## 디렉토리 구조

```text
.
├── flake.nix
├── apps/
│   └── aarch64-darwin/       # `nix run .#...` 헬퍼 스크립트
│       ├── apply
│       ├── build
│       ├── build-switch
│       ├── clean
│       ├── rollback
│       └── update-homebrew
├── hosts/
│   └── darwin/
│       └── default.nix       # 호스트 수준 nix-darwin 엔트리포인트
├── modules/
│   ├── darwin/               # macOS 전용 패키지, 파일, Dock, Homebrew
│   │   ├── casks.nix
│   │   ├── dock/
│   │   │   └── default.nix
│   │   ├── files.nix
│   │   ├── home-manager.nix
│   │   ├── pf.nix
│   │   └── packages.nix
│   └── shared/               # 공유 패키지, 셸 설정, 파일
│       ├── config/           # 이 레포에서 관리하는 앱 설정 트리
│       │   ├── dev-infra/
│       │   │   ├── README.md
│       │   │   ├── compose.yml
│       │   │   ├── mysql/
│       │   │   │   └── Dockerfile
│       │   │   └── mysql-init/
│       │   │   │   └── 001-admin-superuser.sql
│       │   ├── ghostty/
│       │   ├── nvim/
│       │   ├── vscode/
│       │   └── wezterm/
│       ├── pkgs/             # nixpkgs에 없는 소규모 로컬 패키지
│       │   └── im-select.nix
│       ├── default.nix
│       ├── files.nix
│       ├── home-manager.nix
│       └── packages.nix
└── overlays/
    ├── README.md
    └── ytsurf.nix
```

## macOS 설치

이 레포지토리는 현재 Nix 시스템 문자열 `aarch64-darwin`의 Apple Silicon macOS를 대상으로 합니다.

### 1. 의존성 설치

```sh
xcode-select --install
```

### 2. Nix 설치

```sh
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```

설치 후 새 터미널을 열어 `nix`가 `PATH`에서 사용 가능한지 확인합니다.

### 3. flakes 및 nix-command 활성화

`/etc/nix/nix.conf`에 다음을 추가합니다:

```conf
experimental-features = nix-command flakes
```

또는 아래와 같이 사용합니다:

```sh
nix --extra-experimental-features 'nix-command flakes' <command>
# 예시
# nix --extra-experimental-features 'nix-command flakes' run .#build-switch
```

문제 해결: nix를 찾을 수 없는 경우

```sh
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix --extra-experimental-features 'nix-command flakes' run .#build-switch
```

### 4. 이 레포지토리 클론

클론 경로는 중요하지 않습니다. 레포지토리 루트에서 명령을 실행하기만 하면 됩니다.

예시:

```sh
cd ~
git clone https://github.com/kimbank/nix-config.git
# 또는 SSH
# git clone git@github.com:kimbank/nix-config.git
cd nix-config
```

### 5. Git 사용자 정보 설정

`nix run .#apply`는 현재 `git user.name`과 `git user.email`을 읽어 이 레포지토리에 반영합니다.

```sh
git config --global user.name "이름"
git config --global user.email "이메일@example.com"
```

### 6. 올바른 macOS 로그인 사용자로 apply 실행

`apply`는 `whoami`로 현재 macOS 로그인 계정을 사용합니다.

- Nix로 관리하려는 실제 macOS 계정으로 로그인합니다.
- 그런 다음 레포지토리 루트에서 `apply`를 실행합니다.
- macOS 계정이 `kimbank`라면, `kimbank`로 로그인한 상태에서 실행합니다.

```sh
nix run .#apply
```

`apply`가 업데이트하는 항목:

- macOS 로그인 사용자명
- git 사용자 이름
- git 사용자 이메일

### 7. 패키지 검토

[NixOS Search](https://search.nixos.org/packages)에서 패키지를 검색합니다.

다음 파일들을 검토합니다:

- `modules/shared/packages.nix`
- `modules/darwin/packages.nix`
- `modules/darwin/casks.nix`

패키지 분류:

- 공유 CLI 패키지: `modules/shared/packages.nix`
- 소규모 로컬 공유 패키지: `modules/shared/pkgs/`
- macOS 전용 Nix 패키지: `modules/darwin/packages.nix`
- Homebrew 포뮬러: `modules/darwin/home-manager.nix`
- Homebrew 캐스크: `modules/darwin/casks.nix`
- Claude Code CLI: `modules/darwin/casks.nix`의 `claude-code@latest`
- Screen Sharing/VNC용 macOS PF 규칙: `modules/darwin/pf.nix`
- JetBrains IDE: `jetbrains-toolbox`를 캐스크로 설치 후 Toolbox에서 IDE 설치 및 업데이트 관리

### 8. 셸 설정 검토

이 설정은 Home Manager를 통해 셸을 관리합니다. 다음을 검토합니다:

- `modules/shared/home-manager.nix`
- `modules/darwin/home-manager.nix`
- `modules/shared/config/ghostty`: Ghostty 및 `cmux`가 `~/.config/ghostty/config`에서 읽는 터미널 테마 설정

JetBrains Toolbox 사용자는 Toolbox 셸 스크립트를 활성화하여 `webstorm`, `datagrip` 같은 IDE 런처를 PATH에서 사용할 수 있습니다. 이 레포는 기본 Toolbox 스크립트 디렉토리를 셸 시작 시 PATH에 포함하므로, Toolbox가 런처를 생성하면 `we`, `dg` 같은 별칭이 새 셸에서 바로 동작합니다.

JavaScript 및 TypeScript 런타임 전환은 Nix에서 고정 `nodejs_*`, `bun`, `deno` 패키지 대신 Home Manager의 `programs.mise` 통합을 통해 관리됩니다. Home Manager가 글로벌 기본값을 `~/.config/mise/config.toml`에 기록하므로 새 셸 전체에 적용됩니다. 이 레포는 Node `lts`, Bun/Deno `latest` 같은 이동 채널에 글로벌 폴백을 유지하고, 프로젝트 로컬 `.mise.toml` 및 `.tool-versions` 파일로 정확한 버전을 고정할 수 있습니다. `.nvmrc` 또는 `.node-version`도 Node 프로젝트에서 계속 지원됩니다. 해당 파일이 있는 프로젝트에 진입하면 `mise install`을 한 번 실행합니다.

`pnpm` 글로벌 바이너리는 Home Manager를 통해 `PNPM_HOME=~/Library/pnpm`으로 선언적으로 관리되므로, 셸 dotfile을 직접 수정하는 `pnpm setup` 대신 이 방식을 사용합니다.

Android Studio는 Homebrew 캐스크로 관리되고, Home Manager가 새 셸에서 `ANDROID_HOME`, `ANDROID_SDK_ROOT`, Android SDK 커맨드라인 경로를 내보냅니다. 앱 설치 후 Android Studio의 SDK Manager를 사용해 `~/Library/Android/sdk` 아래에 Android SDK Platform, Build-Tools, Platform-Tools, Command-line Tools, side-by-side NDK를 설치합니다.

iOS 작업에서 실기기 개발이나 디버깅은 보통 Xcode와 `pnpm dev:ios`, `pnpm preflight` 같은 프로젝트 로컬 스크립트만으로 충분합니다. 이 설정은 로컬 EAS iOS 빌드가 필요한 경우를 위해 nixpkgs에서 `fastlane`을 설치하므로, 일회성 `brew install fastlane` 대신 이 선언적 패키지를 사용합니다.

`modules/shared/config/`의 앱 설정은 헬퍼 명령을 통해 빌드할 때 실제 앱 경로에 쓰기 가능한 심볼릭 링크로 연결됩니다. 앱이 자체 dotfile을 수정해도 Git은 이 체크아웃의 변경 사항을 인식합니다. 선택적 추적이 필요한 디렉토리는 로컬 `.gitignore`를 사용하고, 전체 백업이 필요한 설정 트리는 그냥 추적하면 됩니다.

### 9. 빌드 전 스테이징

git을 사용하는 경우, Nix가 현재 작업 트리 내용을 인식할 수 있도록 먼저 파일을 스테이징합니다.

```sh
git add .
```

### 10. 빌드 확인

```sh
nix run .#build
```

이 헬퍼는 현재 레포 루트를 내보내고 `--impure`로 Nix를 실행하여 `modules/shared/config/`의 변경 가능한 링크가 Nix 스토어 대신 이 체크아웃을 참조하도록 합니다.

### 11. 설정 적용

```sh
nix run .#build-switch
```

`build-switch`는 보통 macOS `sudo` 비밀번호 입력 프롬프트까지 진행됩니다. 셸 설정을 변경했다면, 세션을 새로고침합니다:

```sh
exec zsh -l
```

## 최초 설치 후 업데이트

일반 워크플로:

1. Nix 파일을 수정합니다.
2. `opencode` 같은 nixpkgs 관리 패키지의 최신 버전이 필요하면 `nix flake update nixpkgs`로 `flake.lock`의 핀된 `nixpkgs` 입력을 갱신합니다.
3. Nix 관리 Homebrew 메타데이터를 최신으로 유지하려면 `nix run .#update-homebrew`로 `nix-homebrew` 및 핀된 공식/서드파티 탭 입력을 `flake.lock`에서 갱신합니다.
4. 추적 파일을 생성하거나 변경했다면(앱 설정 포함) `git add .`를 실행합니다.
5. `nix run .#build`로 검증합니다.
6. `nix run .#build-switch`로 적용합니다.

이 레포는 Homebrew 자체와 탭 모두 Nix를 통해 관리합니다. 필요한 탭을 `flake.nix`에 `flake = false` 입력으로 추가하고, `owner/homebrew-name` 형식의 Homebrew 온디스크 탭 디렉토리 이름을 사용해 `nix-homebrew.taps`에 연결합니다. 최신 Homebrew 패키지 메타데이터가 필요할 때는 `brew update` 대신 `nix run .#update-homebrew`를 사용합니다.

CodexBar는 핀된 `steipete/tap` 캐스크에서 설치됩니다. 업스트림 `homebrew/cask`는 더 최신이지만 이 호스트에서 크래시가 있어 사용하지 않습니다. Sparkle 자동 업데이터는 선언적으로 비활성화되어 앱 업데이트가 Nix/Homebrew 경로를 유지합니다.

`claude-code@latest`도 마찬가지입니다: 이 레포는 최신 Homebrew 캐스크 채널을 선언적으로 추적하지만, 새 Claude Code 릴리즈는 `flake.lock`의 핀된 Homebrew 메타데이터를 통해 도달합니다.

스위치 후에도 `which claude`가 이전 네이티브 또는 npm 설치를 가리킨다면, Homebrew 캐스크 바이너리가 PATH에서 우선권을 갖도록 해당 복사본을 제거합니다.

Node, Bun, Deno 프로젝트에서는 `mise`를 사용해 런타임 버전을 확인하거나 설치합니다:

```sh
mise ls --current
mise install
```

새 레포 기반 dotfile 트리를 추가할 때의 일반적인 패턴:

1. `modules/shared/config/<앱>` 아래에 디렉토리를 만듭니다.
2. 앱이 설정과 함께 캐시, 잠금, 비밀 파일을 쓰는 경우, 로컬 `.gitignore`를 추가해 추적할 파일만 남깁니다.
3. `modules/shared/files.nix`에 매핑 하나를 추가합니다.
4. `git add .`와 `nix run .#build`를 실행합니다.

## 독립형 설정 미러

`nix-config`는 전체 [`modules/shared/config`](modules/shared/config) 트리의 원본 소스입니다.

독립형 [`kimbank/.config`](https://github.com/kimbank/.config) 레포지토리는 이 전체 Nix 레포 외부에서 설정 트리만 필요한 환경을 위한 미러 출력으로 사용됩니다.

이 레포는 다음을 포함합니다:

- `.github/scripts/dot-config-mirror/publish-config-mirrors.sh`: 로컬 수동 발행 또는 워크플로 사용
- `.github/workflows/publish-dot-config-mirror-repo.yml`: `main` 푸시 시 자동 발행

발행 흐름은 `modules/shared/config`에 대해 `git subtree split`을 사용하고 결과 히스토리를 미러 레포지토리 브랜치에 강제 푸시합니다. 다음 발행 시 덮어쓰지 않으려면 미러 레포에 직접 커밋하지 않습니다.

### GitHub Actions 설정

`nix-config`에 `DOT_CONFIG_MIRROR_REPO_TOKEN` 시크릿을 생성합니다.

레포지토리 시크릿 대신 환경 시크릿으로 저장하는 경우, 워크플로에서 사용하는 환경인 `publish dot config mirror repo`에 연결합니다.

권장 범위:

- 세분화된 개인 액세스 토큰
- `kimbank/.config`만 레포지토리 액세스
- 레포지토리 권한 `Contents: Read and write`

`nix-config` Actions 실행의 `GITHUB_TOKEN`은 다른 레포에 푸시하기 위한 것이 아니므로, 워크플로는 크로스 레포 발행을 위해 이 별도의 시크릿을 사용합니다.

### 수동 발행

```sh
export PUBLISH_GITHUB_TOKEN=YOUR_TOKEN
bash ./.github/scripts/dot-config-mirror/publish-config-mirrors.sh config
```

로컬에서 SSH로 동일한 레포를 사용하려면 대상 URL을 재정의합니다:

```sh
CONFIG_MIRROR_URL=git@github.com:kimbank/.config.git \
  bash ./.github/scripts/dot-config-mirror/publish-config-mirrors.sh config
```

서브모듈에서 이동한 후 첫 번째 성공적인 발행은 `kimbank/.config`의 대상 브랜치 히스토리를 이 레포의 서브트리 파생 히스토리로 대체합니다.

예시:

- `modules/shared/packages.nix`에 CLI 도구 추가
- `modules/shared/pkgs/`에 소규모 로컬 CLI 패키지 추가
- `modules/darwin/home-manager.nix`에 Homebrew 포뮬러 추가
- `modules/darwin/casks.nix`에 GUI 앱 추가
- `modules/darwin/casks.nix`에 `jetbrains-toolbox` 추가 후 Toolbox에서 WebStorm/DataGrip 설치 관리
- `modules/shared/config/dev-infra/compose.yml`에서 로컬 Docker 스택 조정
- `modules/shared/config/ghostty`에서 Ghostty 또는 `cmux` 터미널 외관 조정
- `modules/darwin/home-manager.nix`에서 Colima 자동 시작 및 Docker/Kubernetes 프로필 설정 조정
- `modules/darwin/pf.nix`에서 PF 기반 인바운드 VNC 허용 목록 조정
- `modules/shared/config/dev-infra/mysql/Dockerfile`에서 로컬 MySQL 이미지 부트스트랩 조정
- `modules/shared/home-manager.nix`에서 셸 설정 조정
- `hosts/darwin/default.nix`에서 macOS 기본값 조정

## Tailscale을 통한 화면 공유

인바운드 Screen Sharing/VNC 필터링은 `modules/darwin/pf.nix`에서 선언적으로 관리됩니다.

`nix run .#build-switch`로 적용 후 로드된 VNC 규칙을 확인합니다:

```sh
sudo pfctl -a org.nixos.vnc-screen-sharing -sr
```

로컬 Docker 스택은 Home Manager가 관리하는 `~/.config/dev-infra/compose.yml` 경로에서 실행합니다. 헬퍼 명령으로 빌드하면 이 경로가 레포 체크아웃으로 다시 연결되어 상대 바인드 마운트가 실제 작업 트리 파일을 가리킬 수 있습니다. 로컬 시크릿은 추적되는 Compose YAML에 넣지 말고 `modules/shared/config/dev-infra/.env` 같은 무시된 파일에 보관합니다.

## macOS에서의 Docker

이 레포는 기존 패키지 레이아웃에 맞는 분할로 Docker 도구를 설치합니다:

- `modules/shared/packages.nix`: nixpkgs의 Docker CLI와 `kubectl`
- `modules/darwin/home-manager.nix`: Colima 로그인 타임 서비스 및 기본 Docker/Kubernetes 프로필 설정
- `modules/shared/config/dev-infra/compose.yml`: `~/.config/dev-infra/`에 링크된 Portainer, MySQL, PostgreSQL, Redis, RustFS 스택
- `modules/shared/config/dev-infra/README.md`: 로컬 스택 상세 사용 가이드

`nix run .#build-switch` 후 첫 실행:

```sh
kubectl get nodes
docker compose -f ~/.config/dev-infra/compose.yml up -d
```

Portainer는 [https://localhost:9443](https://localhost:9443), [https://kimbank.local:9443](https://kimbank.local:9443), [https://ehkim.local:9443](https://ehkim.local:9443)에서 접근 가능합니다. 처음에는 자체 서명 인증서로 인해 브라우저 경고가 표시될 수 있습니다.

로컬 DB 및 오브젝트 스토리지 서비스는 `${DEV_INFRA_BIND_ADDRESS:-0.0.0.0}`에 `3306`, `5432`, `6379`, `9000`, `9001` 포트를 게시하므로 `localhost`, `kimbank.local`, `ehkim.local`을 통해 작동합니다. 루프백 전용 실행에는 `DEV_INFRA_BIND_ADDRESS=127.0.0.1`로 설정합니다.

기본 MySQL 및 PostgreSQL 데이터베이스 이름은 `playground`입니다. PostgreSQL은 `admin`을 슈퍼유저로 사용하고, MySQL 스택은 로컬 개발을 위해 `root`와 로컬 `admin` 계정을 전체 권한으로 초기화합니다. Portainer는 `admin` 계정을 비밀번호 `adminadmin!!`로 초기화합니다. RustFS는 S3 API를 `http://127.0.0.1:9000`, `http://kimbank.local:9000`, `http://ehkim.local:9000`에, 웹 콘솔을 `http://127.0.0.1:9001`, `http://kimbank.local:9001`, `http://ehkim.local:9001`에 `admin` / `adminadmin!!`로 노출합니다. RustFS CORS는 로컬 개발을 위해 `*`로 기본 설정됩니다.

Colima는 Home Manager의 macOS `launchd` 통합을 통해 사용자 로그인 시 자동으로 시작하도록 구성되어 있으며, 기본 프로필은 로컬 Kubernetes 테스트를 위한 내장 k3s 클러스터도 활성화합니다. Home Manager는 활성화 시 일반 `~/.colima/default/colima.yaml`을 작성하므로 직접 `colima start` 명령으로 프로필을 업데이트할 수 있습니다. 단, 영구적인 변경은 `modules/darwin/home-manager.nix`에 해야 합니다. 새 세대로 전환 전에 Colima가 이미 실행 중이었다면 `colima stop && colima start`로 한 번 재시작하여 Kubernetes 설정을 현재 세션에 적용합니다.

나중에 초기 DB 사용자명, 비밀번호, 데이터베이스 이름을 변경하면 관련 Docker 볼륨을 제거한 후 컨테이너를 재생성하여 새 초기화 값이 적용되도록 합니다.

전체 명령 참조 및 초기화 워크플로는 [`modules/shared/config/dev-infra/README.md`](modules/shared/config/dev-infra/README.md)를 참조합니다.

## 참고 사항

- Nix 모듈에서 제외해야 하는 로컬 전용 GitHub 버킷 설정에는 [`scripts/github-local-auth/setup-github-local-auth.sh`](scripts/github-local-auth/setup-github-local-auth.sh)를 사용합니다. 구성된 1Password 항목을 읽고, 로컬 `~/.ssh` 및 `~/.gitconfig` 상태를 기록하며, 버킷 레벨 `~/Github/*/.envrc` 파일을 업데이트합니다. `op://...` 참조 대신 해당 `.envrc` 파일에 평문 `GH_TOKEN` 값을 의도적으로 쓰려면 `--danger`를 전달합니다.
- 현재 대상 플랫폼은 `arm64-darwin`이 아니라 `aarch64-darwin`입니다.
- `nix run .#apply`는 템플릿의 초기 개인화에만 사용합니다.
- `nix run .#update-homebrew`는 핀된 Homebrew 버전과 `flake.lock`에 저장된 공식/서드파티 Homebrew 탭 핀을 모두 갱신합니다.
- 일상적인 변경은 `nix run .#build-switch`로 적용합니다.
- 레포 구조, 워크플로, 사용자 가시적 동작을 변경하면 코드와 함께 이 README를 업데이트하여 문서화된 레이아웃과 명령이 최신 상태를 유지하도록 합니다.
- 새 Mac에서는 간단하게 진행됩니다. 이미 사용 중인 Mac에서는 기존 `/etc` 파일, 이전 Homebrew 상태, 기존 셸 dotfile이 최초 활성화 시 충돌할 수 있습니다.
