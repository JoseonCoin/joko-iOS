import Foundation
import RxSwift
import RxCocoa
import Moya

public class HomeViewModel: BaseViewModel {
    public struct Input {}
    
    public struct Output {
        public init() {}
    }
    
    public init() {}

    public func transform(input: Input) -> Output {
        return Output()
    }
}
