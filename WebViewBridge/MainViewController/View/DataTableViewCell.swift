import UIKit

class DataTableViewCell: UITableViewCell {
    
    static let identifier = "DataTableViewCell"
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var innerContainerView: UIView!
    
    @IBOutlet weak var keyContainerView: UIView!
    @IBOutlet weak var KeyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
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
        innerContainerView.layer.cornerRadius = innerBorderRadius
        keyContainerView.layer.cornerRadius = 8
        
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    func configure(key: String, value: String, isFirst: Bool = false, isLast: Bool = false) {
        KeyLabel.text = key
        KeyLabel.font = .systemFont(ofSize: 13, weight: .bold)
        
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 14)
        valueLabel.numberOfLines = 0
        
        topConstraint.constant = isFirst ? 10 : 4
        bottomConstraint.constant = isLast ? 10 : 4
    }
}
