import UIKit


protocol ImageFeedViewControllerProtocol: AnyObject {
    func insertRows(from oldCount: Int, to newCount: Int)
    func showLoading()
    func hideLoading()
    func showErrorAlert()

    func updateCellLikeState(at index: Int, isLiked: Bool)
    func presentSingleImage(url: URL)
}


final class ImageFeedViewController: UIViewController {

    private let imagesTable = UITableView()
    private var presenter: ImageFeedPresenterProtocol

    // MARK: - Init

    init(presenter: ImageFeedPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        setupUI()
        presenter.viewDidLoad()
    }

    // MARK: - UI Setup

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

// MARK: - ImageFeedViewControllerProtocol

extension ImageFeedViewController: ImageFeedViewControllerProtocol {

    func insertRows(from oldCount: Int, to newCount: Int) {
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        imagesTable.performBatchUpdates {
            imagesTable.insertRows(at: indexPaths, with: .automatic)
        }
    }

    func showLoading() {
        UIBlockingProgressHUD.show()
    }

    func hideLoading() {
        UIBlockingProgressHUD.dismiss()
    }

    func showErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось изменить состояние лайка",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }

    func updateCellLikeState(at index: Int, isLiked: Bool) {
        let indexPath = IndexPath(row: index, section: 0)
        if let cell = imagesTable.cellForRow(at: indexPath) as? ImageViewCell {
            cell.setIsLiked(isLiked)
        }
    }

    func presentSingleImage(url: URL) {
        let vc = SingleImageViewController()
        vc.imageURL = url
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ImageFeedViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.photosCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImageViewCell.identifier,
            for: indexPath
        ) as? ImageViewCell else { return UITableViewCell() }

        cell.delegate = self
        cell.configure(with: presenter.photo(at: indexPath.row))
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ImageFeedViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = presenter.photo(at: indexPath.row)
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        return photo.size.height * scale + imageInsets.top + imageInsets.bottom
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.fetchNextPageIfNeeded(forRowAt: indexPath.row)
    }
}

// MARK: - ImageViewCellDelegate

extension ImageFeedViewController: ImageViewCellDelegate {

    func imageViewCellDidTapLike(_ cell: ImageViewCell) {
        guard let indexPath = imagesTable.indexPath(for: cell) else { return }
        presenter.didTapLike(at: indexPath.row)
    }

    func imageViewCellDidFinishLoading(_ cell: ImageViewCell) {
        guard let indexPath = imagesTable.indexPath(for: cell) else { return }
        imagesTable.reloadRows(at: [indexPath], with: .none)
    }
}
