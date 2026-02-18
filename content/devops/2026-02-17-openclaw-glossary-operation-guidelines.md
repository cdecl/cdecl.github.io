---
title: "OpenClaw 용어집 및 운영 지침 가이드"

tags:
  - openclaw
  - clawdbot
  - agent
  - gateway
  - devops
  - security
  - operations
  - 용어집
  - 운영 지침
---


OpenClaw(ClawdBot 기반)는 개인 AI 에이전트를 메시징 채널과 연결해 운영하는 게이트웨이 중심 프레임워크입니다. 이 문서는 용어를 사람 친화적으로 정리하고, 운영 시 바로 적용할 수 있는 체크리스트와 최신 변경 사항(공식 소스 기준)까지 함께 제공합니다.

## 개요

- 문서 목적: 용어 설명 + 운영 지침 통합 가이드
- 최신 정보 범위: 공식 문서와 공식 릴리스만 사용
- 최신 반영 기준:
  - GitHub Release `v2026.2.15` (게시일: **2026-02-16**)
  - docs.openclaw.ai의 공식 업데이트 문서

## 핵심 개념 (단순 설명)

### Gateway (게이트웨이)
- 모든 메신저(WhatsApp, Telegram, Discord 등)와 에이전트를 연결해 주는 중앙 서버/데몬.
- 기본 포트: `18789` (WebSocket).
- 한 개의 Gateway로 여러 채널과 여러 에이전트를 동시에 관리 가능.

### Agent (에이전트)
- AI 어시스턴트의 "뇌"에 해당.
- 개별 성격, 메모리, 행동 방식을 가짐.
- 각 Agent는 격리된 상태(`workspace`, `auth`, `sessions`)를 유지.
- 기본 에이전트 이름: `main`.

### Workspace (작업 폴더)
- Agent의 "개인 폴더"로, 기본 경로: `~/.openclaw/workspace`.
- 주요 파일:
  - `AGENTS.md`: 동작 지시, 규칙, 메모리.
  - `SOUL.md`: 성격, 말투, 경계.
  - `USER.md`: 사용자 정보와 호칭.
  - `TOOLS.md`: 사용 가능한 도구/툴 설명.
  - `BOOTSTRAP.md`: 최초 실행 설정(한 번 실행 후 삭제).
  - `memory/YYYY-MM-DD.md`: 일일 메모리 로그.

### Agent Directory (`agentDir`)
- 에이전트의 기술 설정/인증 정보를 저장.
- 기본 경로: `~/.openclaw/agents/<agentId>/agent`.
- 주요 파일:
  - `auth-profiles.json`: 모델 제공자(Anthropic, OpenAI 등) 인증 정보.
  - 에이전트별 모델 설정/구조 파일.

## 통신 구조

### Channel (채널)
- 메신저 연결 단위.
- 예: WhatsApp, Telegram, Discord 각각 하나의 관(pipe).

### Account ID (`accountId`)
- 같은 채널 내 여러 계정을 구분.
- 예: 개인 WhatsApp, 업무용 WhatsApp.

### Session Key (`sessionKey`)
- 대화 스레드를 구분하는 고유 이름/주소.
- 예:
  - `agent:main:main` (기본 1:1 대화)
  - `agent:main:telegram:group:123` (그룹 대화)

### Session ID (`sessionId`)
- 실제 대화 기록 파일 ID.
- 경로 예: `~/.openclaw/agents/<agentId>/sessions/<sessionId>.jsonl`.
- 세션 재설정 시 값이 바뀜.

### Binding (바인딩)
- 라우팅 규칙.
- 어떤 채널/계정/연락처에서 온 메시지를 어떤 Agent로 보낼지 결정.
- 가장 구체적인 규칙이 우선 적용.

## 세션 관리

### Main Session (기본 대화)
- 기본 1:1 대화 세션.
- 예: `agent:<agentId>:main`.
- 모든 개인 대화를 한 세션으로 모아 유지할 수 있음.

### DM Scope (`dmScope`)
- DM(1:1) 분리 수준 설정.
  - `main`: 모든 DM 공유
  - `per-peer`: 사용자별 분리
  - `per-channel-peer`: 채널+사용자별 분리
  - `per-account-channel-peer`: 계정+채널+사용자별 최대 분리

