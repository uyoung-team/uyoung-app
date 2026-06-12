# uyoung-app

`uyoung-app`은 기존 `UYOUNG` 앱을 새로운 디자인 토큰 체계와 화면 구조 기준으로 재정비한 Flutter 모바일 앱입니다.  
기억섬 기반 추억 공유, 출석 체크, 캘린더 탐색, 친구/프로필 관리, Supabase 인증 및 사용자 데이터 흐름을 하나의 앱 경험으로 연결하는 것을 목표로 합니다.

이 문서는 이력서·포트폴리오 제출을 염두에 두고, 프로젝트 목적과 구현 범위, 기술적 포인트를 빠르게 파악할 수 있도록 정리했습니다.

## 한눈에 보기

- **플랫폼**: Flutter iOS / Android
- **언어**: Dart
- **상태관리**: `provider` + `ChangeNotifier`
- **백엔드**: `Supabase`
- **특징**:
  - 기존 `UYOUNG` 기능 흐름을 유지하면서 UI/에셋 구조를 재정비
  - 화면별 폰트/컬러/에셋 토큰 체계 정리
  - 홈, 출석체크, 기억섬, 캘린더, 마이페이지 중심 구조
  - 초대 링크 진입 및 OAuth 인증 흐름 지원

## 프로젝트 목표

이 프로젝트의 핵심은 단순한 화면 재구성이 아니라,

- 기존 앱 `UYOUNG`의 주요 기능과 사용자 흐름을 유지하면서
- 새 프로젝트 구조에서 유지보수성과 확장성을 높이고
- 디자인 토큰, 에셋 경로, 공통 컴포넌트 기준을 명확히 정리하는 것

입니다.

즉, “기억섬 기반 공유 추억 앱”이라는 제품 경험은 유지하고, 구현 구조와 디자인 시스템 레이어를 개선한 버전입니다.

## 주요 기능

### 1. 인증 / 앱 진입

- `Supabase OAuth` 기반 소셜 로그인
- 인증 상태에 따른 진입 분기
- 프로필 설정 필요 여부 확인
- 초대 링크 진입 시 특정 기억섬으로 연결

관련 파일:
- [app.dart](/Users/choseoungeun/dev/uyoung-app/lib/app/app.dart)
- [bootstrap.dart](/Users/choseoungeun/dev/uyoung-app/lib/app/bootstrap.dart)
- [app_router.dart](/Users/choseoungeun/dev/uyoung-app/lib/app/routes/app_router.dart)
- [login_page.dart](/Users/choseoungeun/dev/uyoung-app/lib/features/login/presentation/pages/login_page.dart)

### 2. 홈

- 캐릭터 메인 화면
- 진주 수량 확인
- 알림 진입 및 읽음 처리
- 출석체크 진입
- shell story 연결

관련 파일:
- [home_page.dart](/Users/choseoungeun/dev/uyoung-app/lib/features/home/presentation/pages/home_page.dart)
- [notification_page.dart](/Users/choseoungeun/dev/uyoung-app/lib/features/home/presentation/pages/notification_page.dart)
- [shell_story_page.dart](/Users/choseoungeun/dev/uyoung-app/lib/features/home/presentation/pages/shell_story_page.dart)

### 3. 출석체크

- 출석 진입 → 보상 공개 → 보드 확인의 단계형 흐름
- 출석 로그 및 보상 아이템 기반 UI
- RPC 호출 기반 출석 처리

관련 파일:
- [attendance_page.dart](/Users/choseoungeun/dev/uyoung-app/lib/features/attendance/presentation/pages/attendance_page.dart)
- [attendance_board_page.dart](/Users/choseoungeun/dev/uyoung-app/lib/features/attendance/presentation/pages/attendance_board_page.dart)
- [attendance_view_model.dart](/Users/choseoungeun/dev/uyoung-app/lib/features/attendance/presentation/viewmodels/attendance_view_model.dart)

### 4. 기억섬

- 기억섬 목록/검색/생성
- 멤버 선택 및 초대
- 초대 링크 입장
- 상세 탭, 즐겨찾기, 타임라인, 날짜별 보기
- 사진 상세, 댓글/스티커/날짜/위치 조정 UI 흐름

관련 파일:
- [memory_page.dart](/Users/choseoungeun/dev/uyoung-app/lib/features/memory/presentation/pages/memory_page.dart)
- [memory_detail_page.dart](/Users/choseoungeun/dev/uyoung-app/lib/features/memory/presentation/pages/memory_detail_page.dart)
- [timeline_memory_page.dart](/Users/choseoungeun/dev/uyoung-app/lib/features/memory/presentation/pages/timeline_memory_page.dart)
- [memory_repository.dart](/Users/choseoungeun/dev/uyoung-app/lib/features/memory/data/memory_repository.dart)

### 5. 캘린더

- 월 단위 기억 탐색
- 날짜별 기억 요약
- 선택 날짜 바텀시트 및 상세 흐름
- 기억섬 필터/관리/설정 화면

관련 파일:
- [calendar_page.dart](/Users/choseoungeun/dev/uyoung-app/lib/features/calendar/presentation/pages/calendar_page.dart)
- [calendar_view_model.dart](/Users/choseoungeun/dev/uyoung-app/lib/features/calendar/presentation/viewmodels/calendar_view_model.dart)
- [calendar_repository.dart](/Users/choseoungeun/dev/uyoung-app/lib/features/calendar/data/calendar_repository.dart)

### 6. 마이페이지

- 프로필/진주/친구/공지/문의 관리
- 친구 프로필 조회 및 삭제
- 프로필 URL 복사
- 친구 초대
- 로그아웃

