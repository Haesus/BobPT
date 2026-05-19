//
//  Settings+Extension.swift
//  ProjectDescriptionHelpers
//
//  Created by 윤해수 on 11/19/25.
//

import ProjectDescription
import UtilityPlugin

// MARK: - Settings Factory Helpers
// 프로젝트/타겟/패키지 설정을 빌드 환경(dev/release/beta)에 맞게 자동 구성하는 확장
extension ProjectDescription.Settings {
  /// 프로젝트 전역 설정 생성
  /// xcconfig가 전달되면 해당 파일을 Debug/Release 모두에 연결함
  public static func projectSettings(xcconfig: Path? = nil) -> Self {
    // 개발(DEV) 환경 설정 값
    let devConfig = BuildConfiguration.dev
    // 배포(RELEASE) 환경 설정 값
    let releaseConfig = BuildConfiguration.release
    // 베타테스트(BETA) 환경 설정 값
    let betaConfig = BuildConfiguration.beta

    // DEV,RELEASE,BETA 세 가지 Configuration으로 Settings 구성
    return .settings(
      base: RecommendedOverrides.buildSettings,
      configurations: [
        .debug(
          name: devConfig.configurationName,
          settings: RecommendedOverrides.buildSettings
            // Swift 컴파일러 플래그 설정 (예: -DDEV)
            .otherSwiftFlags(["$(inherited)", "-D\(devConfig.name)"])
            // 컴파일 조건 활성화 (DEV + DEBUG)
            .swiftActiveCompilationConditions([devConfig.name, "DEBUG"])
          ,
          xcconfig: xcconfig
        ),
        .release(
          name: releaseConfig.configurationName,
          settings: RecommendedOverrides.buildSettings
            // Release 환경에서는 DEV 대신 RELEASE 플래그 적용
            .otherSwiftFlags(["$(inherited)", "-D\(releaseConfig.name)"])
            // Release용 활성 조건 (RELEASE)
            .swiftActiveCompilationConditions([releaseConfig.name])
          ,
          xcconfig: xcconfig
        ),
        .release(
          name: betaConfig.configurationName,
          settings: RecommendedOverrides.buildSettings
            // Beta 환경에서는 BETA 플래그 적용
            .otherSwiftFlags(["$(inherited)", "-D\(betaConfig.name)"])
            // Beta용 활성 조건 (BETA)
            .swiftActiveCompilationConditions([betaConfig.name])
          ,
          xcconfig: xcconfig
        )
      ],
      defaultSettings: .recommended
    )
  }

  /// 타겟별 설정 생성
  /// 대상 Product(iOS App, Framework 등)에 따라 각 타겟 전용 xcconfig 자동 연결
  public static func targetSettings(product: Product) -> Self {
    // 개발(DEV) 환경 설정 값
    let devConfig = BuildConfiguration.dev
    // 배포(RELEASE) 환경 설정 값
    let releaseConfig = BuildConfiguration.release
    // 베타테스트(BETA) 환경 설정 값
    let betaConfig = BuildConfiguration.beta

    // DEV/RELEASE/BETA에 대한 타겟 구성 생성
    return .settings(
      base: RecommendedOverrides.buildSettings,
      configurations: [
        .debug(
          name: devConfig.configurationName,
          settings: RecommendedOverrides.buildSettings,
          // 제품(Product) 타입에 맞는 타겟 전용 xcconfig 파일 적용
          xcconfig: .targetXCConfig(type: product)
        ),
        .release(
          name: releaseConfig.configurationName,
          settings: RecommendedOverrides.buildSettings,
          // 제품(Product) 타입에 맞는 타겟 전용 xcconfig 파일 적용
          xcconfig: .targetXCConfig(type: product)
        ),
        .release(
          name: betaConfig.configurationName,
          settings: RecommendedOverrides.buildSettings,
          // 제품(Product) 타입에 맞는 타겟 전용 xcconfig 파일 적용
          xcconfig: .targetXCConfig(type: product)
        )
      ],
      defaultSettings: .recommended
    )
  }

  /// Swift Package용 설정
  /// 시뮬레이터 빌드 호환성을 위해 x86_64 아키텍처 제외
  public static var packageSettings: Self {
    // 개발(DEV) 환경 설정 값
    let devConfig = BuildConfiguration.dev
    // 배포(RELEASE) 환경 설정 값
    let releaseConfig = BuildConfiguration.release
    // 베타테스트(BETA) 환경 설정 값
    let betaConfig = BuildConfiguration.beta

    // 패키지 레벨 DEV/PROD Configuration 구성
    return .settings(
      base: [
        // iOS 시뮬레이터에서 x86_64 아키텍처 제외 (M1/M2 환경 대응)
        "EXCLUDED_ARCHS[sdk=iphonesimulator*]": "x86_64"
      ],
      configurations: [
        // 패키지 Debug 설정 생성
        .debug(name: devConfig.configurationName),
        // 패키지 Release 설정 생성
        .release(name: releaseConfig.configurationName),
        // 패키지 Beta 설정 생성
        .release(name: betaConfig.configurationName)
      ],
      defaultSettings: .recommended
    )
  }
}
