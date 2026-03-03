import UIKit
import WebKit

class MainViewController: UIViewController {
    @IBOutlet weak var webContainerView: UIView!
    
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var dividerHadleView: UIView!
    
    @IBOutlet weak var functionSegmentView: UISegmentedControl!
    
    @IBOutlet weak var functionTableView: UITableView!
    @IBOutlet weak var logTableView: UITableView!
    @IBOutlet weak var storageTableView: UITableView!
    
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    
    private var webView: WKWebView!
    var router: BridgeRouter!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setWebView()
    }
    
    deinit {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "bridge")
    }
    
    func setUI () {
        let conerRadius: CGFloat = 18
        
        dividerHadleView.layer.cornerRadius = 3
        
        functionTableView.layer.cornerRadius = conerRadius
        logTableView.layer.cornerRadius = conerRadius
        storageTableView.layer.cornerRadius = conerRadius
    }
    
    func setWebView() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
        
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webContainerView.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: webContainerView.topAnchor),
            webView.bottomAnchor.constraint(equalTo: webContainerView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: webContainerView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: webContainerView.trailingAnchor),
        ])
        
        let context = BridgeContext(viewController: self, webView: webView)
        let router = BridgeRouter(context: context)
        
        router.register(NativeUIToastHandler())
        router.register(NativeHapticComboHandler())
        router.register(NativePushHandler())
        router.register(NativeTokenHandler())
        
        self.router = router
        
        let uc = webView.configuration.userContentController
        uc.removeScriptMessageHandler(forName: "bridge")
        uc.add(self, name: "bridge")
        
        guard let url = URL(string: "http://192.168.0.10:5173") else { return }
        webView.load(URLRequest(url: url))
    }
}

