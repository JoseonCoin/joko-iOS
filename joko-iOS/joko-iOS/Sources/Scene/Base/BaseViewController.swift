import UIKit
import RxSwift
import RxCocoa

open class BaseViewController<ViewModel: BaseViewModel>: UIViewController, UIGestureRecognizerDelegate
{
    public let disposeBag = DisposeBag()
    public var viewModel: ViewModel

    public var viewWillAppearRelay = PublishRelay<Void>()
    
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        attribute()
        bind()
    }
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        addView()
        setLayout()
    }
    open func attribute() {
        view.backgroundColor = .systemBackground
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    open func bindAction() {
        // Rx 액션을 설정하는 함수
    }
    open func bind() {
        // UI 바인딩을 설정하는 함수
    }
    open func addView() {
        // 서브뷰를 구성하는 함수
    }
    open func setLayout() {
        // 레이아웃을 설정하는 함수
    }
}

