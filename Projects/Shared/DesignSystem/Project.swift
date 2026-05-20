import ProjectDescription
import ProjectDescriptionHelpers

let targetName = "DesignSystem"

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
  resources: [
    "Resources/**"
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
