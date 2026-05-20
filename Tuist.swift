import ProjectDescription

let config = Config(
  project: .tuist(
    plugins: [
      .local(path: .relativeToRoot("Plugins/UtilityPlugin")),
      .local(path: .relativeToRoot("Plugins/DependencyPlugin"))
    ],
    generationOptions: .options(disableSandbox: true)
  )
)
