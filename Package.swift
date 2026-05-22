// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if TUIST
import struct ProjectDescription.PackageSettings
import ProjectDescriptionHelpers

let packageSettings: PackageSettings = .init(
  productTypes: [
    "Alamofire": .framework,
    "AppAuth": .framework,
    "AppAuthCore": .framework,
    "GoogleSignIn": .framework,
    "KakaoSDKAuth": .framework,
    "KakaoSDKCommon": .framework,
    "KakaoSDKUser": .framework,
    "Lottie": .framework,
    "NMapsMap": .framework
  ],
  baseSettings: .packageSettings
)
#endif

let package = Package(
  name: "BobPT",
  platforms: [.iOS(.v16)],
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.1"),
    .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.4.2"),
    .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "9.0.0"),
    .package(url: "https://github.com/kakao/kakao-ios-sdk.git", from: "2.27.3"),
    .package(url: "https://github.com/navermaps/SPM-NMapsMap.git", from: "3.18.0")
  ]
)
