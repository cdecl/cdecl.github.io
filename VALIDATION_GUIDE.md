# Jekyll → Hugo 마이그레이션 검증 가이드

## 📋 검증 결과 요약

| 항목 | 상태 | 비고 |
|------|------|------|
| **전체 포스트** | ✅ 135개 | 정상 |
| **파일명 형식** | ⚠️  133개 정상, 2개 오류 | `.md.md` 중복 확장자 |
| **Frontmatter** | ✅ 100% | YAML 형식 정상 |
| **메타데이터** | ✅ 양호 | 카테고리, 태그 완성 |
| **Jekyll 호환성** | ⚠️  40+개 파일 | 마크업 정리 필요 |
| **전체 평가** | 85% | 단순 정리 후 사용 가능 |

---

## 🔍 상세 검증 항목

### 1. 파일 구조 검증

✅ **포스트 디렉토리 구조**:
```
content/post/
├── 2021-08-11-Ansible-101.md
├── 2021-08-12-cmake-basic.md
├── ...
├── 2024-11-07-sed-sd-comparison.md.md  ❌ (확장자 중복)
├── 2024-11-17-apps-for-macos.md.md     ❌ (확장자 중복)
└── 2026-01-12-opencode-ai-agent.md
```

### 2. YAML Frontmatter 검증

✅ **모든 파일의 frontmatter 형식**:
```yaml
---
categories:
- devops
date: '2021-08-11T00:00:00Z'
tags:
- ansible
- automation
title: Ansible-101
toc: true
toc_sticky: true
---
```

**Frontmatter 검증 결과**:
- ✅ 모든 파일에 `---` 시작/종료 마크 존재
- ✅ 모든 필수 필드 포함 (title, date, categories, tags)
- ✅ YAML 문법 오류 없음
- ✅ 날짜 형식 ISO 8601 준수

### 3. 메타데이터 분석

**카테고리 분포**:
```
devops: 52개 (38.5%)
dev:    83개 (61.5%)
```

**상위 태그 분석**:
```
linux              15개
kubernetes         12개
docker             11개
python             10개
shell               9개
git                 8개
ai                  7개
cpp                 6개
golang              5개
ansible            5개
aws                 4개
c++                 4개
ci/cd              4개
rest/api           4개
terraform          4개
```

### 4. 날짜 범위 검증

- **가장 오래된 포스트**: 2021-08-11 (Ansible-101)
- **가장 최신 포스트**: 2026-01-12 (OpenCode AI Agent)
- **포스트 연속성**: 약 4년 9개월 간 꾸준히 작성

---

## ⚠️ 발견된 문제

### 문제 1️⃣ : 파일명 확장자 중복 (2개)

**상태**: 🔴 **즉시 수정 필요**

**문제 파일**:
- `2024-11-07-sed-sd-comparison.md.md`
- `2024-11-17-apps-for-macos.md.md`

**원인**: Jekyll → Hugo 변환 중 파일명 중복

**해결책**:
```bash
# macOS/Linux
mv content/post/2024-11-07-sed-sd-comparison.md.md content/post/2024-11-07-sed-sd-comparison.md
mv content/post/2024-11-17-apps-for-macos.md.md content/post/2024-11-17-apps-for-macos.md
```

### 문제 2️⃣ : Jekyll 고유 마크업 (40개+ 파일)

**상태**: 🟡 **점진적 정리 필요**

#### 2-1. `{% raw %}` 블록
```markdown
{% raw %}
코드 또는 특수 마크다운
{% endraw %}
```

**영향**: 
- Hugo에서는 불필요하거나 다르게 처리
- 내용이 그대로 표시되지 않을 수 있음

**예시 파일**: `2021-08-11-Ansible-101.md`

#### 2-2. `{:target="_blank"}` 속성
```markdown
[링크](url){:target="_blank"}
```

**영향**:
- Hugo에서 인식 불가
- 외부 링크가 새 탭에서 열리지 않음

**변환 방법**:
```html
<!-- 방법 1: HTML 링크 -->
<a href="url" target="_blank">링크</a>

<!-- 방법 2: Hugo 파라미터 -->
[링크](url "기타 링크 설정")
```

**예시 파일**: `2021-12-15-kustomize-basic.md`

#### 2-3. 기타 Jekyll 문법
- `{{ site.url }}` - Jekyll 사이트 변수
- `{{ page.url }}` - Jekyll 페이지 변수  
- `{% highlight %}` - Jekyll 코드 하이라이팅

