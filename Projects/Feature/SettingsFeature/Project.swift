import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let targetName = "SettingsFeature"

let target: Target = .target(
  name: targetName,
  destinations: AppEnv.platform,
  product: .staticFramework,
  bundleId: AppEnv.moduleBundleId(name: targetName),
  deploymentTargets: AppEnv.deploymentTarget,
  infoPlist: .default,
  sources: [
    "Sources/**"
  ],
  dependencies: [
    .project(target: "BobPTCore", path: "../../Core/BobPTCore"),
    .project(target: "BobPTDomain", path: "../../Domain/BobPTDomain"),
    .project(target: "DesignSystem", path: "../../Shared/DesignSystem"),
    .project(target: "FeedbackUI", path: "../../Shared/FeedbackUI")
  ],
  settings: .targetSettings(product: .staticFramework)
)

let project = Project(
  name: targetName,
  organizationName: AppEnv.organizationName,
  options: .options(
    automaticSchemesOptions: .disabled,
    disableSynthesizedResourceAccessors: true
  ),
  settings: .projectSettings(),
  targets: [
    target
  ]
)
