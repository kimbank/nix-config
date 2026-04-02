# Worktrunk

이 디렉터리는 이 리포가 관리하는 사용자 전역 Worktrunk 설정을 담습니다.

- 실제 사용자 설정 파일: `~/.config/worktrunk/config.toml`
- 이 리포의 원본 파일: `modules/shared/config/worktrunk/config.toml`
- Home Manager 링크 설정: `modules/shared/files.nix`
- zsh shell integration 설정: `modules/shared/home-manager.nix`

중요:

- 이 리포는 `~/.config/worktrunk` 디렉터리 전체를 링크하지 않고 `config.toml` 파일만 링크합니다.
- 이유는 Worktrunk가 런타임 상태 파일을 같은 디렉터리에 쓰기 때문입니다.
- 예: 승인 상태, 로그 관련 상태

## 빠른 시작

Worktrunk의 핵심은 "브랜치 이름으로 worktree를 다룬다"는 점입니다.

가장 자주 쓰는 명령:

```bash
# 기존 worktree로 이동
wt switch develop

# 현재 worktree를 기준으로 새 브랜치 + 새 worktree 생성 후 이동
wt switch --create --base @ feature/login

# 직전 worktree로 이동
wt switch -

# 인터랙티브 picker 열기
wt switch

# 전체 worktree 상태 보기
wt list

# 기본 브랜치로 머지하고 정리
wt merge

# 특정 브랜치로 머지
wt merge develop

# 현재 worktree 정리
wt remove

# 현재 설정과 shell integration 상태 확인
wt config show
```

짧은 옵션도 자주 씁니다.

```bash
wt switch -c -b @ feature/login
```

위 명령은 아래와 같습니다.

```bash
wt switch --create --base @ feature/login
```

## 추천 워크플로우

`develop` 기반으로 작업한다면 보통 이렇게 쓰면 편합니다.

1. 기준 브랜치 worktree로 이동

```bash
wt switch develop
```

2. 현재 worktree를 기준으로 새 작업 브랜치 생성

```bash
wt switch --create --base @ feature/login
```

3. Worktrunk 전역 `post-create` 훅이 자동 실행

- `.env`가 없으면 base worktree의 `.env`를 복사
- `package.json`이 있으면 `pnpm install`
- `pnpm-lock.yaml`이 없고 npm/yarn lockfile만 있으면 먼저 `pnpm import`
- `prisma/schema.prisma`가 있으면 `npx prisma generate`

4. 작업 중 상태 확인

```bash
wt list
```

5. 끝나면 머지

```bash
# 기본 브랜치로 머지
wt merge

# 또는 develop로 머지
wt merge develop
```

6. 머지 없이 정리만 할 때

```bash
wt remove
```

## 현재 전역 설정

이 리포의 `config.toml`은 사용자 전역 훅을 선언합니다.

현재 선언:

- `post-create.env`
- `post-create.pnpm`
- `post-create.prisma`

동작 요약:

```toml
[post-create]
```

- `env`: 새 worktree에 `.env`가 없고 base worktree에 `.env`가 있으면 복사
- `pnpm`: `package.json`이 있을 때만 실행
- `prisma`: `prisma/schema.prisma`가 있을 때만 실행

전역 사용자 훅이라 프로젝트 승인 프롬프트 없이 실행됩니다.

반대로 프로젝트별 공유 설정은 각 레포의 `.config/wt.toml`에 넣습니다. 이 경우 공식 문서 기준으로 첫 실행 시 승인 절차가 있습니다.

## Shell Integration

`wt switch`가 현재 셸의 작업 디렉터리를 실제로 바꾸려면 shell integration이 필요합니다.

이 리포에서는 `wt config shell install`을 수동으로 돌리지 않고, Home Manager가 zsh startup에서 다음을 선언적으로 로드합니다.

```bash
eval "$(wt config shell init zsh)"
```

적용 순서:

```bash
nix run .#build-switch
exec zsh -l
```

확인:

```bash
wt config show
```

`Shell integration not active`가 보이면 보통 아직 현재 셸이 새 설정으로 다시 시작되지 않은 상태입니다.

## User Config vs Project Config

