import UIKit

final class SingleImageViewController: UIViewController {
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    private let scrollView: UIScrollView
    private let imageView: UIImageView
    private let backButton: UIButton
    private let shareButton: UIButton
    
    convenience init(image: UIImage) {
        self.init()
        self.image = image
    }
    
    init() {
        scrollView = UIScrollView()
        imageView = UIImageView()
        backButton = UIButton(type: .system)
        shareButton = UIButton(type: .system)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        scrollView = UIScrollView()
        imageView = UIImageView()
        backButton = UIButton(type: .system)
        shareButton = UIButton(type: .system)
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        
        setupScrollView()
        setupImageView()
        setupButtons()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.delegate = self
        
        guard let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        shareButton.layer.cornerRadius = shareButton.frame.height / 2
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupImageView() {
        scrollView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
    }
    
    private func setupButtons() {
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.titleLabel?.font = .systemFont(ofSize: 18)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        let shareBtnImg = UIImage(systemName: "square.and.arrow.down")
        shareButton.setImage(shareBtnImg, for: .normal)
        shareButton.tintColor = .white
        shareButton.backgroundColor = .black
        shareButton.clipsToBounds = true
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        
        [backButton, shareButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.heightAnchor.constraint(equalToConstant: 24),
            backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor),
            
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.heightAnchor.constraint(equalToConstant: 51),
            shareButton.widthAnchor.constraint(equalToConstant: 51)
        ])
    }
    
    @objc private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapShareButton() {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        centerScrollViewContents()
    }
    
    private func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size
        let contentsSize = scrollView.contentSize
        
        var contentInsets = UIEdgeInsets.zero
        
        if contentsSize.width < boundsSize.width {
            contentInsets.left = (boundsSize.width - contentsSize.width) / 2
            contentInsets.right = contentInsets.left
        }
        
        if contentsSize.height < boundsSize.height {
            contentInsets.top = (boundsSize.height - contentsSize.height) / 2
            contentInsets.bottom = contentInsets.top
        }
        
        scrollView.contentInset = contentInsets
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        centerScrollViewContents()
    }
}
