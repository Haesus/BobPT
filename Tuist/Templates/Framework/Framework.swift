//
//  Framework.swift
//  ProjectDescriptionHelpers
//
//  Created by 윤해수 on 11/19/25.
//

import Foundation
import ProjectDescription

// 모듈의 Layer (예: Feature, Domain, Core)를 입력받는 템플릿 속성
let layerAttribute: Template.Attribute = .required("layer")

// 생성할 모듈의 이름을 입력받는 템플릿 속성
let nameAttribute: Template.Attribute = .required("name")

// 생성 시점의 날짜를 기본값으로 제공하는 템플릿 속성
// Stencil 파일에서 생성일자 삽입에 활용 가능
let nowDateAttribute: Template.Attribute = .optional("nowDate", default: .string(getNowDateString()))

// 사용자 이름 가져오기(MacOS 사용자 정보)
let authorAttribute: Template.Attribute = .optional("author", default: .string(NSFullUserName()))

// MARK: - Tuist Template 정의
// layer/name/날짜를 입력받아 TMA 기반 모듈 구조 전체를 자동 생성하는 템플릿
let template = Template(
  description: "Generate Module",
  attributes: [
    // 레이어 구분 값 (Feature/Domain/Core)
    layerAttribute,
    // 모듈명 (예: Login, UserInfo)
    nameAttribute,
    // 생성 날짜 (기본값: 오늘 날짜)
    nowDateAttribute,
    // 사용자 정보
    authorAttribute
  ],
  // MARK: - 템플릿이 생성할 전체 파일/디렉토리 구조 정의
  // 필요한 모든 모듈 구조(Project, Sources, Interface, Tests, Example)을 일괄 생성
  items: [
    // Project.swift 생성 - 모듈의 메타정보를 담는 Tuist 프로젝트 파일
    .file(
      path: "Projects/\(layerAttribute)/\(nameAttribute)/Project.swift",
      templatePath: "Stencil/Project.stencil"
    ),

    // 기본 소스 파일 생성 (모듈의 메인 구현 영역)
    .file(
      path: "Projects/\(layerAttribute)/\(nameAttribute)/Sources/\(nameAttribute).swift",
      templatePath: "Stencil/Source.stencil"
    ),

    // 리소스 폴더 생성 - 최소 1개 파일(dummy)로 폴더 유지
    .string(
      path: "Projects/\(layerAttribute)/\(nameAttribute)/Resources/dummy.txt",
      contents: "dummy file"
    ),

    // Interface 레이어 생성 (외부에 노출되는 프로토콜/타입)
    .file(
      path: "Projects/\(layerAttribute)/\(nameAttribute)/Interface/\(nameAttribute)Interface.swift",
      templatePath: "Stencil/Interface.stencil"
    ),

    // Tests 폴더 생성 - 유닛 테스트 파일
    .file(
      path: "Projects/\(layerAttribute)/\(nameAttribute)/Tests/\(nameAttribute)Tests.swift",
      templatePath: "Stencil/Tests.stencil"
    ),

    // Testing 폴더 생성 - Mock/Stub 등 테스트 유틸용 파일
    .file(
      path: "Projects/\(layerAttribute)/\(nameAttribute)/Testing/\(nameAttribute)Testing.swift",
      templatePath: "Stencil/Testing.stencil"
    ),

    // Example 앱 생성 - 모듈을 직접 실행/미리보기 할 수 있는 데모 앱 구조
    .file(
      path: "Projects/\(layerAttribute)/\(nameAttribute)/Example/Sources/\(nameAttribute)App.swift",
      templatePath: "Stencil/App.stencil"
    ),
    .file(
      path: "Projects/\(layerAttribute)/\(nameAttribute)/Example/Sources/ContentView.swift",
      templatePath: "Stencil/ContentView.stencil"
    ),
    .file(
      path: "Projects/\(layerAttribute)/\(nameAttribute)/Example/Resources/LaunchScreen.storyboard",
      templatePath: "Stencil/LaunchScreen.stencil"
    ),
    .directory(
      path: "Projects/\(layerAttribute)/\(nameAttribute)/Example/Resources/",
      sourcePath: "Font"
    ),
    .directory(
      path: "Projects/\(layerAttribute)/\(nameAttribute)/Example/Resources/",
      sourcePath: "Assets.xcassets"
    )
  ]
)

// 현재 날짜(M/d/yy 형식)를 문자열로 생성하는 유틸 함수
// 템플릿 생성 시 파일 헤더 등에 사용 가능
func getNowDateString() -> String {
  let formatter = DateFormatter()
  formatter.dateFormat = "M/d/yy"
  return formatter.string(from: Date())
}
