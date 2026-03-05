import UIKit

class LogTableViewCell: UITableViewCell {
    
    static let identifier = "LogTableViewCell"
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var innerContainer: UIView!
    
    @IBOutlet weak var statusPillView: UIView!
    @IBOutlet weak var statusLable: UILabel!
    
    @IBOutlet weak var commnandWayPillContainerView: UIView!
    @IBOutlet weak var commandWayPillInnerView: UIView!
    @IBOutlet weak var commandWayLabel: UILabel!
    
    @IBOutlet weak var logTextView: UITextView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        let outerBorderRadius: CGFloat = 14
        let innerBorderRadius: CGFloat = 10
        
        containerView.layer.cornerRadius = outerBorderRadius
        innerContainer.layer.cornerRadius = innerBorderRadius
        
        logTextView.layer.cornerRadius = innerBorderRadius
        logTextView.isEditable = false
        logTextView.isScrollEnabled = false
        
        statusPillView.layer.cornerRadius = innerBorderRadius
        commnandWayPillContainerView.layer.cornerRadius = innerBorderRadius
        commandWayPillInnerView.layer.cornerRadius = 6
        
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    func configure(with log: LogItem, isFirst: Bool = false, isLast: Bool = false) {
        // 첫 번째/마지막 셀 여백
        topConstraint.constant = isFirst ? 10 : 4
        bottomConstraint.constant = isLast ? 10 : 4
        // 상태 텍스트
        statusLable.text = log.statusText
        statusLable.font = .systemFont(ofSize: 12, weight: .bold)
        
        // 방향 텍스트
        commandWayLabel.text = log.directionText
        commandWayLabel.font = .systemFont(ofSize: 11, weight: .bold)
        
        // 로그 내용
        logTextView.text = "[\(log.action)]\n\(log.detail)"
        logTextView.font = .systemFont(ofSize: 13)
        
        // 상태별 색상
        applyStatusColor(log.status)
        
        // 방향별 색상
        applyDirectionColor(log.direction)
    }
    
    private func applyStatusColor(_ status: LogStatus) {
        switch status {
        case .pending:
            containerView.backgroundColor = UIColor.systemGray4
            statusPillView.backgroundColor = UIColor.systemGray4
            statusLable.textColor = UIColor.systemGray
        case .success:
            containerView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            statusPillView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
            statusLable.textColor = UIColor.systemGreen
        case .failure:
            containerView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
            statusPillView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
            statusLable.textColor = UIColor.systemOrange
        }
    }
    
    private func applyDirectionColor(_ direction: LogDirection) {
        switch direction {
        case .webToNative:
            commnandWayPillContainerView.backgroundColor = UIColor.systemCyan.withAlphaComponent(0.25)
            commandWayLabel.textColor = UIColor.systemCyan
        case .nativeToWeb:
            commnandWayPillContainerView.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.15)
            commandWayLabel.textColor = UIColor.systemPurple
        }
    }
}

