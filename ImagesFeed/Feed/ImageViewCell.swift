import UIKit

final class ImageViewCell: UITableViewCell {
    
    static let identifier = "ImageViewCell"
    
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
        lbl.textColor = AppColors.textPrimary
        return lbl
    }()
    
    private let likeButton: UIButton = {
        let lb = UIButton()
        let img = UIImage(resource: .likeInactive)
        lb.setImage(img, for: .normal)
        return lb
    }()
    
    private var isLiked = false

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.backgroundColor = AppColors.background
        
        [mainImageView, dateLabel, likeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        setupConstraints()
        likeButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    @objc private func imageDoubleTapped() {
        likeToggle()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppLayout.spacingVertical),
            mainImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppLayout.spacingHorizontal),
            mainImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppLayout.spacingHorizontal),
            mainImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppLayout.spacingVertical),
            
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppLayout.spacingVertical - AppLayout.spacingBetweenLines),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppLayout.spacingHorizontal + AppLayout.spacingBetweenLines),
            
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppLayout.spacingHorizontal),
            likeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppLayout.spacingVertical),
            likeButton.widthAnchor.constraint(equalToConstant: AppLayout.likeImageSize),
            likeButton.heightAnchor.constraint(equalToConstant: AppLayout.likeImageSize),
        ])
    }
    
    // MARK: - Actions
    @objc private func buttonTapped() {
        likeToggle()
    }
    
    private func likeToggle() {
        isLiked.toggle()
        let imageName = isLiked ? "likeActive" : "likeInactive"
        let image = UIImage(named: imageName)
        likeButton.setImage(image, for: .normal)
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }

    // MARK: - Configure
    func configure(with image: UIImage?, date: String? = nil) {
        mainImageView.image = image
        dateLabel.text = date ?? "15 September 2025"
    }
}
