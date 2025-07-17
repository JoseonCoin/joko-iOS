import RxSwift
import Moya
import RxCocoa

public class QuizViewModel: BaseViewModel {
    private let disposeBag = DisposeBag()
    private let provider = MoyaProvider<QuizAPI>(plugins: [MoyaLoggingPlugin()])
    
    public struct Input {
        let fetchTrigger: Observable<Void>
        let submitTrigger: Observable<(quizId: Int, selectedIndex: Int, userId: Int)>
    }
    
    public struct Output {
        let quizIds: Driver<[Int]>
        let quiz: Driver<Quiz>
        let submitResult: Driver<QuizSubmitResponse>
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
                        Quiz(quizId: 0, question: "불러오기 실패", options: [], coin: 0, imageUrl: "")
                    )
            }
            .asDriver(onErrorDriveWith: .empty())
        
        let submitResult = input.submitTrigger
            .flatMapLatest { [weak self] (quizId, selectedIndex, userId) -> Observable<QuizSubmitResponse> in
                guard let self = self else { return .empty() }
                return self.provider.rx.request(.postQuizSubmit(quizId: quizId, selectedIndex: selectedIndex, userId: userId))
                    .filterSuccessfulStatusCodes()
                    .map(QuizSubmitResponse.self)
                    .asObservable()
                    .catchAndReturn(
                        QuizSubmitResponse(correct: false, correctAnswer: "", explanation: "제출 실패", coinReward: 0)
                    )
            }
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(quizIds: quizIds, quiz: quiz, submitResult: submitResult)
    }
}
