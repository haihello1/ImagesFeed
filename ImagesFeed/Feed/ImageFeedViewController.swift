import UIKit

final class ImageFeedViewController: UIViewController {
    
    private let imagesTable = UITableView()
    private let seasons = (0...19).map { String($0) }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = AppColors.background
        setupTableView()
        setupConstraints()
    }
    
    private func setupTableView() {
        imagesTable.backgroundColor = AppColors.background
        imagesTable.separatorStyle = .none
        imagesTable.dataSource = self
        imagesTable.delegate = self
        imagesTable.register(ImageViewCell.self, forCellReuseIdentifier: ImageViewCell.identifier)
        imagesTable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imagesTable)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imagesTable.topAnchor.constraint(equalTo: view.topAnchor),
            imagesTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imagesTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imagesTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

// MARK: - UITableViewDataSource
extension ImageFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return seasons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImageViewCell.identifier,
            for: indexPath
        ) as? ImageViewCell else {
            return UITableViewCell()
        }
        
        let imageName = seasons[indexPath.row]
        cell.configure(with: UIImage(named: imageName))
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ImageFeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: seasons[indexPath.row]) else {
            return 100
        }
        
        let imageInsets = UIEdgeInsets(
            top: AppLayout.spacingVertical,
            left: AppLayout.spacingHorizontal,
            bottom: AppLayout.spacingVertical,
            right: AppLayout.spacingHorizontal
        )
        
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        
        return ceil(cellHeight)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let image = UIImage(named: seasons[indexPath.row]) else { return }
        
        let photoViewer = SingleImageViewController(image: image)
        photoViewer.modalPresentationStyle = .fullScreen
        present(photoViewer, animated: true)
    }
}
