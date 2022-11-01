# 1. 작업 흐름(Workflow)
- 이슈 발급 -> 커밋 -> 이슈종료 지향<br>Issuing -> Commit -> Issue closing<br><br><br>

# 2. 이슈 컨벤션(Issue Convention)
- Issue의 title은 tag로 시작한다<br>Start with a tag when creating an issue

- PR 메시지 작성 전 Issue를 먼저 생성하고 PR 메시지에 연결한다<br>Create an issue then connect it to the pull request message

- 작업에 대한 원인 또는 흐름 등을 작성한다<br>Write the reason(s) of the work or workflow

- 버그 이슈일 때는 버그의 재현방법을 자세히 기술한다<br>When the issue is related to a bug, describe the bug regeneration condition in detail<br><br><br>

# 3. 커밋 컨벤션(Commit Convention)
## 3.1. 커밋 메시지 구조(Commit Message Structure)<br>

> ① Type: ② Subject<br><br>
> ③ Body<br><br>
> ④ Footer

<br>

## 3.2. 각 항목의 설명(Explanation for each item)
### ① Type(필수; required)
타입에는 작업 타입을 나타내는 태그를 적습니다.<br>In the section of type, place a type that can represent the type of your current work<br><br>
작업 타입에는 대략 다음과 같은 종류가 있습니다.<br>The representative work types are as follows<br><br>
|*Type*|*Subject*|
|:---|:---|
|**[Feat]**|새로운 기능 추가|
|**[Add]**|새로운 뷰, 에셋, 파일, 데이터... 추가|
|**[Fix]**|버그 수정|
|**[Build]**|빌드 관련 파일 수정|
|**[Design]**|UI Design 변경|
|**[Docs]**|문서 (문서 추가, 수정, 삭제)|
|**[Style]**|스타일 (코드 형식, 세미콜론 추가: 비즈니스 로직에 변경 없는 경우)|
|**[Refactor]**|코드 리팩토링|
|**[Rename]**|파일명 또는 디렉토리명을 단순히 변경만 한 경우|
|**[Delete]**|파일 또는 디렉토리를 단순히 삭제만 한 경우|

예시) [Type] #이슈번호 커밋메세지 `git commit -m "[Feat] #12 로그인 기능 추가"`<br><br>

### ② Subject(필수; required)
- 서브젝트는 50글자가 넘지 않도록 작성합니다.<br>It is recommended not to exceed 50 characters writing a subject<br><br>
- 서브젝트는 마침표를 찍지 않습니다.<br>You **do not** use a period writing a subject<br><br>
- 영어로 작성하는 경우 첫 문자는 대문자로 작성합니다.<br>If the subject is written in English, the first character must be capitalized<br>
<br><br>

### ③ Body(옵셔널; optional)
- 바디는 서브젝트에서 한 줄 건너뛰고 작성합니다.<br>Leave one blank line between the subject section and body section<br><br>
- 바디는 없어도 큰 문제가 없는 경우도 많습니다. 따라서 항상 작성해야 하는 부분은 아닙니다.<br>You do not asked to write the body section. The body section is completely optional<br><br>
- 설명해야 하는 변경점이 있는 경우에만 작성하도록 합시다!<br>If you need to explain something to others, then write the body section<br><br>
- 바디에는 뭐가 어떻게 변경됐다는 구체적 정보보다는 왜 이 작업을 했는지에 대한 정보를 적는 것이 좋습니다.<br>It is better to write the reason for your work than write the concrete contents of the work<br>
<br><br>

### ④ Footer(옵셔널; optional)
- 푸터도 바디와 마찬가지로 옵션입니다.<br>The footer section is another optional section to write<br><br>
- 푸터의 경우 일반적으로 트래킹하는 이슈가 있는 경우 트래커 ID를 표기할 때 사용합니다.<br>Typically, the footer is to display the current tracking issue if there is one<br><br>
- '#' 를 누르면 이슈 번호나 커밋 번호를 확인할 수 있습니다.<br>You can see the issue number or commit number when you put a '**#**' character<br><br>
- 필요한 경우 푸터를 남겨주세요!<br>Write the footer if it is required to do so<br>
<br><br><br>



# 4. PR 컨벤션(Pull Request Convention)
## 4.1. PR 메시지 구조(Pull Request Message Structure)
> ① Motivation<br><br>
> ② Key Changes<br><br>
> ③ To Reviewers

<br>

## 4.2. 각 항목의 설명(Explanation for each item)
### ① Motivation(필수; Required)
- 모티베이션 섹션에는 작업이 필요한 이유를 적습니다.<br>In the **Motivation** section, it is required to write the reason for your current work<br><br>

### ② Key Changes(필수; Required)
- 키 체인지즈 섹션에는 실제 작업 내용을 적습니다.<br>In the **Key Changes** section, write the concrete contents of your work<br><br>
- 구체적인 코드 변경분보다는 클래스, 메서드 등의 로직에 대해 설명하는 것이 추천됩니다.<br>It is recommended not to write the code itself, but write the logic of the class, method, etc.<br><br>

### ③ To Reviewers(필수; Required)
- 투 리뷰어즈 섹션에는 리뷰어가 주의 깊에 보아야 하는 중요 부분을 적습니다.<br>In the **To Reviewers** section, it is recommended to write the core part you wish the reviewer to review
