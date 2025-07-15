import UIKit
import RxSwift
import RxCocoa
import Then
import SnapKit

open class BaseTextField: UITextField {
    public let disposeBag = DisposeBag()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        attribute()
        bindActions()
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }

    open func attribute() {}

    open func layout() {}

    open func bindActions() {}
}
