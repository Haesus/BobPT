import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let appTargetName = "BobPT"

let appTarget: Target = .target(
  name: appTargetName,
  destinations: AppEnv.platform,
  product: .app,
  bundleId: AppEnv.bundleId,
  deploymentTargets: AppEnv.deploymentTarget,
  infoPlist: InfoPlist.BobPT.app,
  sources: [
    "Sources/**"
  ],
  resources: .resources(
    [
      "Resources/**"
    ],
    privacyManifest: .bobPT
  ),
  entitlements: Entitlements.BobPT.app,
  dependencies: [
    .project(target: "BobPTCore", path: "../../Core/BobPTCore"),
    .project(target: "DesignSystem", path: "../../Shared/DesignSystem"),
    .project(target: "FeedbackUI", path: "../../Shared/FeedbackUI"),
    .project(target: "RecommendationFeature", path: "../../Feature/RecommendationFeature"),
    .project(target: "HistoryFeature", path: "../../Feature/HistoryFeature"),
    .project(target: "SettingsFeature", path: "../../Feature/SettingsFeature")
  ],
  settings: .targetSettings(product: .app)
)

let appScheme = Scheme.makeAppScheme(
  target: TargetReference(stringLiteral: appTargetName),
  config: currentConfig
)

let project = Project(
  name: "BobPT",
  organizationName: AppEnv.organizationName,
  options: .options(
    automaticSchemesOptions: .disabled,
    disableSynthesizedResourceAccessors: true
  ),
  settings: .projectSettings(xcconfig: .appXCConfig(for: currentConfig)),
  targets: [
    appTarget
  ],
  schemes: [
    appScheme
  ]
)
