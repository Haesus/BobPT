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
          "CFBundleURLTypes": [
            [
              "CFBundleURLName": "Kakao Login",
              "CFBundleURLSchemes": [
                "kakao$(KAKAO_NATIVE_APP_KEY)"
              ]
            ],
            [
              "CFBundleURLName": "Naver Login",
              "CFBundleURLSchemes": [
                "$(NAVER_LOGIN_URL_SCHEME)"
              ]
            ],
            [
              "CFBundleURLName": "Google Login",
              "CFBundleURLSchemes": [
                "$(GOOGLE_REVERSED_CLIENT_ID)"
              ]
            ]
          ],
          "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
          "API_BASE_URL": "$(API_BASE_URL)",
          "GIDClientID": "$(GOOGLE_IOS_CLIENT_ID)",
          "GIDServerClientID": "$(GOOGLE_SERVER_CLIENT_ID)",
          "ID_KEY": "$(ID_KEY)",
          "ITSAppUsesNonExemptEncryption": false,
          "KAKAO_NATIVE_APP_KEY": "$(KAKAO_NATIVE_APP_KEY)",
          "LSApplicationQueriesSchemes": [
            "kakaokompassauth",
            "nmap"
          ],
          "LSRequiresIPhoneOS": true,
          "NMFNcpKeyId": "$(NAVER_MAP_CLIENT_ID)",
          "NSLocationAlwaysAndWhenInUseUsageDescription": "사용자의 위치 정보를 가져와 메뉴를 추천해드릴게요.",
          "NSLocationWhenInUseUsageDescription": "사용자의 위치 정보를 통해 메뉴를 추천합니다.",
          "SECRET_KEY": "$(SECRET_KEY)",
          "NAVER_LOGIN_CLIENT_ID": "$(NAVER_LOGIN_CLIENT_ID)",
          "NAVER_LOGIN_URL_SCHEME": "$(NAVER_LOGIN_URL_SCHEME)",
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
