import Foundation
import RIBs

protocol YearsPresentable: Presentable {
  var years: [Year] { get set }
  func reloadDownloadState(at index: Int)

  func showYearUnavailableError()
  func showNoInternetError(withRetryHandler retryHandler: @escaping () -> Void)
  func showError()
}

protocol YearsRouting: ViewableRouting {
  func routeToYear(_ year: Year)
}

protocol YearsListener: AnyObject {
  func yearsDidError(_ error: Error)
}

final class YearsInteractor: PresentableInteractor<YearsPresentable> {
  weak var listener: YearsListener?
  weak var router: YearsRouting?

  private var pendingTask: NetworkServiceTask?
  private var pendingYear: Year?

  private let dependency: YearsDependency

  init(presenter: YearsPresentable, dependency: YearsDependency) {
    self.dependency = dependency
    super.init(presenter: presenter)
  }

  override func didBecomeActive() {
    super.didBecomeActive()
    presenter.years = Array(type(of: dependency.yearsService).all).reversed()
  }
}

extension YearsInteractor: YearsPresentableListener {
  func select(_ year: Year) {
    guard let index = presenter.years.firstIndex(of: year) else { return }

    let onFailure: (Error) -> Void = { [weak self] error in
      switch error {
      case let error as URLError where error.code == .notConnectedToInternet:
        self?.presenter.showNoInternetError(withRetryHandler: { [weak self] in
          self?.select(year)
        })
      case let error as YearsService.Error where error == .yearNotAvailable:
        self?.presenter.showYearUnavailableError()
      default:
        self?.presenter.showError()
      }
    }
    let onSuccess: () -> Void = { [weak self] in
      self?.router?.routeToYear(year)
    }

    switch downloadState(for: year) {
    case .inProgress:
      break
    case .completed:
      onSuccess()
    case .available:
      let task = dependency.yearsService.downloadYear(year) { [weak self] error in
        DispatchQueue.main.async {
          if let error = error {
            onFailure(error)
          } else {
            onSuccess()
          }

          self?.pendingYear = nil
          self?.pendingTask = nil
          self?.presenter.reloadDownloadState(at: index)
        }
      }

      pendingYear = year
      pendingTask = task
      presenter.reloadDownloadState(at: index)
    }
  }

  func downloadState(for year: Year) -> YearDownloadState {
    if pendingYear == year {
      return .inProgress
    } else if dependency.yearsService.isYearDownloaded(year) {
      return .completed
    } else {
      return .available
    }
  }
}

extension YearsInteractor: YearsInteractable {
  func yearDidError(_ error: Error) {
    _ = error
  }
}
