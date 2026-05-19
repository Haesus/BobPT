//
//  Project+Extension.swift
//  ProjectDescriptionHelpers
//
//  Created by 윤해수 on 11/19/25.
//

import DependencyPlugin
import ProjectDescription
import UtilityPlugin

// MARK: - Project factory helpers for TMA-based modular architecture
extension Project {
  /// TMA 구조(Modulable 모듈)를 기반으로
  /// Sources / Interface / Tests / Testing / Example 타겟들을 한 번에 생성하는 Project 팩토리 메서드
  public static func makeTMABasedProject<T: Modulable>(
    module: T,
    options: Project.Options = .options(disableSynthesizedResourceAccessors: true),
    packages: [Package] = [],
    infoPlist: InfoPlist = .default,
    includeResource: Bool = false,
    scripts: [TargetScript],
    targets: Set<TargetType>, // ex) [.sources, .interface, .tests, .testing, .example]
    dependencies: [TargetType: [TargetDependency]],
    coreDataModels: [CoreDataModel] = [],
    schemes: [Scheme] = [],
    resourceSynthesizers: [ResourceSynthesizer] = []
  ) -> Project {
    // Modulable 타입명을 문자열로 변환하여 모듈 이름으로 사용
    let name = String(describing: module)
    // 생성할 Target들을 누적해서 담아둘 배열
    var projectTargets: [Target] = []
    // 요청받은 TargetType 집합을 순회하면서 각각에 해당하는 Tuist Target 생성
    targets.forEach { targetType in
      let targetName = "\(name)\(targetType.suffixName)"
      let currentDependencies = dependencies[targetType] ?? []

      switch targetType {
          // 실제 구현 소스가 들어가는 메인 타겟 (Feature / Domain / Core 등)
        case .sources:
          // 리소스 포함 여부에 따라 정적 프레임워크/라이브러리 선택
          let product: Product = if includeResource {
            .staticFramework // currentConfig == .dev ? .framework : .staticFramework
          } else {
            .staticLibrary // currentConfig == .dev ? .framework : .staticLibrary
          }
          // includeResource가 true인 경우에만 Resources 폴더를 리소스로 포함
          let resources: ResourceFileElements? = ["Resources/**"]
          // Interface 타겟이 존재하면 구현(Sources) 타겟이 Interface에 의존하도록 연결
          let interfaceDependency: [TargetDependency] = targets.contains(.interface) ? [.target(name: "\(name)Interface")] : []
          // Interface 의존성과 외부에서 전달된 의존성을 합쳐 최종 dependencies 구성
          let dependencies: [TargetDependency] = (interfaceDependency + currentDependencies).compactMap { $0 }
          let sourceTargetSettings: Settings = .settings(
            base: [
              "ASSETCATALOG_COMPILER_APPICON_NAME": ""
            ],
            defaultSettings: .recommended
          )
          // Sources 타겟 정의 (소스 경로, 리소스, 스크립트, 의존성 설정)
          let target: Target = .target(
            name: targetName,
            product: product,
            infoPlist: infoPlist,
            sources: ["Sources/**/*.swift"],
            resources: resources,
            scripts: scripts,
            dependencies: dependencies,
            settings: sourceTargetSettings,
            coreDataModels: coreDataModels
          )
          projectTargets.append(target)

          // 외부에서 의존하는 public protocol / type만 노출하는 Interface 타겟
        case .interface:
          // Interface는 구현 없이 시그니처만 노출하므로 정적 라이브러리로 구성
          let product: Product = .staticLibrary //currentConfig == .dev ? .framework : .staticLibrary
          // Interface 타겟 정의 (Interface 디렉터리만 소스로 사용)
          let target: Target = .target(
            name: targetName,
            product: product,
            infoPlist: infoPlist,
            sources: ["Interface/**/*.swift"],
            resources: nil,
            scripts: [],
            dependencies: currentDependencies,
            coreDataModels: []
          )
          projectTargets.append(target)

          // 유닛 테스트용 타겟
        case .tests:
          // 테스트 타겟은 기본적으로 메인 Sources 타겟에 의존
          let sourcesDependency: [TargetDependency] = [.target(name: "\(name)")]
          // Testing 타겟이 있으면 그쪽의 Mock/Stub에도 함께 의존
          let testingDependency: [TargetDependency] = targets.contains(.testing) ? [.target(name: "\(name)Testing")] : []
          // 메인, Testing, 추가 의존성을 모두 합쳐 최종 테스트 의존성 구성
          let dependencies: [TargetDependency] = (sourcesDependency + testingDependency + currentDependencies).compactMap { $0 }
          // Tests 타겟 정의 (Tests 디렉터리를 소스로 사용)
          let target: Target = .target(
            name: targetName,
            product: .unitTests,
            infoPlist: infoPlist,
            sources: ["Tests/**/*.swift"],
            resources: nil,
            scripts: [],
            dependencies: dependencies,
            coreDataModels: []
          )
          projectTargets.append(target)

          // 테스트에서 공통으로 사용하는 Mock / Stub 등을 담는 Testing 타겟
        case .testing:
          // Testing용은 보통 여러 테스트 타겟에서 재사용하므로 정적 프레임워크로 구성
          let product: Product = .staticFramework // currentConfig == .dev ? .framework : .staticFramework
          // Interface가 있을 경우 Testing에서도 동일한 인터페이스에 의존
          let interfaceDependency: [TargetDependency] = targets.contains(.interface) ? [.target(name: "\(name)Interface")] : []
          // Testing 타겟 정의 (Testing 디렉터리의 테스트용 코드 포함)
          let dependencies: [TargetDependency] = (interfaceDependency + currentDependencies).compactMap { $0 }
          let target: Target = .target(
            name: targetName,
            product: product,
            infoPlist: infoPlist,
            sources: ["Testing/**/*.swift"],
            resources: nil,
            scripts: [],
            dependencies: dependencies,
            coreDataModels: []
          )
          projectTargets.append(target)

          // 데모용 샘플 앱 타겟 (Example)
        case .example:
          // Example 앱은 실제 구현(Sources) 타겟에 의존
          let sourcesDependency: [TargetDependency] = [.target(name: "\(name)")]
          // 필요 시 Testing 타겟의 Mock/Stub도 함께 의존성으로 추가
          let testingDependency: [TargetDependency] = targets.contains(.testing) ? [.target(name: "\(name)Testing")] : []
          // Example 데모 앱 타겟 정의 (샘플 화면/리소스, 개발용 스크립트 포함)
          let debugDependencies: [TargetDependency] = []
          let dependencies: [TargetDependency] = (sourcesDependency + testingDependency + currentDependencies + debugDependencies).compactMap { $0 }
          let devConfig = BuildConfiguration.dev
          let releaseConfig = BuildConfiguration.release
          let betaConfig = BuildConfiguration.beta
          let exampleSettings: Settings = .settings(
            configurations: [
              .debug(
                name: devConfig.configurationName,
                xcconfig: .appXCConfig(for: devConfig)
              ),
              .release(
                name: releaseConfig.configurationName,
                xcconfig: .appXCConfig(for: releaseConfig)
              ),
              .release(
                name: betaConfig.configurationName,
                xcconfig: .appXCConfig(for: betaConfig)
              )
            ],
            defaultSettings: .recommended
          )
          let target: Target = .target(
            name: targetName,
            product: .app,
            infoPlist: InfoPlist.Example.app(name: targetName),
            sources: ["Example/Sources/**/*.swift"],
            resources: [
              "Example/Resources/**"
            ],
            scripts: [],
            dependencies: dependencies,
            settings: exampleSettings,
            coreDataModels: []
          )
          projectTargets.append(target)
      }
    }

    // 위에서 생성한 Target 배열(projectTargets)을 이용해 최종 Project 인스턴스 생성
    return .init(
      name: name,
      organizationName: AppEnv.organizationName,
      options: options,
      packages: packages,
      settings: .projectSettings(),
      targets: projectTargets,
      schemes: schemes,
      fileHeaderTemplate: nil,
      additionalFiles: [],
      resourceSynthesizers: resourceSynthesizers
    )
  }

