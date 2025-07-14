//import UIKit
//import SnapKit
//import Then
//import RxSwift
//import RxCocoa
//
//public class JokoTextField: UITextField {
//    public var errorMessage = PublishRelay<String?>()
//    private let disposeBag = DisposeBag()
//    
//    public var isSecurity: Bool = false {
//        didSet {
//            textHideButton.isHidden = !isSecurity
//            self.isSecureTextEntry = isSecurity
//            
//            if isSecurity {
//                self.addLeftAndRightView()
//            } else {
//                self.addLeftView()
//                self.addRightView()
//            }
//        }
//    }
//    
//    private var borderColor: UIColor {
//        isEditing ? .main500 : .clear
//    }
//    
//    private let titleLabel = UILabel().then {
//        $0.textColor = .modeBlack
//        $0.font = .JokoFont(.label)
//    }
//    
//    private let textHideButton = UIButton(type: .system).then {
//        $0.setImage(.eyeOff, for: .normal)
//        $0.tintColor = .modeBlack
//        $0.contentMode = .scaleAspectFit
//        $0.isHidden = true
//    }
//    
//    public init(
//        titleText: String? = nil,
//        placeholder: String? = nil,
//        buttonIsHidden: Bool? = nil
//    ) {
//        super.init(frame: .zero)
//        self.titleLabel.text = titleText
//        self.placeholder = placeholder
//        self.textHideButton.isHidden = buttonIsHidden ?? true
//        
//        setupUI()
//        setupLayout()
//        setupBindings()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    public override func layoutSubviews() {
//        super.layoutSubviews()
//        setPlaceholder()
//    }
//    
//    private func setupUI() {
//        self.textColor = .modeBlack
//        self.font = .JokoFont(.body3)
//        self.backgroundColor = .gray50
//        self.layer.cornerRadius = 4
//        self.layer.border(color: borderColor, width: 1)
//        self.addLeftView()
//        self.addRightView()
//        self.autocapitalizationType = .none
//        self.autocorrectionType = .no
//        self.keyboardType = .alphabet
//        
//        setPlaceholder()
//    }
//    
//    private func setupLayout() {
//        [
//            titleLabel,
//            textHideButton
//        ].forEach { self.addSubview($0) }
//        
//        titleLabel.snp.makeConstraints {
//            $0.bottom.equalTo(self.snp.top).offset(-12)
//            $0.leading.equalToSuperview()
//        }
//        
//        textHideButton.snp.makeConstraints {
//            $0.centerY.equalToSuperview()
//            $0.trailing.equalToSuperview().inset(16)
//        }
//    }
//    
//    private func setupBindings() {
//        // 편집 시작 시
//        self.rx.controlEvent(.editingDidBegin)
//            .bind { [weak self] _ in
//                self?.layer.border(color: self?.borderColor, width: 1)
//                self?.errorMessage.accept(nil)
//            }.disposed(by: disposeBag)
//        
//        // 패스워드 보기/숨기기 버튼
//        self.textHideButton.rx.tap
//            .bind { [weak self] in
//                self?.isSecureTextEntry.toggle()
//                let imageName: UIImage = (self?.isSecureTextEntry ?? false) ? .eyeOff : .eyeOn
//                self?.textHideButton.setImage(imageName, for: .normal)
//            }.disposed(by: disposeBag)
//        
//        // 편집 종료 시
//        self.rx.controlEvent(.editingDidEnd)
//            .bind { [weak self] in
//                self?.layer.borderColor = UIColor.clear.cgColor
//            }.disposed(by: disposeBag)
//    }
//    
//    private func setPlaceholder() {
//        guard let string = self.placeholder else {
//            return
//        }
//        attributedPlaceholder = NSAttributedString(
//            string: string,
//            attributes: [
//                .foregroundColor: UIColor.gray500,
//                .font: UIFont.JokoFont(.placeholder)
//            ]
//        )
//    }
//}
