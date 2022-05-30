import RIBs

typealias YearDependency = HasEventBuilder & HasSearchBuilder & HasYearsService

typealias YearArguments = Year

protocol YearBuildable: Buildable {
  func build(with arguments: YearArguments, listener: YearListener) -> YearRouting
}

final class YearBuilder: Builder<YearDependency>, YearBuildable {
  func build(with arguments: YearArguments, listener: YearListener) -> YearRouting {
    let viewController = YearContainerViewController()
    let interactor = YearInteractor(presenter: viewController, dependency: dependency, arguments: arguments)
    let router = YearRouter(interactor: interactor, viewController: viewController, eventBuilder: dependency.eventBuilder, searchBuilder: dependency.searchBuilder)
    interactor.listener = listener
    interactor.router = router
    viewController.listener = interactor
    return router
  }
}
