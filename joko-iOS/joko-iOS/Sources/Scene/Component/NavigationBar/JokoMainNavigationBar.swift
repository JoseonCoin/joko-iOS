import UIKit
import SnapKit
import Then

public class JokoMainNavigationBar: UIView {
    
    // MARK: - Properties
    weak var parentViewController: UIViewController?
    
    private let sinceBackView = UIView().then {
        $0.backgroundColor = .red
    }
    
    private let sinceButton = UIButton().then {
        $0.setTitle("조선 전기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .chosunFont(size: 20)
    }
    
    private let sinceUnderButton = UIButton().then {
        $0.setImage(UIImage(named: "underbutton"), for: .normal)
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 390, height: 44)
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func layout() {
        addSubview(sinceBackView)
        sinceBackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(9.5)
            $0.bottom.equalToSuperview().inset(9.5)
            $0.leading.equalToSuperview().inset(20)
        }
        
        sinceBackView.addSubview(sinceButton)
        sinceButton.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
        }
        
        sinceBackView.addSubview(sinceUnderButton)
        sinceUnderButton.snp.makeConstraints {
            $0.leading.equalTo(sinceButton.snp.trailing).offset(4)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.width.height.equalTo(24)
        }
    }
    
    private func setupGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(sinceBackViewPressed(_:)))
        longPressGesture.minimumPressDuration = 0.0
        sinceBackView.addGestureRecognizer(longPressGesture)
        sinceBackView.isUserInteractionEnabled = true
    }
    
    // MARK: - Actions
    @objc private func sinceBackViewPressed(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            UIView.animate(withDuration: 0.1) {
                self.sinceBackView.alpha = 0.7
            }
        case .ended:
            UIView.animate(withDuration: 0.1) {
                self.sinceBackView.alpha = 1.0
            }
            presentChangeEraViewController()
        case .cancelled:
            UIView.animate(withDuration: 0.1) {
                self.sinceBackView.alpha = 1.0
            }
        default:
            break
        }
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
}
