import RIBs

protocol MoreViewControllable: ViewControllable {
  func showVideos(_ videosViewControllable: ViewControllable)
  func showYears(_ yearsViewControllable: ViewControllable)
}

protocol MoreInteractable: Interactable, VideosListener, YearsListener {}

final class MoreRouter: ViewableRouter<MoreInteractable, MoreViewControllable> {
  private var videosRouter: Routing?
  private var yearsRouter: Routing?

  private let videosBuilder: VideosBuildable
  private let yearsBuilder: YearsBuildable

  init(interactor: MoreInteractable, viewController: MoreViewControllable, videosBuilder: VideosBuildable, yearsBuilder: YearsBuildable) {
    self.videosBuilder = videosBuilder
    self.yearsBuilder = yearsBuilder
    super.init(interactor: interactor, viewController: viewController)
  }
}

extension MoreRouter: MoreRouting {
  func routeToVideos() {
    let videosRouter = videosBuilder.build(withListener: interactor)
    self.videosRouter = videosRouter
    attachChild(videosRouter)
    viewController.showVideos(videosRouter.viewControllable)
  }

  func routeBackFromVideos() {
    if let videosRouter = videosRouter {
      detachChild(videosRouter)
      self.videosRouter = nil
    }
  }

  func routeToYears() {
    let yearsRouter = yearsBuilder.build(withListener: interactor)
    self.yearsRouter = yearsRouter
    attachChild(yearsRouter)
    viewController.showYears(yearsRouter.viewControllable)
  }

  func routeBackFromYears() {
    if let yearsRouter = yearsRouter {
      detachChild(yearsRouter)
      self.yearsRouter = nil
    }
  }
}
