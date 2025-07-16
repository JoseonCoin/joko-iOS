import Foundation
import RxSwift
import RxCocoa
import Moya

public class QuizViewModel: BaseViewModel {
    private let disposeBag = DisposeBag()
    private let provider = MoyaProvider<QuizIdAPI>(
        plugins: [MoyaLoggingPlugin(), AuthPlugin()]
    )
    
    public struct Input {
        let fetchTrigger: Observable<Void>
    }

    public struct Output {
        let quizIds: Driver<[Int]>
    }

    public func transform(input: Input) -> Output {
        let quizIds = input.fetchTrigger
            .flatMapLatest { [weak self] _ -> Observable<[Int]> in
                guard let self = self else { return .just([]) }
                return self.provider.rx.request(.fetchQuizIds)
                    .filterSuccessfulStatusCodes()
                    .map([Int].self)
                    .asObservable()
                    .catchAndReturn([]) // 실패 시 빈 배열 처리
            }
            .asDriver(onErrorJustReturn: [])

        return Output(quizIds: quizIds)
    }
}


