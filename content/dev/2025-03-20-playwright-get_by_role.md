---
title: Playwright `page.get_by_role`
tags:
  - python
  - playwright
  - automation
  - testing
  - get_by_role
  - locator
---
Playwright `page.get_by_role` 역할 기반 요소 탐색

## Playwright `page.get_by_role` 가이드

### 1. `page.get_by_role`이란?  

Playwright의 `page.get_by_role` 메서드는 웹 페이지에서 요소를 역할(role)에 기반하여 탐색하는 강력한 도구입니다. 이는 접근성(Accessibility) 표준인 ARIA(Accessible Rich Internet Applications)를 활용하여 요소를 식별하며, HTML 태그 대신 사용자가 인식하는 기능적 역할을 기준으로 동작합니다.  

**역할(role)**이란 요소가 웹 페이지에서 수행하는 목적을 정의하는 속성으로, 예를 들어 버튼(`button`), 링크(`link`), 입력 필드(`textbox`) 등이 이에 해당합니다. `get_by_role`는 이러한 역할과 선택적으로 `name` 속성을 결합하여 요소를 정확히 찾아냅니다.  

#### 주요 기능  
- **접근성 기반 탐색:** ARIA 표준을 준수하여 요소를 식별.  
- **직관적 사용:** 개발자가 요소의 시각적 표현이나 태그 구조 대신 기능적 역할을 지정.  
- **유연성:** `name`, `checked`, `disabled` 등의 추가 옵션으로 세부 조정 가능.  

이 메서드는 Playwright의 테스트 자동화 및 웹 스크래핑 작업에서 신뢰성과 유지보수성을 높이는 데 적합합니다.  


### 2. `locator` 함수와의 기능적 차이  

Playwright의 `page.locator`와 `page.get_by_role`은 모두 요소를 탐색하지만, 접근 방식에서 차이가 있습니다.  

| 기능              | `page.locator`                          | `page.get_by_role`                     |  
|-------------------|-----------------------------------------|---------------------------------------|  
| **탐색 기준**     | CSS 선택자, XPath, 텍스트 등             | ARIA 역할 및 접근성 속성              |  
| **유연성**        | 세부적인 구조적 탐색 가능                | 역할 기반의 직관적 탐색               |  
| **복잡성**        | 복잡한 쿼리 작성 필요                   | 간단한 역할 및 이름 지정              |  
| **사용 예**       | 특정 클래스나 ID로 요소 찾기             | 버튼, 링크 등 기능적 요소 찾기         |  

`locator`는 구조적이고 세밀한 탐색에 유리한 반면, `get_by_role`은 접근성을 중시하며 기능적 관점에서 요소를 식별합니다. 예를 들어, `<div>` 태그가 버튼처럼 동작할 때 `locator`는 태그 구조에 의존하지만, `get_by_role`은 해당 요소의 역할(`button`)을 인식합니다.  


### 3. `get_by_role`에서 `role` / `name`의 역할  

- **`role`:** 요소의 기능적 목적을 정의합니다. ARIA 표준에서 정의된 값(예: `button`, `link`, `heading`)을 사용하며, HTML 태그와 직접적으로 연관되지 않을 수도 있습니다.  
- **`name`:** 요소의 접근성 이름을 지정하여 동일한 역할 중 특정 요소를 구체화합니다. 이는 보통 `<label>`, `aria-label`, 또는 텍스트 콘텐츠에서 추출됩니다.  

예를 들어, 페이지에 여러 버튼이 있을 때 `role="button"`만으로는 특정 버튼을 식별할 수 없으므로, `name`으로 버튼의 텍스트(예: "Submit")를 추가하여 정확히 타겟팅합니다.  


### 4. HTML 태그 `role` / `name` 탐색 조건  

`get_by_role`은 HTML 태그가 아닌 ARIA 역할(`role`)과 접근성 이름(`name`)을 기반으로 요소를 탐색합니다. HTML 태그는 암묵적인 역할을 가지지만, `role` 속성이 명시되면 이를 우선 적용하며, `name`은 동일한 역할의 요소를 구분하는 필수 조건으로 작용합니다. 아래는 태그, `role`, `name` 간의 매핑과 매칭 조건입니다.  


