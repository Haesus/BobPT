//
//  Scheme+Extension.swift
//  ProjectDescriptionHelpers
//
//  Created by 윤해수 on 11/19/25.
//

import ProjectDescription
import UtilityPlugin

// MARK: - Scheme Factory Helpers
// 앱 및 익스텐션 실행/빌드 스킴을 자동 생성하기 위한 확장
extension Scheme {
  /// 앱 타겟을 위한 실행 스킴 생성
  /// 환경별(dev/prod)로 다른 RunAction 설정을 적용함
  public static func makeAppScheme(
    target: TargetReference,
    config: BuildConfiguration,
    testTargets: [TestableTarget] = []
  ) -> Scheme {
    // 실행(run) 설정을 담을 변수
    var runAction: RunAction

    // 환경 설정(dev / prod)에 따라 RunAction 구성 분기
    switch config {
    case .dev:
      // DEV 환경: 디버깅 로그 활성화, 런타임 환경변수 적용
      runAction = .runAction(
        configuration: config.configurationName,
        executable: target,
        arguments: .arguments(
          environmentVariables: [
            "OS_ACTIVITY_MODE": .environmentVariable(value: "enable", isEnabled: true),
            "IDEPreferLogStreaming": .environmentVariable(value: "YES", isEnabled: true)
          ]
        )
      )
    case .release:
      // RELEASE 환경: 별도 런타임 설정 없이 기본 실행
      runAction = .runAction(configuration: config.configurationName, executable: target)
    case .beta:
      // BETA 환경: 베타 테스트 사용자용으로 RELEASE와 동일하게 실행
      runAction = .runAction(configuration: config.configurationName, executable: target)
    }

    // 구성된 실행/빌드/아카이브/프로파일/분석 액션을 포함한 스킴 생성
    return .scheme(
      name: "\(target.targetName)_\(config.name)",
      shared: true,
      buildAction: .buildAction(targets: [target]),
      testAction: testTargets.isEmpty
        ? nil
        : .targets(
          testTargets,
          configuration: config.configurationName
        ),
      runAction: runAction,
      archiveAction: .archiveAction(configuration: config.configurationName),
      profileAction: .profileAction(configuration: config.configurationName, executable: target),
      analyzeAction: .analyzeAction(configuration: config.configurationName)
    )
  }

  /// 앱 확장(Extension) 타겟을 위한 스킴 생성
  /// 확장과 본체 앱을 함께 빌드해야 하므로 buildAction에 두 타겟 모두 포함
  public static func makeExtensionScheme(extensionTarget: TargetReference, appTarget: TargetReference, config: BuildConfiguration) -> Scheme {
    // 확장 전용 스킴 구성 (빌드/실행/아카이브/프로파일/분석 설정 포함)
    return .scheme(
      name: extensionTarget.targetName,
      shared: true,
      buildAction: .buildAction(targets: [extensionTarget, appTarget]),
      runAction: .runAction(configuration: config.configurationName),
      archiveAction: .archiveAction(configuration: config.configurationName),
      profileAction: .profileAction(configuration: config.configurationName),
      analyzeAction: .analyzeAction(configuration: config.configurationName)
    )
  }
}
