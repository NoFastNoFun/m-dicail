import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var screenshotEventSink: FlutterEventSink?
  private var screenshotObserver: NSObjectProtocol?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    setupScreenshotDetection(binaryMessenger: engineBridge.applicationRegistrar.messenger())
  }

  private func setupScreenshotDetection(binaryMessenger: FlutterBinaryMessenger) {
    let channel = FlutterEventChannel(
      name: "dev.nf2.medicail/screenshot_detection",
      binaryMessenger: binaryMessenger
    )
    channel.setStreamHandler(ScreenshotStreamHandler(
      onListen: { [weak self] sink in
        self?.screenshotEventSink = sink
        self?.startObservingScreenshots()
      },
      onCancel: { [weak self] in
        self?.stopObservingScreenshots()
        self?.screenshotEventSink = nil
      }
    ))
  }

  private func startObservingScreenshots() {
    guard screenshotObserver == nil else { return }
    screenshotObserver = NotificationCenter.default.addObserver(
      forName: UIApplication.userDidTakeScreenshotNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.screenshotEventSink?(nil)
    }
  }

  private func stopObservingScreenshots() {
    if let observer = screenshotObserver {
      NotificationCenter.default.removeObserver(observer)
      screenshotObserver = nil
    }
  }
}

private final class ScreenshotStreamHandler: NSObject, FlutterStreamHandler {
  private let onListen: (FlutterEventSink) -> Void
  private let onCancel: () -> Void

  init(onListen: @escaping (FlutterEventSink) -> Void, onCancel: @escaping () -> Void) {
    self.onListen = onListen
    self.onCancel = onCancel
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    onListen(events)
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    onCancel()
    return nil
  }
}
