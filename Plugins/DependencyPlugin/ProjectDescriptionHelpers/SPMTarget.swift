//
//  SPMTarget.swift
//  DependencyPlugin
//
//  Created by 윤해수 on 11/19/25.
//

import ProjectDescription

public extension TargetDependency {
  // SPM 패키지 의존성들을 한 곳에 모아 관리하기 위한 확장입니다.
  // TargetDependency.SPMTarget 내부에 각 Swift Package Manager 의존성을 static 프로퍼티로 정의하여
  // Project.swift에서 `.SPMTarget.xxx` 형태로 간단하고 안전하게 가져다 쓸 수 있도록 구성한 파일입니다.
  enum SPMTarget {
    public static let alamofire: TargetDependency = .external(name: "Alamofire")
    public static let lottie: TargetDependency = .external(name: "Lottie")
    public static let nMapsMap: TargetDependency = .external(name: "NMapsMap")
  }
}