Worktrunk는 설정 위치가 둘입니다.

사용자 전역:

```text
~/.config/worktrunk/config.toml
```

- 모든 레포에 적용
- 개인 설정
- 이 리포가 관리하는 대상

프로젝트 전용:

```text
<repo>/.config/wt.toml
```

- 특정 레포에만 적용
- 팀과 공유 가능
- 프로젝트 훅 승인 대상

구분 기준:

- 모든 프로젝트에서 공통으로 쓰는 준비 작업: 사용자 전역
- 특정 프로젝트에서만 맞는 `.env`, dev server, DB, 테스트 흐름: 프로젝트 설정

## 유스케이스

### 1. bare repo에서 시작할 때

bare repo로 시작하면 "작업 파일이 펼쳐진 기준 worktree"가 아직 없는 상태입니다.

예를 들어 bare repo가 아래 경로에 있다고 가정해보겠습니다.

```text
~/Github/acme/your-service-api.bare
```

이 상태에서 아래처럼 새 worktree를 만들면:

```bash
wt switch -c wt-test2
```

기본값으로는 bare 디렉터리 "안"이 아니라 bare 디렉터리 "옆"에 worktree가 생깁니다.

```text
~/Github/acme/your-service-api.bare
~/Github/acme/your-service-api.bare.wt-test2
```

이건 이상한 동작이 아니라 Worktrunk의 기본 `worktree-path` 템플릿이 sibling layout이기 때문입니다.

공식 문서 기준 기본 개념:

- 기본 위치는 `../<repo>.<branch>`
- 즉 현재 repo 경로의 상위에 형제 디렉터리 형태로 생성

그래서 bare repo 이름이 `your-service-api.bare`라면 branch `wt-test2`의 기본 경로는:

```text
~/Github/acme/your-service-api.bare.wt-test2
```

가 됩니다.

이 레이아웃은 bare repo와 작업 디렉터리를 섞지 않아서 깔끔합니다.

### 2. 왜 bare "아래"가 아니라 bare "바깥"인가

처음에는 이렇게 생각하기 쉽습니다.

```text
your-service-api.bare/
  develop/
  feature-login/
```

하지만 bare repo는 보통 Git 저장소 메타데이터 역할에 가깝고, working tree를 그 안에 직접 섞는 건 구조가 애매해집니다.

공식 문서도 bare 패턴을 설명할 때는 보통 이런 구조를 예시로 듭니다.

```text
your-service-api/
  .git/        # bare repo
  main/        # worktree
  develop/     # worktree
  feature-api/ # worktree
```

즉 핵심은:

- bare repo는 저장소 중심점
- 실제 작업은 바깥 worktree들에서 수행

입니다.

### 3. `your-service-api`에서 추천 시작 순서

`develop` 기반으로 작업한다고 하면, bare repo를 만든 직후엔 먼저 기준 worktree를 하나 만드는 게 좋습니다.

예시:

```bash
cd ~/Github/acme/your-service-api.bare
wt switch develop
```

그러면 대략 이런 식으로 됩니다.

```text
~/Github/acme/your-service-api.bare
~/Github/acme/your-service-api.bare.develop
```

이제 `develop` worktree가 기준 작업 디렉터리 역할을 합니다.

그 안에서 `.env`를 한 번 준비합니다.

```bash
cd ~/Github/acme/your-service-api.bare.develop
cp .env.example .env
```

그다음부터 feature worktree는 이 `develop` worktree 안에서 만드는 게 가장 자연스럽습니다.

```bash
wt switch -c -b @ feature/login
```

그러면 흐름은 이렇게 됩니다.

1. 현재 `develop` worktree를 base로 새 branch 생성
2. 새 worktree로 이동
3. 전역 `post-create` 훅 실행
4. `develop` worktree의 `.env` 복사 시도
5. `pnpm install`
6. 필요하면 `npx prisma generate`

예상되는 결과 경로:

```text
~/Github/acme/your-service-api.bare
~/Github/acme/your-service-api.bare.develop
~/Github/acme/your-service-api.bare.feature-login
```

### 4. `.env`는 어디에 두는 게 자연스러운가

