import NeedleFoundation
import RIBs

protocol YearsDependency: NeedleFoundation.Dependency {
  var networkService: NetworkService { get }
}

final class YearsComponent: NeedleFoundation.Component<YearsDependency> {
  var yearBuilder: YearBuildable { fatalError() }
}

extension YearsComponent {
  var yearsService: YearsServiceProtocol {
    shared { YearsService(networkService: dependency.networkService) }
  }
}

protocol YearsBuildable: Buildable {
  func finalStageBuild(withDynamicDependency dynamicDependency: YearsListener) -> YearsRouting
}

final class YearsBuilder: MultiStageComponentizedBuilder<YearsComponent, YearsRouting, YearsListener>, YearsBuildable {
  override func finalStageBuild(with component: YearsComponent, _ listener: YearsListener) -> YearsRouting {
    let viewController = YearsRootViewController()
    let interactor = YearsInteractor(component: component, presenter: viewController)
    let router = YearsRouter(component: component, interactor: interactor, viewController: viewController)
    interactor.router = router
    interactor.listener = listener
    viewController.listener = interactor
    return router
  }
}
