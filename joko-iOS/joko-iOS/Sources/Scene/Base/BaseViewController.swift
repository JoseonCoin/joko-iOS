import UIKit
import RxSwift
import RxCocoa

open class BaseViewController<ViewModel: BaseViewModel>: UIViewController, UIGestureRecognizerDelegate {
    public let disposeBag = DisposeBag()
    public var viewModel: ViewModel
    public var viewWillAppearRelay = PublishRelay<Void>()
    
    private var hasSetupViews = false  // 뷰 중복 추가 방지 플래그
    
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
        addView()      // viewDidLoad에서 한 번만 호출
        bind()
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !hasSetupViews {
            setLayout()
            hasSetupViews = true
        }
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