### Session Reset (초기화)
- 새 대화를 시작할 때 `sessionId`를 새로 생성.
- 방법:
  - 수동: `openclaw new`, `openclaw reset`
  - 자동: 지정 시각(예: 매일 04:00), 비활성 시간 기준 자동 리셋

### Compaction (압축/요약)
- 긴 대화를 요약해 컨텍스트 한도 초과를 방지.
- 핵심 맥락은 남기고 오래된 상세를 정리.

### Memory Flush (메모리 저장)
- Compaction 전에 중요한 정보를 영구 메모리로 기록.
- `memory/YYYY-MM-DD.md`에 저장.
- `NO_REPLY` 내부 메시지로 사용자 노출 없이 처리 가능.

## 접근 제어 / 보안

### Pairing (페어링)
- 새 노드(장치) 연결 시 승인 절차.
- 로컬(`127.0.0.1`)은 자동 승인 옵션 가능.
- 승인 후 토큰 발급으로 접근 허용.

### DM Policy (`dmPolicy`)
- DM 허용 범위 제어.
  - `open`: 누구나 가능(위험)
  - `pairing`: 승인 사용자만
  - `allowlist`: 허용 목록만

### Allow From (`allowFrom`)
- 허용 번호/ID 목록.
- 예: `+15555550123`

### Group Policy (`groupPolicy`)
- 그룹 참여 범위 제어.
  - `open`: 모든 그룹(권장하지 않음)
  - `allowlist`: 허용 그룹만
  - `denylist`: 차단 목록 제외

### Require Mention
- 그룹에서 `@멘션`이 있을 때만 응답.
- 불필요 응답/스팸 방지에 유효.

### Gateway Token (`OPENCLAW_GATEWAY_TOKEN`)
- Gateway 접속용 공유 비밀.
- WebSocket 인증에 사용.

### Sandbox (샌드박스)
- 도구 실행 격리(도커 기반).
- 모드:
  - `off`: 비격리(전체 시스템 접근)
  - `non-main`: 메인 세션만 비격리
  - `all`: 모든 세션 격리
- 스코프: `session`, `agent`, `shared`

> 주의
> - `bind: 0.0.0.0` + 약한 인증은 외부 노출 위험이 큼.
> - `dmPolicy: open`, `groupPolicy: open`은 운영 초기 기본값으로 쓰지 않는 것을 권장.
> - `sandbox: off`는 편의성은 높지만, 도구 실행 리스크가 가장 큼.

## 노드 / 클라이언트

### Node (노드)
- 원격 장치(휴대폰/태블릿/PC)가 Gateway에 연결한 실행 주체.
- 연결 역할: `role: "node"`.
- 기능 예:
  - `canvas.*`
  - `camera.*`
  - `screen.record`
  - `location.get`

### Client (클라이언트)
- Gateway를 조작/관리하는 앱.
- 예: macOS 앱, CLI, 웹 UI.
- 메시지 발송, 설정 변경, 세션 점검 가능.

### Control UI (제어 UI)
- 접속: `http://127.0.0.1:18789/`.
- 채팅 기록, 구성, 세션, 노드 상태를 확인/수정.

### Canvas
- Agent가 인터랙티브 UI를 생성하는 렌더링 영역.
- 기본 포트: `18793`.
- 버튼/폼/편집 UI를 클라이언트에 표시.

## 툴 / 기능

### Tool (툴)
- Agent가 실행 가능한 기능 단위.
- 예: `exec`, `read`, `write`, `browser`, `canvas`.
- 에이전트별 허용/차단 정책 적용 가능.

### Skill (스킬)
- 사용자 정의 스크립트/프로그램.
- 경로:
  - `~/.openclaw/skills/` (공유)
  - `<workspace>/skills/` (에이전트별)

### RPC (Remote Procedure Call)
- Gateway 내부 요소 간 호출 프로토콜.
- 도구 실행, 에이전트 호출, 상태 조회에 사용.

### Plugin (플러그인)
- 채널/도구/CLI 명령/Gateway 메서드 확장 모듈.
- 설치 예: `openclaw plugins install @openclaw/plugin-name`

## 설정 / 인증

