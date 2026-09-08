import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var screenshotEventSink: FlutterEventSink?
  private var screenshotObserver: NSObjectProtocol?
  private var screenProtectionEnabled = false
  private var privacyOverlay: UIView?
  private var capturedObserver: NSObjectProtocol?
  private var resignActiveObserver: NSObjectProtocol?
  private var becomeActiveObserver: NSObjectProtocol?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let messenger = engineBridge.applicationRegistrar.messenger()
    setupScreenshotDetection(binaryMessenger: messenger)
    setupScreenProtection(binaryMessenger: messenger)
    setupLifecycleObservers()
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

  private func setupScreenProtection(binaryMessenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "dev.nf2.medicail/screen_protection",
      binaryMessenger: binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(nil)
        return
      }
      switch call.method {
      case "setEnabled":
        let args = call.arguments as? [String: Any]
        let enabled = args?["enabled"] as? Bool ?? false
        self.setScreenProtectionEnabled(enabled)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func setupLifecycleObservers() {
    resignActiveObserver = NotificationCenter.default.addObserver(
      forName: UIApplication.willResignActiveNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      guard let self = self, self.screenProtectionEnabled else { return }
      self.showPrivacyOverlay()
    }

    becomeActiveObserver = NotificationCenter.default.addObserver(
      forName: UIApplication.didBecomeActiveNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      guard let self = self else { return }
      if UIScreen.main.isCaptured && self.screenProtectionEnabled {
        self.showPrivacyOverlay()
      } else {
        self.hidePrivacyOverlay()
      }
    }

    capturedObserver = NotificationCenter.default.addObserver(
      forName: UIScreen.capturedDidChangeNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      guard let self = self else { return }
      if UIScreen.main.isCaptured && self.screenProtectionEnabled {
        self.showPrivacyOverlay()
      } else if !UIScreen.main.isCaptured {
        self.hidePrivacyOverlay()
      }
    }
  }

  private func setScreenProtectionEnabled(_ enabled: Bool) {
    screenProtectionEnabled = enabled
    if enabled && UIScreen.main.isCaptured {
      showPrivacyOverlay()
    } else if !enabled {
      hidePrivacyOverlay()
    }
  }

  private func showPrivacyOverlay() {
    guard privacyOverlay == nil else { return }
    guard let window = keyWindow() else { return }
    let overlay = UIView(frame: window.bounds)
    overlay.backgroundColor = .black
    overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    overlay.isUserInteractionEnabled = true
    window.addSubview(overlay)
    privacyOverlay = overlay
  }

  private func hidePrivacyOverlay() {
    privacyOverlay?.removeFromSuperview()
    privacyOverlay = nil
  }

  private func keyWindow() -> UIWindow? {
    if let window = window {
      return window
    }
    return UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
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
