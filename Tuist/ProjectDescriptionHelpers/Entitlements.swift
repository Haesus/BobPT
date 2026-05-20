//
//  Entitlements
//  ProjectDescriptionHelpers
//
//  Created by 윤해수 on 11/19/25.
//

import ProjectDescription

// MARK: - Entitlements Factory
// Tuist에서 앱/모듈에 적용할 권한(Entitlements) 설정을 모아두는 확장
extension Entitlements {
  /// 각 타겟(앱/익스텐션)에서 재사용할 권한 설정을 정의
  public enum BobPT {
    /// 앱 타겟에서 사용될 Entitlements 정의
    /// - Note: 애플 로그인, Push Notifications, Keychain Sharing 등 필요한 권한을 이곳에 추가
    public static var app: Entitlements {
      // 현재는 빈 권한 설정
      // 필요 시 ["com.apple.developer.applesignin": .boolean(true)] 같은 키들을 추가
      return .dictionary([:])
      // 애플로그인, 푸시알림 등등
    }
  }
}