### `openclaw.json`
- Gateway 메인 설정 파일.
- 기본 경로: `~/.openclaw/openclaw.json`.
- CLI/웹 UI에서 수정 가능.

### Hot Reload
- 재시작 없이 설정 반영.
  - 즉시 반영: 대부분 설정
  - 다음 메시지부터 반영: 세션/라우팅 계열
  - 재시작 필요: 네트워크 바인딩/구조 변경

### 환경 변수
- 비밀 값(API 키, 토큰) 분리 저장.
- 예: `TELEGRAM_BOT_TOKEN`, `ANTHROPIC_API_KEY`.

### Auth Profile
- 모델 제공자 인증 정보.
- `auth-profiles.json`에 저장.
- API 키/OAuth 사용 가능.

### Model Provider / Model Ref
- `models.providers`에 제공자 정의.
- 모델 참조 형식: `provider/model`.
- 예: `anthropic/claude-sonnet-4-5`.

## 운영 체크리스트

### 기본 보안 권장값
- `dmPolicy`: `pairing` 또는 `allowlist`
- `groupPolicy`: `allowlist` 우선
- `requireMention`: 그룹에서 `true` 권장
- `OPENCLAW_GATEWAY_TOKEN`: 평문 공유 금지, 정기 교체
- 외부 바인딩 필요 시 방화벽/IP ACL 동시 적용

### 세션 운영 시나리오
- 정기 리셋: 하루 1회 또는 업무 단위 종료 시 `sessionId` 회전
- Compaction 기준: 토큰 한도 60~70% 접근 시 선제 요약
- Memory Flush: 운영 정책/사용자 선호/중요 결정사항만 저장

### 장애 대응 최소 순서
1. `health` 상태 확인(게이트웨이 응답 여부)
2. `openclaw doctor` 실행(권한/설정/네트워크 점검)
3. Gateway 로그 확인(토큰 인증 실패/채널 연결 실패/툴 실행 오류)
4. 채널별 바인딩 규칙 재검토
5. 필요 시 마지막 정상 구성으로 롤백

## 최신 변경 요약 (공식 소스 기준)

기준 시점: **2026-02-17**

- **항목명**: Release `v2026.2.15` (게시일: **2026-02-16**)  
  **변경 내용**: RPC semantics 개선, macOS 앱 안정성 강화, hooks/commands 개선, 테스트 회귀 수정  
  **운영 영향**: 노드/클라이언트 연동 시 예외 케이스 감소, 채널 연결 안정성 향상 기대  
  **적용 시 주의점**: 커스텀 훅/플러그인 사용 시 이벤트 처리 순서/에러 핸들링 회귀 테스트 필요  
  **출처**: https://github.com/moltbot/moltbot/releases/tag/v2026.2.15

- **항목명**: 공식 업데이트 문서(업데이트 작성일: **2026-02-17**)  
  **변경 내용**: 상위 경로 변경(`~/.claude` -> `~/.openclaw`), 명령어 변경(`molt` -> `openclaw`), 앱 리브랜딩 반영  
  **운영 영향**: 기존 운영 스크립트/문서/자동화 파이프라인의 경로/명령어 수정 필요  
  **적용 시 주의점**: 백업/배포 스크립트, systemd/launchd, CI 문서에서 구 경로/구 명령어 잔존 여부 점검  
  **출처**: https://docs.openclaw.ai/updating

## 전반 흐름 요약

1. 로컬/클라우드에 OpenClaw 설치
2. Gateway 데몬 실행
3. WhatsApp/Telegram/Discord 등 채널 연결
4. 사용자 메시지가 Gateway로 유입
5. Binding 규칙으로 대상 Agent 라우팅
6. Agent가 `SOUL.md`, `USER.md`, `memory/*.md`를 읽고 컨텍스트 구성
7. 모델 호출 및 필요 시 툴 실행
8. 결과를 채널로 반환
9. 히스토리 저장/메모리 업데이트/Compaction 수행

## 참고 링크

- OpenClaw 공식 문서: https://docs.openclaw.ai/
- OpenClaw 업데이트 가이드: https://docs.openclaw.ai/updating
- OpenClaw 릴리스 목록: https://github.com/moltbot/moltbot/releases
- `v2026.2.15` 릴리스: https://github.com/moltbot/moltbot/releases/tag/v2026.2.15
