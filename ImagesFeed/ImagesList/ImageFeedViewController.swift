import UIKit

final class ImageFeedViewController: UIViewController {
    
    private let imagesTable = UITableView()
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService()
    private var imagesListServiceObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupObserver()
        imagesListService.fetchPhotosNextPage()
    }
    
    deinit {
        if let observer = imagesListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
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
    
    private func setupObserver() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        guard oldCount != newCount else { return }
        
        photos = imagesListService.photos
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        
        imagesTable.performBatchUpdates {
            imagesTable.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось изменить состояние лайка",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}

extension ImageFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImageViewCell.identifier,
            for: indexPath
        ) as? ImageViewCell else { return UITableViewCell() }
        
        cell.delegate = self
        cell.configure(with: photos[indexPath.row])
        return cell
    }
}

extension ImageFeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        return photo.size.height * scale + imageInsets.top + imageInsets.bottom
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        guard let url = URL(string: photo.largeImageURL) else { return }
        let vc = SingleImageViewController()
        vc.imageURL = url
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

extension ImageFeedViewController: ImageViewCellDelegate {
    func imageViewCellDidTapLike(_ cell: ImageViewCell) {
        guard let indexPath = imagesTable.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
            case .failure:
                self.showErrorAlert()
            }
        }
    }
}
