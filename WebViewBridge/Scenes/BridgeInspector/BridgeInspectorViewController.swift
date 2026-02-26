//
//  BridgeInspectorViewController.swift
//  WebViewBridge
//
//  Created by Chan Hwi Park on 2/26/26.
//

import UIKit
import WebKit

final class BridgeInspectorViewController: UIViewController {

    // Storyboard Outlets
    @IBOutlet private weak var webContainerView: UIView!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var dividerHandleView: UIView!
    @IBOutlet private weak var panelView: UIView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var logTextView: UITextView!
    @IBOutlet weak var panelHeightConstraint: NSLayoutConstraint!

    private var webView: WKWebView!
    private let logStore = BridgeLogStore()
    lazy var logger = BridgeLogger(store: logStore)

    var outbound: BridgeOutbound!

    var actions: [BridgeActionItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)

        setupWebView()
        setupUI()
        setupActions()
        setupLogging()
        setupGestures()
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        let ucc = WKUserContentController()
        config.userContentController = ucc

        ucc.add(self, name: BridgeProtocol.handlerName)

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        webContainerView.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: webContainerView.topAnchor),
            webView.leadingAnchor.constraint(equalTo: webContainerView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: webContainerView.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: webContainerView.bottomAnchor),
        ])

        outbound = BridgeOutbound(webView: webView, logger: logger)

        let url = URL(string: "http://192.168.0.10:5173")!
        webView.load(URLRequest(url: url))
    }

    private func setupUI() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(onSegmentChanged), for: .valueChanged)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 18

        logTextView.isEditable = false
        logTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        logTextView.contentInsetAdjustmentBehavior = .never
        logTextView.layer.cornerRadius = 18
        
        dividerHandleView.layer.cornerRadius = 2.5

        renderSegment()
    }

    private func setupActions() {
        actions = [
            .init(title: "auth.getToken", action: "auth.getToken", payload: [:]),
            .init(title: "device.haptic(light)", action: "device.haptic", payload: ["type": "light"]),
            .init(title: "navigation.openExternal", action: "navigation.openExternal", payload: ["url": "https://example.com"]),
            .init(title: "storage.set(demo)", action: "storage.set", payload: ["key": "demo", "value": ["a": 1, "t": Int(Date().timeIntervalSince1970)]]),
            .init(title: "storage.get(demo)", action: "storage.get", payload: ["key": "demo"]),
            .init(title: "ui.toast", action: "ui.toast", payload: ["message": "Hello from iOS"]),
            .init(title: "Emit event: push.received", action: "__emitEvent", payload: ["type": "push.received", "payload": ["title": "hello", "body": "from native"]]),
        ]
        tableView.reloadData()
    }

    private func setupLogging() {
        logStore.onChange = { [weak self] lines in
            self?.logTextView.text = lines.joined(separator: "\n\n")
            let range = NSRange(location: max(0, (self?.logTextView.text.count ?? 1) - 1), length: 1)
            self?.logTextView.scrollRangeToVisible(range)
        }
        logger.log("✅ Bridge Inspector ready")
    }

    @objc private func onSegmentChanged() {
        renderSegment()
    }

    private func renderSegment() {
        let isActions = segmentedControl.selectedSegmentIndex == 0
        tableView.isHidden = !isActions
        logTextView.isHidden = isActions
    }
}
