import AVKit
import RIBs
import SafariServices
import UIKit

protocol EventPresentableListener: AnyObject {
  func toggleFavorite()
  func beginFullScreenPlayerPresentation()
  func endFullScreenPlayerPresentation()
}

final class EventContainerViewController: EventViewController, ViewControllable {
  weak var listener: EventPresentableListener?

  private weak var playerViewController: AVPlayerViewController?
  private weak var eventViewController: EventViewController?

  private lazy var favoriteButton: UIBarButtonItem = {
    let favoriteAction = #selector(didToggleFavorite)
    let favoriteButton = UIBarButtonItem(title: nil, style: .plain, target: self, action: favoriteAction)
    return favoriteButton
  }()
}

extension EventContainerViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.largeTitleDisplayMode = .never
    eventListener = self
  }
}

extension EventContainerViewController: EventViewControllerListener {
  func eventViewController(_ eventViewController: EventViewController, didSelect attachment: Attachment) {
    let attachmentViewController = SFSafariViewController(url: attachment.url)
    eventViewController.present(attachmentViewController, animated: true)
  }

  func eventViewControllerDidTapLivestream(_: EventViewController) {
    if let link = event.links.first(where: \.isLivestream), let url = link.livestreamURL {
      showPlayerViewController(with: url)
    }
  }

  func eventViewControllerDidTapVideo(_: EventViewController) {
    if let video = event.video, let url = video.url {
      showPlayerViewController(with: url)
    }
  }

  private func showPlayerViewController(with url: URL) {
    let playerViewController = AVPlayerViewController()
    playerViewController.exitsFullScreenWhenPlaybackEnds = true
    playerViewController.player = AVPlayer(url: url)
    playerViewController.player?.play()
    playerViewController.delegate = self
    self.playerViewController = playerViewController
    present(playerViewController, animated: true)
  }
}

extension EventContainerViewController: AVPlayerViewControllerDelegate {
  func playerViewController(_: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator _: UIViewControllerTransitionCoordinator) {
    listener?.beginFullScreenPlayerPresentation()
  }

  func playerViewController(_: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator _: UIViewControllerTransitionCoordinator) {
    listener?.endFullScreenPlayerPresentation()
  }
}

extension EventContainerViewController: EventPresentable {
  var showsFavoriteButton: Bool {
    get { navigationItem.rightBarButtonItem == favoriteButton }
    set { navigationItem.rightBarButtonItem = newValue ? favoriteButton : nil }
  }

  var showsFavorite: Bool {
    get { favoriteButton.accessibilityIdentifier == "unfavorite" }
    set {
      favoriteButton.title = newValue ? L10n.Event.remove : L10n.Event.add
      favoriteButton.accessibilityIdentifier = newValue ? "unfavorite" : "favorite"
    }
  }
}

private extension EventContainerViewController {
  @objc func didToggleFavorite() {
    listener?.toggleFavorite()
  }
}
