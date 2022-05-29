import RIBs

protocol AgendaViewControllable: ViewControllable {
  func showAgendaEvent(_ event: Event, with viewControllable: ViewControllable)
  func present(_ viewControllable: ViewControllable)
  func dismiss(_ viewControllable: ViewControllable)
}

protocol AgendaInteractable: Interactable, SoonListener {}

final class AgendaRouter: ViewableRouter<AgendaInteractable, AgendaViewControllable>, AgendaRouting {
  private var agendaEventRouter: ViewableRouting?
  private var soonRouter: ViewableRouting?

  private let eventBuilder: EventBuildable
  private let soonBuilder: SoonBuildable

  init(interactor: AgendaInteractable, viewController: AgendaViewControllable, eventBuilder: EventBuildable, soonBuilder: SoonBuildable) {
    self.eventBuilder = eventBuilder
    self.soonBuilder = soonBuilder
    super.init(interactor: interactor, viewController: viewController)
  }

  func routeToAgendaEvent(_ event: Event) {
    if let router = agendaEventRouter {
      detachChild(router)
      agendaEventRouter = nil
    }

    let router = eventBuilder.build(with: .init(event: event))
    attachChild(router)
    viewController.showAgendaEvent(event, with: router.viewControllable)
    agendaEventRouter = router
  }

  func routeToSoon() {
    let soonRouter = soonBuilder.build(withListener: interactor)
    self.soonRouter = soonRouter
    attachChild(soonRouter)
    viewController.present(soonRouter.viewControllable)
  }

  func routeBackFromSoon() {
    if let soonRouter = soonRouter {
      self.soonRouter = nil
      detachChild(soonRouter)
      viewController.dismiss(soonRouter.viewControllable)
    }
  }
}
