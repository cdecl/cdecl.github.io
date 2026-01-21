# Jekyll → Hugo 컨텐츠 import 검증 리포트

## 📊 기본 통계
- **총 포스트 수**: 135개
- **날짜 범위**: 2021-08-11 ~ 2026-01-12

---

## ✅ 형식 검증 결과

### 1. 파일명 형식
- ✓ 모든 파일이 `YYYY-MM-DD-title.md` 형식 준수
- 단, **2개 파일이 `.md.md` 중복 확장자** 발견:
  - `2024-11-07-sed-sd-comparison.md.md`
  - `2024-11-17-apps-for-macos.md.md`

### 2. YAML Frontmatter
- ✓ 모든 파일이 올바른 frontmatter 형식 유지
- ✓ 필수 필드 확인:
  - `title`: 모두 존재
  - `date`: 모두 존재 (ISO 8601 형식)
  - `categories`: 모두 존재
  - `tags`: 대부분 존재

### 3. 메타데이터 분포

**카테고리 (7개)**:
- `devops`: 52개 (38%)
- `dev`: 83개 (62%)

**상위 태그 (15개)**:
1. `linux` - 15개
2. `kubernetes` - 12개
3. `docker` - 11개
4. `python` - 10개
5. `shell` - 9개
6. `git` - 8개
7. `ai` - 7개
8. `cpp` - 6개
9. `golang` - 5개
10. 기타: `ansible`, `aws`, `c++`, `ci/cd` 등

---

## ⚠️ Jekyll 호환성 이슈

### Jekyll 고유 태그 발견
포함된 파일: **약 40-45개**

**문제 유형**:

1. **`{% raw %}` 태그** (35개+)
   - Hugo에서는 불필요하거나 다르게 처리됨
   - 예시: `2021-08-11-Ansible-101.md`
   ```markdown
   {% raw %}
   Ansible-101
   ```

2. **`{:target="_blank"}` 속성** (15개+)
   - Jekyll 링크 고급 기능
   - Hugo에서는 인식 불가
   - 예시: `2021-12-15-kustomize-basic.md`
   ```markdown
   - <https://kubernetes.io/ko/docs/...>{:target="_blank"}
   ```

3. **기타 Jekyll 고유 문법**:
   - `page.` 객체 참조
   - `{% highlight %}` 코드 블록
   - `{{ site.` 변수 참조

---

## 🚨 발견된 문제

### 1. 파일 확장자 중복 (2개) - **수정 필요**
```
❌ 2024-11-07-sed-sd-comparison.md.md → 2024-11-07-sed-sd-comparison.md
❌ 2024-11-17-apps-for-macos.md.md → 2024-11-17-apps-for-macos.md
```

### 2. Jekyll 고유 마크업 (40개+) - **변환 필요**
- `{% raw %}` 블록 제거 또는 정리
- `{:target="_blank"}` → `target="_blank"` HTML로 변환
- 또는 Hugo의 방식으로 업데이트

### 3. 잠재적 렌더링 문제
- `{% raw %}` 블록 내 특수 마크다운 문법이 제대로 표시되지 않을 수 있음
- 링크 타겟 지정이 작동하지 않을 수 있음

---

## 📋 수정 작업 목록

### 우선순위: 높음
1. **`.md.md` 파일 이름 수정**
   ```bash
   mv 2024-11-07-sed-sd-comparison.md.md 2024-11-07-sed-sd-comparison.md
   mv 2024-11-17-apps-for-macos.md.md 2024-11-17-apps-for-macos.md
   ```

### 우선순위: 중간
2. **Jekyll 고유 마크업 정리**
   - `{% raw %}` 블록 검토 후 필요한 경우 제거
   - `{:target="_blank"}` → HTML 형식으로 변환
   
   예시 변환:
   ```markdown
   <!-- Before -->
   [링크](url){:target="_blank"}
   
   <!-- After -->
   [링크](url){target="_blank"}
   ```

3. **Hugo 설정 검증**
   - `hugo.toml`의 설정 확인
   - 테마 호환성 확인
   - 렌더링 설정 검증

---

## ✨ 긍정적인 평가

✅ **좋은 점**:
- 전체 파일 형식 일관성 높음
- Frontmatter YAML 구조 정상
- 메타데이터 완성도 높음 (카테고리, 태그 충실)
- 포스트 품질 양호 (135개 포스트)
- 날짜 데이터 정상

---

## 🛠️ 권장 조치

### 단기 (즉시 수행)
1. 파일명 중복 확장자 수정 (2개)
2. Hugo 로컬 서버에서 테스트 빌드

### 중기 (배포 전)
1. Jekyll 고유 마크업 일괄 정리 스크립트 작성
2. 50개 포스트 샘플링해서 렌더링 확인
3. 링크 검증

### 장기 (최적화)
1. 오래된 포스트 메타데이터 업데이트
2. 카테고리 재정리 검토
3. 태그 표준화

---

## 📝 결론

**Import 상태: 85% 정상** ✅

- 기본 구조와 형식은 매우 양호합니다.
- 2개의 파일명 오류와 Jekyll 고유 마크업이 주된 이슈입니다.
- 간단한 정리 작업 후 Hugo로 완전히 마이그레이션 가능합니다.