  /// 단일 Modulable 모듈에 대해 하나의 Target만 생성하는 간단한 Project 팩토리 메서드
  public static func makeProject<T: Modulable>(
    module: T,
    options: Project.Options = .options(disableSynthesizedResourceAccessors: true),
    packages: [Package] = [],
    infoPlist: InfoPlist = .default,
    includeResource: Bool = false,
    scripts: [TargetScript],
    product: Product,
    dependencies: [TargetDependency],
    coreDataModels: [CoreDataModel] = [],
    schemes: [Scheme] = [],
    resourceSynthesizers: [ResourceSynthesizer] = []
  ) -> Project {
    // Modulable 타입명을 타겟/프로젝트 이름으로 사용
    let targetName = String(describing: module)
    // 필요 시 Resources 디렉터리를 리소스로 포함
    let resources: ResourceFileElements? = includeResource ? ["Resources/**"] : nil
    // 단일 타겟 정의 (product, sources, resources, scripts, dependencies 설정)
    let target: Target = .target(
      name: targetName,
      product: product,
      infoPlist: infoPlist,
      sources: ["Sources/**/*.swift"],
      resources: resources,
      scripts: scripts,
      dependencies: dependencies,
      coreDataModels: coreDataModels
    )
    // 위에서 정의한 타겟 하나만을 포함하는 Project 생성
    return .init(
      name: targetName,
      organizationName: AppEnv.organizationName,
      options: options,
      packages: packages,
      settings: .projectSettings(),
      targets: [target],
      schemes: schemes,
      fileHeaderTemplate: nil,
      additionalFiles: [],
      resourceSynthesizers: resourceSynthesizers
    )
  }