이 리포 기준 추천은 아래와 같습니다.

- bare repo: `.env`를 두는 곳으로 쓰지 않음
- `develop` worktree: 기준 `.env`를 두는 곳
- feature worktree: 생성 시 `develop`의 `.env`를 복사받는 곳

즉 `your-service-api` 예시라면:

```text
~/Github/acme/your-service-api.bare
~/Github/acme/your-service-api.bare.develop/.env
~/Github/acme/your-service-api.bare.feature-login/.env
```

이런 구조가 가장 이해하기 쉽고 유지보수도 편합니다.

### 5. bare repo에서 바로 feature를 만들면 생기는 일

예를 들어 기준 worktree 없이 바로:

```bash
cd ~/Github/acme/your-service-api.bare
wt switch -c feature/login
```

을 하면 worktree 생성 자체는 가능할 수 있습니다. 다만 이 경우 `.env`를 복사할 "기준 worktree"가 아직 없어서, 전역 훅의 `.env` 복사는 스킵될 수 있습니다.

그래서 bare repo를 처음 잡을 때는 보통 아래 순서를 추천합니다.

```bash
wt switch develop
cd ../your-service-api.bare.develop
# 여기서 .env 준비
wt switch -c -b @ feature/login
```

한 줄로 요약하면:

- bare repo는 시작점
- 실제 기준 작업 디렉터리는 `develop` worktree
- 이후 feature는 그 `develop` worktree에서 파생

## Hook 관련 주의사항

공식 사이트 문서와 현재 설치된 바이너리 help가 hook 이름에서 다르게 보일 수 있습니다.

이 리포는 현재 설치된 `wt 0.30.1` 기준으로 동작을 맞춥니다.

버전별 실제 동작 확인:

```bash
wt --version
wt hook --help-page
wt switch --help-page
```

현재 확인된 기준:

- `post-create`: 새 worktree 생성 직후, 다음 단계 전에 끝나야 하는 작업
- `post-start`: 백그라운드 작업
- `post-switch`: 모든 switch 결과에 반응하는 작업

즉:

- `.env` 복사, `pnpm install`, `prisma generate` 같은 준비 작업은 `post-create`
- dev server는 `post-start`
- 터미널 창 이름 변경 같은 반응형 작업은 `post-switch`

## Hook 수동 실행

설정 바꾼 뒤 현재 worktree에서 다시 시험해보고 싶으면:

```bash
# 현재 worktree에서 사용자 전역 post-create 훅 다시 실행
wt hook post-create user:
```

프로젝트 훅까지 같이 시험하려면:

```bash
wt hook post-create
```

문제 파악 시:

```bash
wt hook post-create -v
wt switch --no-verify
wt merge --no-verify
```

## cmux 메모

공식 문서에는 `tmux` 예제가 있습니다. 예를 들어 `post-switch`에서 현재 브랜치명으로 창 이름을 바꾸는 패턴입니다.

```toml
[post-switch]
tmux = "[ -n \"$TMUX\" ] && tmux rename-window {{ branch | sanitize }}"
```

`cmux`도 비슷한 창 이름 변경 명령을 제공한다면 같은 아이디어로 응용할 수 있습니다. 다만 이 리포는 아직 `cmux` 전용 `post-switch` 훅은 선언하지 않았습니다.

이 부분은 공식 `tmux` 예제를 `cmux`에 맞게 응용하는 아이디어입니다.

## 공식 레퍼런스

- Main docs: <https://worktrunk.dev/worktrunk/>
- `wt switch`: <https://worktrunk.dev/switch/>
- `wt list`: <https://worktrunk.dev/list/>
- `wt merge`: <https://worktrunk.dev/merge/>
- `wt remove`: <https://worktrunk.dev/remove/>
- `wt config`: <https://worktrunk.dev/config/>
- `wt hook`: <https://worktrunk.dev/hook/>
- Tips & Patterns: <https://worktrunk.dev/tips-patterns/>

추가로, 현재 설치된 버전에서 실제 노출되는 옵션과 hook 이름은 아래 help가 가장 정확합니다.

```bash
wt --help-page
wt switch --help-page
wt hook --help-page
wt config --help-page
```
