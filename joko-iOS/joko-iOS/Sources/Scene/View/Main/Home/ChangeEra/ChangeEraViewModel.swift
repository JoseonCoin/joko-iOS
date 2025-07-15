import Foundation
import RxSwift
import RxCocoa
import Moya

public class ChangeEraViewModel: BaseViewModel {
    public struct Input {
        // 나중에 필요한 Input 정의
    }
    
    public struct Output {
        // 나중에 필요한 Output 정의
        public init() {} // 빈 이니셜라이저 추가
    }
    
    public init() {} // 필요 시 생성자 추가
    
    public func transform(input: Input) -> Output {
        return Output() // 빈 Output 반환
    }
}