| 역할 (`role`)       | 이름 (`name`)                          | Python 코드 예시                                                  | HTML 예시                                                                 | 설명                                                                                   |
|---------------------|----------------------------------------|--------------------------------------------------------------------|---------------------------------------------------------------------------|----------------------------------------------------------------------------------------|
| `button`            | "Sign in"                              | `page.get_by_role("button", name="Sign in").click()`              | `<button>Sign in</button>`                                               | "Sign in" 텍스트를 가진 버튼을 클릭합니다.                                              |
| `link`              | "About"                                | `page.get_by_role("link", name="About").click()`                  | `<a href="#">About</a>`                                                  | "About" 텍스트를 가진 링크를 클릭합니다.                                                |
| `heading`           | "Sign up"                              | `page.get_by_role("heading", name="Sign up").is_visible()`        | `<h1>Sign up</h1>`                                                       | "Sign up" 텍스트를 가진 제목(heading)이 보이는지 확인합니다.                            |
| `checkbox`          | "Subscribe"                            | `page.get_by_role("checkbox", name="Subscribe").check()`          | `<input type="checkbox" id="sub"><label for="sub">Subscribe</label>`     | "Subscribe" 텍스트를 가진 체크박스를 선택합니다.                                        |
| `button`            | `/submit/i` (정규 표현식)              | `page.get_by_role("button", name=/submit/i).click()`              | `<button>Submit</button>` 또는 `<button>SUBMIT</button>`                 | "submit" 텍스트를 포함하는 (대소문자 구분 없이) 버튼을 클릭합니다.                      |
| `button`            | "Close dialog" (명시적 `name` 없음)    | `page.get_by_role("button").first().click()`                      | `<button>Close dialog</button><button>Other</button>`                    | 여러 버튼이 있는 경우 `name` 미지정 시 첫 번째 버튼을 선택. 오류 방지를 위해 구체화 필요. |
| `row`               | "A" (정확한 매칭)                     | `page.get_by_role("row", name="A", exact=True).is_visible()`      | `<tr><td>A</td></tr>`                                                    | "A" 텍스트를 정확히 가진 행(row)이 보이는지 확인합니다. `exact=True`로 부분 매칭 방지. |
| `link`              | `/read more about locators/i` (정규 표현식) | `page.get_by_role("link", name=/read more about locators/i).click()` | `<a href="#">Read more about locators</a>`                            | "read more about locators" 텍스트를 포함하는 (대소문자 구분 없이) 링크를 클릭합니다.    |
| `spinbutton`        | `{value: {now: 5, text: "medium"}}`   | `page.get_by_role("spinbutton", value={"now": 5, "text": "medium"})` | `<input role="spinbutton" aria-valuenow="5" aria-valuetext="medium">` | `aria-valuenow="5"`와 `aria-valuetext="medium"` 속성을 가진 `spinbutton`을 찾습니다.    |



#### `role` 및 `name` 매칭 조건  
- **`role` 매칭**:  
  - 기본 역할: HTML 태그가 암묵적으로 가지는 역할(예: `<button>` → `button`)이 적용됩니다.  
  - 명시적 역할: `role` 속성이 정의되면 기본 역할을 재정의합니다(예: `<a role="button">` → `button`).  
  - Playwright는 DOM에서 `role` 속성을 우선 탐지하며, 기본 역할은 속성이 없을 때만 적용됩니다.  

- **`name` 매칭**:  
  - **출처**: `name`은 요소의 접근성 이름으로, 다음 순서로 결정됩니다:  
    1. `aria-label` 속성(예: `<input aria-label="Search">` → "Search").  
    2. `<label>` 태그와의 연관(예: `<label for="id">Name</label><input id="id">` → "Name").  
    3. 텍스트 콘텐츠(예: `<button>Save</button>` → "Save").  
  - **조건**: 동일한 `role`을 가진 요소가 여러 개일 경우, `name`으로 특정 요소를 필터링합니다. `name`이 일치하지 않으면 해당 요소는 무시됩니다.  
  - **대소문자 무시**: `name` 매칭은 대소문자를 구분하지 않습니다(예: "save"와 "Save"는 동일).  

