import ProjectDescription

extension InfoPlist {
  public enum BobPT {
    public static var app: InfoPlist {
      .dictionary(
        [
          "CFBundleDevelopmentRegion": "ko_KR",
          "CFBundleDisplayName": "$(APP_NAME)",
          "CFBundleExecutable": "$(EXECUTABLE_NAME)",
          "CFBundleIdentifier": "$(PRODUCT_BUNDLE_IDENTIFIER)",
          "CFBundleInfoDictionaryVersion": "6.0",
          "CFBundleName": "$(PRODUCT_NAME)",
          "CFBundlePackageType": "APPL",
          "CFBundleShortVersionString": "$(MARKETING_VERSION)",
          "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
          "ID_KEY": "$(ID_KEY)",
          "ITSAppUsesNonExemptEncryption": false,
          "LSApplicationQueriesSchemes": [
            "nmap"
          ],
          "LSRequiresIPhoneOS": true,
          "NMFNcpKeyId": "$(NAVER_MAP_CLIENT_ID)",
          "NSLocationAlwaysAndWhenInUseUsageDescription": "사용자의 위치 정보를 가져와 메뉴를 추천해드릴게요.",
          "NSLocationWhenInUseUsageDescription": "사용자의 위치 정보를 통해 메뉴를 추천합니다.",
          "SECRET_KEY": "$(SECRET_KEY)",
          "UIApplicationSupportsIndirectInputEvents": true,
          "UILaunchStoryboardName": "LaunchScreen",
          "UISupportedInterfaceOrientations": [
            "UIInterfaceOrientationPortrait"
          ],
          "UISupportedInterfaceOrientations~ipad": [
            "UIInterfaceOrientationLandscapeLeft",
            "UIInterfaceOrientationLandscapeRight",
            "UIInterfaceOrientationPortrait",
            "UIInterfaceOrientationPortraitUpsideDown"
          ]
        ]
      )
    }
  }
}
