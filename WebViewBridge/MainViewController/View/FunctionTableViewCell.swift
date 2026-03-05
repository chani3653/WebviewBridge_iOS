import UIKit

class FunctionTableViewCell: UITableViewCell {
    @IBOutlet weak var functionNameLabel: UILabel!
    
    static let identifier = "FunctionTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        functionNameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        functionNameLabel.textColor = .label
    }
    
    func configure(with functionName: String) {
        functionNameLabel.text = functionName
    }
}
