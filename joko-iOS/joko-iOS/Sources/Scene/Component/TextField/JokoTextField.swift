//import UIKit
//import SnapKit
//import Then
//import RxSwift
//import RxCocoa
//
//public class JokoTextField: BaseTextField {
//    public var errorMessage = PublishRelay<String?>()
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
//        isEditing ? .main : .gray900
//    }
//
//    private let titleLabel = UILabel().then {
//        $0.textColor = .white
//        $0.font = .JokoFont(.body1)
//    }
//
//    private let textHideButton = UIButton(type: .system).then {
//        $0.setImage(.eyeOff, for: .normal)
//        $0.tintColor = .gray600
//        $0.contentMode = .scaleAspectFit
//        $0.isHidden = true
//    }
//
//    public init(ㄱ
//        titleText: String? = nil,
//        placeholder: String? = nil,
//        buttonIsHidden: Bool? = nil,
//        showEmailSuffix: Bool = false
//    ) {
//        super.init(frame: .zero)
//        self.titleLabel.text = titleText
//        self.placeholder = placeholder
//        self.textHideButton.isHidden = buttonIsHidden ?? true
//        setPlaceholder()
//    }
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    public override func layoutSubviews() {
//        super.layoutSubviews()
//        setPlaceholder()
//    }
//
//    public override func attribute() {
//        self.textColor = .modeBlack
//        self.font = .pickFont(.caption1)
//        self.backgroundColor = .gray50
//        self.layer.cornerRadius = 4
//        self.layer.border(color: borderColor, width: 1)
//        self.addLeftView()
//        self.addRightView()
//        self.autocapitalizationType = .none
//        self.autocorrectionType = .no
//        self.keyboardType = .alphabet
//    }
//    public override func layout() {
//        [
//            titleLabel,
//            textHideButton
//        ].forEach { self.addSubview($0) }
//
//        titleLabel.snp.makeConstraints {
//            $0.bottom.equalTo(self.snp.top).offset(-12)
//            $0.leading.equalToSuperview()
//        }
//        textHideButton.snp.makeConstraints {
//            $0.centerY.equalToSuperview()
//            $0.trailing.equalToSuperview().inset(16)
//        }
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
//                .font: UIFont.JokoFont(.body4)
//            ]
//        )
//    }
//
//    public override func bindActions() {
//        self.rx.controlEvent(.editingDidBegin)
//            .bind { [weak self] _ in
//                self?.layer.border(color: self?.borderColor, width: 1)
//                self?.errorMessage.accept(nil)
//            }.disposed(by: disposeBag)
//
//        self.textHideButton.rx.tap
//            .bind { [weak self] in
//                self?.isSecureTextEntry.toggle()
//                let imageName: UIImage = (self?.isSecureTextEntry ?? false) ? .eyeOff: .eyeOn
//                self?.textHideButton.setImage(imageName, for: .normal)
//            }.disposed(by: disposeBag)
//
//        self.rx.controlEvent(.editingDidEnd)
//            .bind { [weak self] in
//                self?.layer.borderColor = UIColor.clear.cgColor
//            }.disposed(by: disposeBag)
//
//        errorMessage
//            .bind { [weak self] content in
//                self?.errorLabel.isHidden = content == nil
//                guard let content = content else { return }
//                self?.layer.borderColor = UIColor.error.cgColor
//                self?.errorLabel.text = "\(content)"
//            }.disposed(by: disposeBag)
//    }
//
//}
