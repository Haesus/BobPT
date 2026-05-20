//
//  BuildConfiguration.swift
//  UtilityPlugin
//
//  Created by 윤해수 on 11/19/25.
//

import ProjectDescription

public enum BuildConfiguration: String, CaseIterable, Sendable {
  case dev
  case release
  case beta
}

extension BuildConfiguration {
  public var name: String {
    return rawValue.uppercased()
  }

  public var configurationName: ConfigurationName {
    return ConfigurationName(stringLiteral: name)
  }
}
