import UIKit

final class TaskCell: UITableViewCell {
    
    static let identifier = "TaskCell"
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var importanceImageView: UIImageView!
    @IBOutlet weak var categoryImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = false
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        // Thiết lập shadow
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1 // Độ mờ của shadow
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1) // Hướng đổ bóng
        containerView.layer.shadowRadius = 4 // Bán kính của shadow
        
        importanceImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
        categoryImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    // MARK: - Data configuration for cell
    
    func config(
        title: String,
        description: String,
        time: String,
        importance: ImportanceLevel,
        color: TaskColor
    ) {
        titleLabel.text = title
        descLabel.text = description
        hourLabel.text = time
        setImportance(importance)
        setColor(color)
    }
    
    // MARK: - Set background color for cell
    
    private func setColor(_ color: TaskColor) {
        containerView.backgroundColor = UIColor(named: color.rawValue)
    }
    
    // MARK: - Set Importance Level & Change Color Flag
    
    private func setImportance(_ importance: ImportanceLevel) {
        let flagImg = UIImage(systemName: "flag.fill")?.withRenderingMode(.alwaysOriginal)
        switch importance {
        case .low:
            importanceImageView.image = flagImg?.withTintColor(.systemCyan)
        case .medium:
            importanceImageView.image = flagImg?.withTintColor(.systemOrange)
        case .high:
            importanceImageView.image = flagImg?.withTintColor(.systemRed)
        }
    }
}