관련 파일:
- [my_page_page.dart](/Users/choseoungeun/dev/uyoung-app/lib/features/my_page/presentation/pages/my_page_page.dart)
- [friend_profile_page.dart](/Users/choseoungeun/dev/uyoung-app/lib/features/my_page/presentation/pages/friend_profile_page.dart)
- [pearl_charge_page.dart](/Users/choseoungeun/dev/uyoung-app/lib/features/my_page/presentation/pages/pearl_charge_page.dart)

## 주요 화면

이력서 또는 포트폴리오 제출용으로는 아래 6장 정도를 선별해서 넣는 구성이 가장 깔끔합니다.

- 로그인
- 홈
- 출석체크
- 기억섬
- 캘린더
- 마이페이지

스크린샷 파일은 `docs/screenshots/`에 아래 이름으로 두는 것을 추천합니다.

- `login.png`
- `home.png`
- `attendance.png`
- `memory.png`
- `calendar.png`
- `mypage.png`

README에는 아래 형식으로 바로 연결할 수 있습니다.

```md
## 주요 화면

| 로그인 | 홈 |
| --- | --- |
| ![로그인](docs/screenshots/login.png) | ![홈](docs/screenshots/home.png) |

| 출석 체크 | 기억섬 |
| --- | --- |
| ![출석 체크](docs/screenshots/attendance.png) | ![기억섬](docs/screenshots/memory.png) |

| 캘린더 | 마이페이지 |
| --- | --- |
| ![캘린더](docs/screenshots/calendar.png) | ![마이페이지](docs/screenshots/mypage.png) |
```

## 기술 스택

- **Flutter / Dart**
- **Provider**
- **Supabase**
  - Auth
  - Database
  - RPC
  - Storage
- **app_links**
- **flutter_svg**
- **image_picker**
- **table_calendar**

## 아키텍처

이 프로젝트는 `feature-first` 구조와 `provider + ChangeNotifier`를 사용합니다.

```text
lib/
├── app/
├── core/
├── features/
│   ├── attendance/
│   ├── calendar/
│   ├── home/
│   ├── login/
│   ├── memory/
│   └── my_page/
└── shared/
```

각 기능은 보통 아래 레이어로 나뉩니다.

```text
feature/
├── data/
├── presentation/pages/
├── presentation/viewmodels/
└── presentation/widgets/
```

흐름:

1. `Page`가 사용자 입력을 받음
2. `ViewModel`이 상태를 관리함
3. `Repository`가 비즈니스 흐름을 중개함
4. `Service`가 Supabase 및 외부 데이터 접근을 담당함

## 디자인 시스템 / 에셋 전략

이 프로젝트는 기존 앱의 화면 경험은 유지하되, 디자인 시스템 레이어를 새로 정리한 버전입니다.

- `AppFont`
- `AppColors`
- `AppTheme`
- `AssetPaths`

를 중심으로 폰트, 컬러, 아이콘, 이미지 경로를 통일했습니다.

즉:
- 화면 흐름과 기능은 `UYOUNG`를 최대한 유지
- 폰트/에셋/공통 컴포넌트 정의는 `uyoung-app` 기준으로 재정비

## 구현 포인트

- **기존 서비스 마이그레이션**
  - 단순 리디자인이 아니라, 기존 앱의 주요 기능 흐름을 새 구조로 옮기는 작업
- **딥링크 기반 기억섬 초대 흐름**
  - 초대코드로 특정 기억섬에 진입하는 구조
- **출석체크 RPC 처리**
  - 서버 기반 보상 처리 흐름
- **공유형 추억 공간 모델링**
  - 기억섬, 멤버, 초대, 즐겨찾기, 알림 설정 등 관계형 데이터 관리
- **캘린더 탐색 UX**
  - 날짜 선택, 바텀시트, 상세 탐색으로 이어지는 흐름 구성
- **에셋 재정비**
  - 화면별 에셋을 기능 단위 폴더와 `AssetPaths`로 정리

## 실행 방법

### 1. 패키지 설치

```bash
flutter pub get
```

### 2. 앱 실행

```bash
flutter run
```

### 3. 환경값 주입

현재 프로젝트는 `String.fromEnvironment` 기반으로 Supabase 값을 받을 수 있습니다.

```bash
flutter run \
  --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY \
  --dart-define=MEMORY_INVITE_BASE_URL=https://momenture.app/invite
```

관련 파일:
- [supabase_config.dart](/Users/choseoungeun/dev/uyoung-app/lib/core/network/supabase_config.dart)

## 에셋 및 폰트

- 아이콘: `assets/icons/...`
- 이미지: `assets/images/...`
- 로그인/홈/출석/기억섬/캘린더/마이페이지/shell story 별 폴더 구분
- 폰트:
  - `OwnglyphKonghae`

## 프로젝트에서 보여줄 수 있는 역량

- Flutter 기반 **중대형 앱 마이그레이션 경험**
- `Provider` 중심 상태관리 설계
- Supabase 인증/DB/Storage/RPC 연동
- 딥링크 및 인증 게이트 설계
- 디자인 토큰과 에셋 경로 체계화
- 기존 서비스의 기능 흐름을 유지한 채 구조를 재정비하는 작업

## 참고

- 일부 기억 데이터는 원본 `UYOUNG` 프로젝트와 동일하게 더미/로컬 데이터와 혼합될 수 있습니다.
- 이는 기존 서비스 흐름을 기준으로 화면 및 탐색 경험을 유지하기 위한 단계적 마이그레이션 전략의 일부입니다.
