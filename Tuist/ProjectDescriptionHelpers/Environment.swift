//
//  Environment.swift
//  ProjectDescriptionHelpers
//
//  Created by 윤해수 on 11/19/25.
//

import ProjectDescription
import UtilityPlugin

/// 프로젝트 루트 디렉터리 경로를 환경 변수에서 가져옴 (없으면 SRCROOT 사용)
/// "TUIST_ROOT_DIR" 환경 변수값
public let rootDirectory = Environment.rootDir.getString(default: "SRCROOT")

/// 현재 빌드 설정(TUIST_BUILD_CONFIG)을 환경 변수에서 읽음 (기본값 DEV)
/// "TUIST_BUILD_CONFIG" 환경 변수값
public let buildConfiguration = Environment.buildConfig.getString(default: "DEV")

/// 문자열로 읽은 빌드 설정을 BuildConfiguration 타입으로 변환하여 현재 환경으로 사용
/// 현재 빌드 환경
public let currentConfig = BuildConfiguration(rawValue: buildConfiguration.lowercased()) ?? .dev