#### 추가 고려사항  
- **우선순위**: `role` 속성이 기본 역할보다 우선하며, `name`은 `role` 매칭 후 필터링 조건으로 작용합니다.  
- **접근성**: `name`은 스크린 리더가 요소를 사용자에게 설명하는 데 사용되므로, 정확한 매칭을 위해 필수적입니다.  
- **Playwright 동작**: `get_by_role`은 `role`과 `name`을 결합하여 요소를 식별하며, `name`이 지정되지 않으면 모든 일치하는 `role`을 반환합니다(단, 여러 요소가 매칭되면 오류 발생 가능).  

**설명**: `role`은 요소의 기능을 정의하고, `name`은 동일 역할 내에서 고유성을 보장합니다. Playwright는 이 두 조건을 기반으로 요소를 탐색하며, HTML 태그의 구조적 특성보다 기능적 의도를 우선시합니다.  


### 5. 예제 HTML 및 코드  

다음은 `get_by_role` 사용을 설명하기 위한 HTML과 Python 코드입니다.  

#### 예제 HTML  
```html  
<!DOCTYPE html>  
<html>  
<head><title>Sample Page</title></head>  
<body>  
  <h1>Welcome</h1>  
  <button>Click Me</button>  
  <button>Submit</button>  
  <input type="text" aria-label="Username">  
  <a href="#" role="button">Custom Button Link</a>  
</body>  
</html>  
```

#### 예제 코드  
```python  
from playwright.sync_api import sync_playwright  

with sync_playwright() as p:  
    browser = p.chromium.launch()  
    page = browser.new_page()  
    page.goto("file:///path/to/sample.html")  

    # 버튼 찾기 (name으로 구체화)  
    submit_button = page.get_by_role("button", name="Submit")  
    submit_button.click()  

    # 텍스트 입력 필드 찾기  
    username_field = page.get_by_role("textbox", name="Username")  
    username_field.fill("testuser")  

    # 속성으로 정의된 role 사용  
    custom_button = page.get_by_role("button", name="Custom Button Link")  
    custom_button.click()  

    browser.close()  
```

위 코드는 `role`과 `name`을 결합하여 요소를 정확히 탐색하고 상호작용합니다. 특히 `<a role="button">`는 `role` 속성을 통해 버튼으로 인식됩니다.  


### 6. `get_by_role`로 해결하지 못하는 경우: `locator` 활용  

`get_by_role`은 역할 기반 탐색에 강점이 있지만, 특정 상황에서는 한계가 있습니다. 이 경우 `locator` 메서드와 `has` 또는 `has_text` 옵션을 사용합니다.  

#### 한계 예  
- **복잡한 중첩 구조:** 역할만으로 요소를 구분하기 어려운 경우.  
- **역할 미지정:** ARIA 속성이 없는 요소.  
- **텍스트 기반 필터링:** 특정 텍스트를 포함한 요소를 세부적으로 찾을 때.  

#### `locator` 사용 예  
```python  
# 중첩된 요소 찾기  
nested_button = page.locator("div.container").get_by_role("button", name="Save")  

# 텍스트로 필터링  
text_filtered = page.locator("li").filter(has_text="Item 1")  

# 특정 요소 포함 여부 확인  
parent_with_child = page.locator("section").filter(has=page.get_by_role("heading"))  
```

- **`has`:** 특정 하위 요소를 포함하는 상위 요소를 찾음.  
- **`has_text`:** 텍스트 콘텐츠를 기반으로 필터링.  

이러한 방식은 `get_by_role`의 직관성을 보완하며, 복잡한 DOM 구조에서도 유연하게 대응합니다.  


### 결론  

Playwright의 `page.get_by_role`은 접근성 표준을 기반으로 요소를 직관적이고 신뢰성 있게 탐색하는 도구입니다. `role`과 `name`을 활용하여 기능적 관점에서 요소를 식별하며, `locator` 대비 간결함을 제공합니다. 특히 `role` 속성을 통해 태그의 기본 역할을 재정의한 요소도 정확히 탐색할 수 있습니다. 그러나 복잡한 구조나 역할 미지정 요소에서는 `locator`와의 조합이 필요합니다.  

테스트 자동화나 웹 스크래핑에서 유지보수성과 정확성을 높이고자 한다면, `get_by_role`을 적극 활용하고, 한계 상황에서는 `locator`를 보완적으로 사용하는 접근을 추천합니다.  

