//
//  PathExtension.swift
//  UtilityPlugin
//
//  Created by 윤해수 on 11/19/25.
//

import Foundation
import ProjectDescription

extension ProjectDescription.Path {
  public static let appXCConfig: Path = .relativeToRoot("Xcconfig/Project/Main.xcconfig")

  public static func appXCConfig(for config: BuildConfiguration) -> Path {
    return .relativeToRoot("Xcconfig/Project/\(config.name.lowercased()).xcconfig")
  }

  public static func targetXCConfig(type: Product) -> Self {
    return .relativeToRoot("Xcconfig/Target/\(type.rawValue).xcconfig")
  }
}
