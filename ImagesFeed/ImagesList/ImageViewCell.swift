import UIKit
import Kingfisher

protocol ImageViewCellDelegate: AnyObject {
    func imageViewCellDidTapLike(_ cell: ImageViewCell)
}

final class ImageViewCell: UITableViewCell {
    
    static let identifier = "ImageViewCell"
    weak var delegate: ImageViewCellDelegate?
    
    private let mainImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = AppLayout.cornerRadius
        return iv
    }()
    
    private let dateLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = AppFonts.body
        lbl.textColor = AppColors.textSecondary
        return lbl
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    private var currentTask: DownloadTask?
    
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentTask?.cancel()
        mainImageView.image = nil
        delegate = nil
        removeGradient()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.backgroundColor = AppColors.background
        
        [mainImageView, dateLabel, likeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            mainImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppLayout.spacingVertical),
            mainImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppLayout.spacingHorizontal),
            mainImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppLayout.spacingHorizontal),
            mainImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppLayout.spacingVertical),
            
            dateLabel.leadingAnchor.constraint(equalTo: mainImageView.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: -8),
            
            likeButton.topAnchor.constraint(equalTo: mainImageView.topAnchor, constant: 8),
            likeButton.trailingAnchor.constraint(equalTo: mainImageView.trailingAnchor, constant: -8),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Gradient
    
    private func addGradient() {
        guard gradientLayer == nil else { return }
        
        let gradient = CAGradientLayer()
        gradient.frame = mainImageView.bounds
        gradient.cornerRadius = AppLayout.cornerRadius
        gradient.masksToBounds = true
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        
        mainImageView.layer.addSublayer(gradient)
        gradientLayer = gradient
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0, 0.8, 1]
        animation.duration = 1.0
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: "locationsChange")
    }
    
    private func removeGradient() {
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = mainImageView.bounds
    }
    
    // MARK: - Public
    
    @objc private func likeButtonTapped() {
        delegate?.imageViewCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "likeActive") : UIImage(named: "likeInactive")
        likeButton.setImage(likeImage, for: .normal)
    }
    
    func configure(with photo: Photo) {
        dateLabel.text = photo.createdAt
        setIsLiked(photo.isLiked)
        
        guard let url = URL(string: photo.thumbImageURL) else { return }
        
        addGradient()
        
        mainImageView.kf.indicatorType = .activity
        currentTask = mainImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "stub")
        ) { [weak self] _ in
            guard let self,
                  let tableView = self.superview as? UITableView,
                  let indexPath = tableView.indexPath(for: self) else { return }
            
            self.removeGradient()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
