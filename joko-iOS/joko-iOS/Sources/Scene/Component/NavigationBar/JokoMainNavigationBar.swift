import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

public class JokoMainNavigationBar: UIView {
    weak var parentViewController: UIViewController?
    
    private let sinceUnderButton = UIButton().then {
        let image = UIImage(named: "underbutton")?.withRenderingMode(.alwaysOriginal)
        $0.setImage(image, for: .normal)
    }
    
    private let shopButton = UIImageView().then {
        $0.image = UIImage(named: "shop")?.withRenderingMode(.alwaysOriginal)
        $0.isUserInteractionEnabled = true
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 390, height: 44)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        addSubview(sinceUnderButton)
        sinceUnderButton.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(9.5)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(100)
            $0.height.equalTo(25)
        }
        
        addSubview(shopButton)
        shopButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(44)
            $0.height.equalTo(36)
        }
    }
    
    private func setupGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(sinceUnderButtonPressed(_:)))
        longPressGesture.minimumPressDuration = 0.0
        sinceUnderButton.addGestureRecognizer(longPressGesture)
        sinceUnderButton.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(shopButtonTapped))
        shopButton.addGestureRecognizer(tapGesture)
    }
    
    @objc private func sinceUnderButtonPressed(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            UIView.animate(withDuration: 0.1) {
                self.sinceUnderButton.alpha = 0.7
            }
        case .ended:
            UIView.animate(withDuration: 0.1) {
                self.sinceUnderButton.alpha = 1.0
            }
            presentChangeEraViewController()
        case .cancelled:
            UIView.animate(withDuration: 0.1) {
                self.sinceUnderButton.alpha = 1.0
            }
        default:
            break
        }
    }
    
    @objc private func shopButtonTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.shopButton.alpha = 0.7
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.shopButton.alpha = 1.0
            }
        }
        pushToShopViewController()
    }
    
    private func presentChangeEraViewController() {
        guard let parentVC = parentViewController else { return }
        
        let changeEraVC = ChangeEraViewController(viewModel: ChangeEraViewModel())
        
        if #available(iOS 15.0, *) {
            changeEraVC.modalPresentationStyle = .pageSheet
            if let sheet = changeEraVC.sheetPresentationController {
                sheet.detents = [UISheetPresentationController.Detent.medium(), UISheetPresentationController.Detent.large()]
                sheet.preferredCornerRadius = 16
                sheet.prefersGrabberVisible = true
            }
        } else {
            changeEraVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            changeEraVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        }
        
        DispatchQueue.main.async {
            parentVC.present(changeEraVC, animated: true)
        }
    }
    
    private func pushToShopViewController() {
        guard let parentVC = parentViewController else { return }
        let shopVC = ShopViewController(viewModel: ShopViewModel())
        if let navigationController = parentVC.navigationController {
            DispatchQueue.main.async {
                navigationController.pushViewController(shopVC, animated: true)
            }
        } else {
            DispatchQueue.main.async {
                parentVC.present(shopVC, animated: true)
            }
        }
    }
}
