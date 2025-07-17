import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class ShopCollectionViewCell: UICollectionViewCell {
    static let identifier = "ShopCollectionViewCell"
    
    private let containerView = UIView().then {
        $0.backgroundColor = .gray600
        $0.layer.cornerRadius = 12
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 4
        $0.layer.shadowOpacity = 0.1
    }
    
    private let itemImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    private let nameLabel = UILabel().then {
        $0.font = .JokoFont(.body2)
        $0.textColor = .white1
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private let priceContainer = UIView().then {
        $0.backgroundColor = .gray900
        $0.layer.cornerRadius = 8
    }
    
    private let coinImageView = UIImageView().then {
        $0.image = UIImage(systemName: "bitcoinsign.circle.fill")
        $0.tintColor = .yellow
    }
    
    private let priceLabel = UILabel().then {
        $0.font = .JokoFont(.body3)
        $0.textColor = .white1
    }
    
    private let loadingIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.color = .white1
        $0.hidesWhenStopped = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        itemImageView.image = nil
        nameLabel.text = nil
        priceLabel.text = nil
        loadingIndicator.stopAnimating()
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        [itemImageView, nameLabel, priceContainer, loadingIndicator].forEach {
            containerView.addSubview($0)
        }
        [coinImageView, priceLabel].forEach {
            priceContainer.addSubview($0)
        }
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        itemImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(60)
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.center.equalTo(itemImageView)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(itemImageView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.lessThanOrEqualTo(priceContainer.snp.top).offset(-8)
        }
        
        priceContainer.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
            $0.bottom.equalToSuperview().inset(16)
        }
        
        coinImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(16)
        }
        
        priceLabel.snp.makeConstraints {
            $0.leading.equalTo(coinImageView.snp.trailing).offset(4)
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
        }
    }
    
    func configure(with item: ShopItem) {
        nameLabel.text = item.displayName
        priceLabel.text = "\(item.price)"
        
        if let imageUrl = item.imageUrl, !imageUrl.isEmpty {
            loadImage(from: imageUrl)
        } else {
            setDefaultImage()
        }
    }
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            setDefaultImage()
            return
        }
        
        loadingIndicator.startAnimating()
        itemImageView.alpha = 0.5
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                self?.itemImageView.alpha = 1.0
                
                if let data = data, error == nil, let image = UIImage(data: data) {
                    self?.itemImageView.image = image
                } else {
                    self?.setDefaultImage()
                }
            }
        }.resume()
    }
    
    private func setDefaultImage() {
        itemImageView.image = UIImage(named: "default_item") ?? UIImage(systemName: "photo")
        itemImageView.tintColor = .gray400
    }
    
    func setSelected(_ selected: Bool, animated: Bool = true) {
        let duration = animated ? 0.2 : 0.0
        
        UIView.animate(withDuration: duration) {
            self.containerView.transform = selected ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
            self.containerView.alpha = selected ? 0.8 : 1.0
        }
    }
}
