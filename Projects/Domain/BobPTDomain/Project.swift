import ProjectDescription
import ProjectDescriptionHelpers

let targetName = "BobPTDomain"

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
    .project(target: "BobPTShare", path: "../../Share/BobPTShare")
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