  /// Modulable enum을 루트로 하여, 모든 케이스를 child 모듈로 두는 루트 Project 생성
  /// 각 케이스는 .dependency(module:)를 통해 하위 모듈로 연결됨
  public static func makeRootProject<T: Modulable>(
    rootModule: T.Type,
    options: Project.Options = .options(disableSynthesizedResourceAccessors: true),
    packages: [Package] = [],
    infoPlist: InfoPlist = .default,
    scripts: [TargetScript],
    product: Product,
    schemes: [Scheme] = [],
    resourceSynthesizers: [ResourceSynthesizer] = []
  )  -> Project {
    // enum 타입 이름을 루트 타겟/프로젝트 이름으로 사용
    let targetName = String(describing: T.self)
    // enum의 모든 케이스를 하위 모듈로 간주
    let childTargets = T.allCases
    // 각 케이스를 TargetDependency로 변환하여 루트 타겟의 의존성으로 설정
    let dependencies: [TargetDependency] = childTargets.map { .dependency(module: $0) }

    // 루트 타겟 정의 (하위 모듈들에 의존하는 상위 Aggregation 타겟)
    let target: Target = .target(
      name: targetName,
      product: product,
      infoPlist: infoPlist,
      sources: ["Sources/**/*.swift"],
      resources: nil,
      scripts: scripts,
      dependencies: dependencies
    )
    // 단일 루트 타겟을 포함하는 루트 Project 생성
    return .init(
      name: targetName,
      organizationName: AppEnv.organizationName,
      options: options,
      packages: packages,
      settings: .projectSettings(),
      targets: [target],
      schemes: schemes,
      fileHeaderTemplate: nil,
      additionalFiles: [],
      resourceSynthesizers: resourceSynthesizers
    )
  }
}

extension Project {
  /// TMA 아키텍처에서 사용하는 Target의 역할 종류를 표현하는 타입
  /// Sources / Interface / Tests / Testing / Example 다섯 가지 케이스를 가짐
  public enum TargetType: Hashable {
    /// 실제 구현 코드가 들어가는 메인 타겟
    case sources
    /// 외부로 노출되는 인터페이스 전용 타겟
    case interface
    /// 유닛 테스트 타겟
    case tests
    /// 테스트용 Mock / Stub / Fixture 타겟
    case testing
    /// 샘플 앱(Example) 타겟
    case example

    /// 각 TargetType에 대응되는 타겟 이름의 접미사 규칙
    public var suffixName: String {
      switch self {
        case .sources:
          return "" // 메인 소스 타겟은 접미사 없음
        case .interface:
          return "Interface" // Interface 타겟은 "Interface" 접미사
        case .tests:
          return "Tests" // Tests 타겟은 "Tests" 접미사
        case .testing:
          return "Testing" // Testing 타겟은 "Testing" 접미사
        case .example:
          return "Example" // Example 앱은 "Example" 접미사
      }
    }
  }
}
