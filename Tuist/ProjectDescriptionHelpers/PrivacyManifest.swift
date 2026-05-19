//
//  PrivacyManifest
//  ProjectDescriptionHelpers
//
//  Created by 윤해수 on 11/19/25.
//

import ProjectDescription

extension PrivacyManifest {
  // MARK: - Privacy Manifest
  // 앱이 수집·사용하는 데이터 유형과 접근 API를 선언적으로 정의하여
  // App Store Privacy 요구사항을 충족하기 위한 매니페스트
  public static var bobPT: Self {
    return .privacyManifest(
      tracking: false,
      trackingDomains: [],
      // TODO: 실제 앱에서 수집하는 데이터가 생기면 App Store Privacy 항목에 맞춰 추가하세요.
      collectedDataTypes: [],
      // 앱에서 접근하는 민감 API 유형
      // Apple의 민감 API(AIT) 접근 이유를 명시해야 함
      accessedApiTypes: [
        // UserDefaults 접근 — 기본 설정 저장(사유 코드 CA92.1)
        [
          "NSPrivacyAccessedAPITypeReasons": ["CA92.1"],
          "NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategoryUserDefaults"
        ]
      ]
    )
  }
}
