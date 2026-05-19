//
//  AppEnv
//  ProjectDescriptionHelpers
//
//  Created by 윤해수 on 11/19/25.
//

import Foundation
import ProjectDescription
import UtilityPlugin

/// MARK: - App Environment Configuration
/// 전체 프로젝트에서 공통으로 사용하는 환경값들을 정의한 enum
/// Tuist 프로젝트 전역 설정에서 반복되는 값을 중앙에서 관리
public enum AppEnv {
  /// TODO: 새 프로젝트를 시작할 때 조직/회사명으로 교체하세요.
  /// Project organizationName과 생성 파일 메타데이터에 사용됩니다.
  public static let organizationName: String = "BobPT"

  /// 최소 지원 iOS 버전 설정
  /// 모든 모듈(Target)에 공통 적용되는 Deployment Target
  public static let deploymentTarget: DeploymentTargets = .iOS("16.0")

  /// 지원 플랫폼(iPhone, iPad 등)을 정의
  public static let platform: Destinations = [.iPhone]

  /// TODO: 새 프로젝트의 Bundle Identifier로 교체하세요.
  /// - App Store Connect에 등록할 앱 ID와 fastlane/Appfile, fastlane/Matchfile의 값이 모두 일치해야 합니다.
  /// - DEV/BETA를 별도 앱으로 설치하려면 아래처럼 suffix를 분리합니다.
  /// - 예: com.company.product, com.company.product.beta, com.company.product.dev
  public static var bundleId: String {
    switch currentConfig {
    case .dev:
      return "com.kibwa.BobPT.dev"
    case .beta:
      return "com.kibwa.BobPT.beta"
    case .release:
      return "com.kibwa.BobPT"
    }
  }

  /// 각 모듈(Target)을 위한 번들 ID 생성 메서드
  /// 모듈 이름을 기반으로 소문자 + 알파벳/숫자/점 문자만 허용하도록 정제 후
  /// 형태로 bundle identifier 생성
  public static func moduleBundleId(name: String) -> String {
        // 모듈 이름을 소문자로 변환
    var moduleName = name.lowercased()
        // 번들 ID에 허용할 수 있는 문자 집합 정의
    let validCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789.")
        // 허용되지 않는 문자 제거 → 유효한 문자열로 정제
    moduleName = moduleName.components(separatedBy: validCharacters.inverted).joined(separator: "")
        // 최종 번들 ID 규칙에 맞게 조합하여 반환
    return "\(bundleId).\(moduleName)"
  }
}
