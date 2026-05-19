//
//  Target+Extension.swift
//  ProjectDescriptionHelpers
//
//  Created by 윤해수 on 11/19/25.
//

import ProjectDescription
import UtilityPlugin

extension Target {
  // MARK: - Target Factory
  /// 공통 Target 생성 함수
  /// 모듈별 Sources/Resources/Scripts/Dependencies 등을 한 번에 설정하기 위한 헬퍼
  static func target(
    // 타겟 이름 (예: AuthFeature, CoreNetwork)
    name: String,
    // 제품 타입 (app, framework, staticLibrary 등)
    product: Product,
    // Info.plist 정의 (커스텀/자동 생성)
    infoPlist: InfoPlist,
    // 소스 코드 경로
    sources: SourceFilesList,
    // 리소스 파일 목록 (없으면 nil)
    resources: ResourceFileElements?,
    // 빌드 스크립트 (SwiftLint, SwiftGen 등)
    scripts: [TargetScript],
    // 의존하는 다른 Target 또는 외부 패키지
    dependencies: [TargetDependency],
    // 타겟 전용 빌드 설정 (필요 시만 전달)
    settings: Settings? = nil,
    // CoreData
    coreDataModels: [CoreDataModel] = []
  ) -> Target {
    return .target(
      // 타겟 표시 이름
      name: name,
      // 플랫폼 설정(iOS, macOS 등) - AppEnv에서 관리
      destinations: AppEnv.platform,
      product: product,
      productName: nil,
      // 모듈명 기반 번들ID 자동 생성
      bundleId: AppEnv.moduleBundleId(name: name),
      // 최소 지원 OS 버전 설정
      deploymentTargets: AppEnv.deploymentTarget,
      // 각 타겟 전용 Info.plist 적용
      infoPlist: infoPlist,
      // 소스 파일 경로
      sources: sources,
      // 리소스 파일 포함
      resources: resources,
      copyFiles: nil,
      headers: nil,
      entitlements: nil,
      // 빌드 전/후 실행할 스크립트(SwiftGen, SwiftLint 등)
      scripts: scripts,
      // 타겟 의존성 목록
      dependencies: dependencies,
      // product 타입에 맞는 타겟 빌드 설정 자동 적용(필요 시 override)
      settings: settings ?? .targetSettings(product: product),
      // CoreData 모델 (현재 사용 안 함)
      coreDataModels: coreDataModels,
      // 런타임 환경 변수 (필요 시 추가)
      environmentVariables: [:],
      // launchArguments 설정
      launchArguments: [],
      // 추가 포함할 파일들
      additionalFiles: [],
      // 파일별 커스텀 빌드 규칙
      buildRules: []
    )
  }
}