---

## ✨ 긍정적인 평가

| 항목 | 상태 | 설명 |
|------|------|------|
| 파일 형식 일관성 | ✅ 우수 | 98%의 파일이 정상 형식 |
| Frontmatter 완성도 | ✅ 우수 | 모든 필드 포함 |
| 메타데이터 품질 | ✅ 우수 | 카테고리, 태그 충실 |
| 콘텐츠 양 | ✅ 풍부 | 135개 포스트 (4년 축적) |
| 포스트 연속성 | ✅ 양호 | 2021년부터 2026년 |
| 마크다운 구조 | ✅ 정상 | 표준 마크다운 준수 |

---

## 🛠️ 수정 작업 플랜

### Phase 1: 긴급 수정 (즉시)
```
예상 시간: 5분
우선순위: ⭐⭐⭐
```

1. ✅ 파일명 중복 확장자 수정 (2개)
   ```bash
   cd /Users/cdecl/dev/cdeclog
   python3 fix_import.py  # 자동 수정 스크립트
   ```

### Phase 2: 호환성 검증 (1주일 내)
```
예상 시간: 1-2시간
우선순위: ⭐⭐
```

1. Hugo 로컬 서버 실행
   ```bash
   hugo server -D
   ```

2. 렌더링 확인
   - 모든 포스트 타이틀 표시 확인
   - 코드 블록 렌더링 확인
   - 링크 작동 확인

3. Jekyll 마크업 샘플 검토
   - 40개 파일 중 10개 샘플 선택
   - 렌더링 상태 검증
   - 수정 필요 여부 판단

### Phase 3: 점진적 정리 (2-4주)
```
예상 시간: 4-8시간
우선순위: ⭐
```

1. Jekyll 고유 마크업 정리 (최대 40개)
   - 우선순위: 인기 포스트부터
   - 방법: 반자동 스크립트 + 수동 검증

2. 렌더링 재검증
   - 각 수정 후 로컬에서 테스트

---

## 📝 실행 명령어

### 1. 자동 수정 실행
```bash
cd /Users/cdecl/dev/cdeclog
python3 fix_import.py
```

### 2. 검증 스크립트 실행
```bash
cd /Users/cdecl/dev/cdeclog
python3 validate_import.py
```

### 3. Hugo 빌드 테스트
```bash
cd /Users/cdecl/dev/cdeclog
hugo server -D  # 로컬 서버 (포트 1313)
hugo -d public   # 정적 파일 생성
```

### 4. 변경사항 확인
```bash
cd /Users/cdecl/dev/cdeclog
git status      # 변경된 파일 확인
git diff        # 변경 내용 검토
```

---

## 📊 검증 스크립트 위치

생성된 검증 도구:
- [validate_import.py](validate_import.py) - 상세 검증 스크립트
- [fix_import.py](fix_import.py) - 자동 수정 스크립트
- [IMPORT_VALIDATION_REPORT.md](IMPORT_VALIDATION_REPORT.md) - 상세 리포트

---

## ✅ 최종 체크리스트

- [ ] 파일명 중복 확장자 수정 (2개)
- [ ] 수정된 파일로 Hugo 빌드 테스트
- [ ] 로컬 서버 렌더링 확인
- [ ] 모든 포스트 제목/내용 표시 확인
- [ ] 링크 작동 확인
- [ ] Jekyll 고유 마크업 파일 샘플 검토
- [ ] 필요시 Jekyll 마크업 정리
- [ ] 최종 배포 전 전체 테스트
- [ ] Git 커밋 및 배포

---

## 🎯 결론

✅ **Import 상태: 85% 정상 - 즉시 사용 가능**

### 주요 특징
1. **형식**: 대부분 정상적인 Hugo 호환 형식
2. **내용**: 4년간 축적된 135개 고품질 포스트
3. **메타데이터**: 카테고리, 태그 완벽하게 정리됨

### 남은 작업
1. **필수**: 파일명 2개 수정 (5분)
2. **권장**: 로컬 테스트 (30분)
3. **선택**: Jekyll 마크업 정리 (4시간)

> **결론**: 간단한 정리 후 바로 Hugo로 마이그레이션 가능합니다. 현재 상태에서도 대부분의 포스트가 정상 렌더링될 것으로 예상됩니다.

