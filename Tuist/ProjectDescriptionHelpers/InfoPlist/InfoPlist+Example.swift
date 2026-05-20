//
//  InfoPlist+Example.swift
//  ProjectDescriptionHelpers
//
//  Created by 윤해수 on 11/19/25.
//

import ProjectDescription

extension InfoPlist {
  public enum Example {
    public static func app(name: String) -> InfoPlist {
      return .dictionary(
        [
          // MARK: - Environment Value
          // 환경별로 달라지는 API 엔드포인트
          // MARK: - Core Foundation
          // 기본 지역 설정
          "CFBundleDevelopmentRegion": "ko_KR",
          // 홈 화면에 표시될 앱 이름
          "CFBundleDisplayName": "\(name)",
          // 실행 가능한 바이너리 이름
          "CFBundleExecutable": "$(EXECUTABLE_NAME)",
          // 번들 식별자
          "CFBundleIdentifier": "$(PRODUCT_BUNDLE_IDENTIFIER)",
          // Info.plist 포맷 버전
          "CFBundleInfoDictionaryVersion": "6.0",
          // 시스템 내부에서 사용하는 앱 이름
          "CFBundleName": "\(name)",
          // 패키지 타입(APPL = 앱)
          "CFBundlePackageType": "APPL",
          // 사용자에게 표시되는 버전
          "CFBundleShortVersionString": "1.0.0",
          // 빌드 번호
          "CFBundleVersion": "1",

          // MARK: - Launch Services
          // 앱이 iOS가 반드시 필요함
          "LSRequiresIPhoneOS": true,

          // MARK: - Cocoa
          // 네트워크 통신 보안 설정
          "NSAppTransportSecurity": [
            "NSAllowsArbitraryLoads": true
          ],
          // Bonjour 서비스 탐색
          "NSBonjourServices": [
            "_dartobservatory._tcp"
          ],
          // 카메라 접근 권한 안내
          "UILaunchStoryboardName": "LaunchScreen",
          // 전체 UI 스타일 (Light / Dark)
          "UIUserInterfaceStyle": "Light"
        ]
      )
    }
  }
}
