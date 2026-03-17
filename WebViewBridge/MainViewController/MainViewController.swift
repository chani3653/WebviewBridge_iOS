import UIKit
import WebKit

class MainViewController: UIViewController {
    @IBOutlet weak var webContainerView: UIView!
    
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var dividerHadleView: UIView!
    
    @IBOutlet weak var functionSegmentView: UISegmentedControl!
    
    @IBOutlet weak var tableViewContainer: UIView!
    @IBOutlet weak var functionTableView: UITableView!
    @IBOutlet weak var logTableView: UITableView!
    @IBOutlet weak var storageTableView: UITableView!
    
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    
    var webView: WKWebView!
    var router: BridgeRouter!
    var logItems: [LogItem] = []
    var storageItems: [(key: String, value: String)] = []
    let originalURL = "http://192.168.0.10:5173"
    
    private var panGesture: UIPanGestureRecognizer!
    private var initialBottomConstraint: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setupTableView()
        setupDividerGesture()
        setWebView()
    }
    
    deinit {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "bridge")
    }
    
    // MARK: - UI Setup

    func setUI () {
        let conerRadius: CGFloat = 18
        
        // TableView corner radius (동적으로 조절될 수 있어서 코드로 유지)
        functionTableView.layer.cornerRadius = conerRadius
        logTableView.layer.cornerRadius = conerRadius
        storageTableView.layer.cornerRadius = conerRadius
        
        functionTableView.isHidden = false
        logTableView.isHidden = true
        storageTableView.isHidden = true
    }
    
    // MARK: - Setup TableView
    
    func setupTableView() {
        // FunctionTableView 설정
        functionTableView.delegate = self
        functionTableView.dataSource = self
        
        let nib = UINib(nibName: "FunctionTableViewCell", bundle: nil)
        functionTableView.register(nib, forCellReuseIdentifier: FunctionTableViewCell.identifier)
        
        functionTableView.separatorStyle = .singleLine
        functionTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        // LogTableView 설정
        logTableView.delegate = self
        logTableView.dataSource = self
        
        let logNib = UINib(nibName: "LogTableViewCell", bundle: nil)
        logTableView.register(logNib, forCellReuseIdentifier: LogTableViewCell.identifier)
        
        // StorageTableView 설정
        storageTableView.delegate = self
        storageTableView.dataSource = self
        
        let dataNib = UINib(nibName: "DataTableViewCell", bundle: nil)
        storageTableView.register(dataNib, forCellReuseIdentifier: DataTableViewCell.identifier)
    }
    
    // MARK: - Setup Divider Gesture
    
    func setupDividerGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDividerPan(_:)))
        dividerView.addGestureRecognizer(panGesture)
        dividerView.isUserInteractionEnabled = true
    }
    
    @objc func handleDividerPan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            initialBottomConstraint = bottomViewConstraint.constant
            
        case .changed:
            let dividerY = gesture.location(in: view).y
            let safeAreaTop = view.safeAreaInsets.top
            let safeAreaBottom = view.safeAreaInsets.bottom
            let availableHeight = view.bounds.height - safeAreaTop - safeAreaBottom
            let bottomSpace = view.bounds.height - dividerY - safeAreaBottom
            let minAreaHeight = availableHeight / 3
            let minBottom = minAreaHeight
            let maxBottom = availableHeight - minAreaHeight
            
            bottomViewConstraint.constant = max(minBottom, min(maxBottom, bottomSpace))
            
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            
        default:
            break
        }
    }
    
    // MARK: - Setup WebView
    
    func setWebView() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
        
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webContainerView.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: webContainerView.topAnchor),
            webView.bottomAnchor.constraint(equalTo: webContainerView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: webContainerView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: webContainerView.trailingAnchor),
        ])
        
        let context = BridgeContext(viewController: self, webView: webView) { [weak self] direction, status, action, detail in
            self?.addLog(direction: direction, status: status, action: action, detail: detail)
        }
        let router = BridgeRouter(context: context)
        
        router.register(NativeUIToastHandler())
        router.register(NativeHapticComboHandler())
        router.register(NativePushHandler())
        router.register(NativeTokenHandler())
        router.register(NativeOpenExternalHandler())
        
        self.router = router
        
        let uc = webView.configuration.userContentController
        uc.removeScriptMessageHandler(forName: "bridge")
        uc.add(self, name: "bridge")
        
        guard let url = URL(string: "http://192.168.0.10:5173") else { return }
        webView.load(URLRequest(url: url))
    }
    
    // MARK: - Storage
    
    func loadUserDefaults() {
        let defaults = UserDefaults.standard
        storageItems = defaults.dictionaryRepresentation()
            .sorted { $0.key < $1.key }
            .map { (key: $0.key, value: "\($0.value)") }
        storageTableView.reloadData()
    }
    
    // MARK: - Log
    
    func addLog(direction: LogDirection, status: LogStatus, action: String, detail: String) {
        let log = LogItem(direction: direction, status: status, action: action, detail: detail)
        logItems.insert(log, at: 0)
        logTableView.reloadData()
    }
    
    @IBAction func segmentChangeAction(_ sender: UISegmentedControl) {
        // 모든 테이블뷰 숨기기
        functionTableView.isHidden = true
        logTableView.isHidden = true
        storageTableView.isHidden = true
        
        // 선택된 세그먼트에 따라 테이블뷰 표시
        switch sender.selectedSegmentIndex {
        case 0: // 기능
            functionTableView.isHidden = false
        case 1: // 콘솔
            logTableView.isHidden = false
        case 2: // 데이터
            storageTableView.isHidden = false
            loadUserDefaults()
        default:
            functionTableView.isHidden = false // 기본값
        }
    }
}



