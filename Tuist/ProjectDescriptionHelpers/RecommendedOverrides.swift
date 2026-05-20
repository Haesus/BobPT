//
//  RecommendedOverrides.swift
//  ProjectDescriptionHelpers
//
//  Created by 윤해수 on 02/23/26.
//

import ProjectDescription

enum RecommendedOverrides {
  static let buildSettings: SettingsDictionary = [
    "ENABLE_MODULE_VERIFIER": "YES",
    "ENABLE_MODULE_VERIFIER_SUPPORTED_LANGUAGES": "YES",
    "MODULE_VERIFIER_SUPPORTED_LANGUAGES": "objective-c objective-c++",
    "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "",
    "ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOLS": "YES",
    "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
    "SWIFT_EMIT_LOC_STRINGS": "YES",
    "STRING_CATALOG_GENERATE_SYMBOLS": "YES"
  ]
}
