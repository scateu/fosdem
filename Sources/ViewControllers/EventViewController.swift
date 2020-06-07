import UIKit

protocol EventViewControllerDelegate: AnyObject {
  func eventViewControllerDidTapVideo(_ eventViewController: EventViewController)
  func eventViewController(_ eventViewController: EventViewController, didSelect attachment: Attachment)
}

protocol EventViewControllerDataSource: AnyObject {
  func eventViewController(_ eventViewController: EventViewController, playbackPositionFor event: Event) -> PlaybackPosition
}

final class EventViewController: UITableViewController {
  weak var delegate: EventViewControllerDelegate?
  weak var dataSource: EventViewControllerDataSource?

  var event: Event?

  private var eventCell: EventTableViewCell?

  func reloadPlaybackPosition() {
    eventCell?.reloadPlaybackPosition()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    if let event = event {
      tableView.separatorStyle = .none

      var isAdaptive = true
      if #available(iOS 13.0, *), tableView.style == .insetGrouped {
        isAdaptive = false
      }

      if isAdaptive {
        tableView.contentInset.top = 8
        tableView.contentInset.bottom = 20
      }

      eventCell = EventTableViewCell(isAdaptive: isAdaptive)
      eventCell?.delegate = self
      eventCell?.dataSource = self
      eventCell?.configure(with: event)
    }
  }

  override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    event == nil ? 0 : 1
  }

  override func tableView(_: UITableView, cellForRowAt _: IndexPath) -> UITableViewCell {
    eventCell ?? UITableViewCell()
  }
}

extension EventViewController: EventViewDelegate, EventViewDataSource {
  func eventViewDidTapVideo(_: EventView) {
    delegate?.eventViewControllerDidTapVideo(self)
  }

  func eventView(_: EventView, didSelect attachment: Attachment) {
    delegate?.eventViewController(self, didSelect: attachment)
  }

  func eventView(_: EventView, playbackPositionFor event: Event) -> PlaybackPosition {
    dataSource?.eventViewController(self, playbackPositionFor: event) ?? .beginning
  }
}
