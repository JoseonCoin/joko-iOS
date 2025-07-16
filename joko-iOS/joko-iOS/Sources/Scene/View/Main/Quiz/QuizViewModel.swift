import Foundation
import RxSwift
import RxCocoa
import Moya

public class QuizViewModel: BaseViewModel {
    private let disposeBag = DisposeBag()
        private let provider = MoyaProvider<QuizIdAPI>(plugins: [MoyaLoggingPlugin()])
    

    public struct Input {
        let fetchTrigger: Observable<Void>
    }

    public struct Output {
        let quizIds: Driver<[Int]>
        let quiz: Driver<Quiz>
    }

    public func transform(input: Input) -> Output {
        let quizIdsRelay = BehaviorRelay<[Int]>(value: [])

        let quizIds = input.fetchTrigger
            .flatMapLatest { [weak self] _ -> Observable<[Int]> in
                guard let self = self else { return .just([]) }
                return self.provider.rx.request(.fetchQuizIds)
                    .filterSuccessfulStatusCodes()
                    .map([Int].self)
                    .asObservable()
                    .catchAndReturn([])
            }
            .do(onNext: { quizIdsRelay.accept($0) })
            .asDriver(onErrorJustReturn: [])

        let quiz = quizIdsRelay
            .filter { !$0.isEmpty }
            .map { $0[0] }
            .flatMapLatest { [weak self] id -> Observable<Quiz> in
                guard let self = self else { return .empty() }
                return self.provider.rx.request(.fetchOneQuiz(id: id))
                    .filterSuccessfulStatusCodes()
                    .map(Quiz.self)
                    .asObservable()
                    .catchAndReturn(
                        Quiz(quizId: 0, question: "불러오기 실패", options: [], coin: 0, imageurl: "")
                    )
            }
            .asDriver(onErrorDriveWith: .empty())

        return Output(quizIds: quizIds, quiz: quiz)
    }
}
