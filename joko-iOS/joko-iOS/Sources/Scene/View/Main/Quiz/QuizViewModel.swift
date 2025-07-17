import RxSwift
import Moya
import RxCocoa

public class QuizViewModel: BaseViewModel {
    private let disposeBag = DisposeBag()
    private let provider = MoyaProvider<QuizAPI>(plugins: [MoyaLoggingPlugin()])
    
    public struct Input {
        let fetchTrigger: Observable<Void>
        let submitTrigger: Observable<(quizId: Int, selectedIndex: Int)>
    }
    
    public struct Output {
        let quizIds: Driver<[Int]>
        let quiz: Driver<Quiz>
        let submitResult: Driver<QuizSubmitResponse>
    }
    
    public func transform(input: Input) -> Output {
        let quizIdsRelay = BehaviorRelay<[Int]>(value: [])
        let userId = 1 // 하드코딩된 userId
        
        let quizIds = input.fetchTrigger
            .flatMapLatest { [weak self] _ -> Observable<[Int]> in
                guard let self = self else { return .just([]) }
                return self.provider.rx.request(.fetchQuizIds)
                    .filterSuccessfulStatusCodes()
                    .map([Int].self)
                    .asObservable()
                    .do(onNext: { ids in
                        print("✅ Quiz IDs loaded: \(ids)")
                    })
                    .catchAndReturn([])
            }
            .do(onNext: { quizIdsRelay.accept($0) })
            .asDriver(onErrorJustReturn: [])
        
        let quiz = quizIdsRelay
            .filter { !$0.isEmpty }
            .map { $0[0] }
            .flatMapLatest { [weak self] id -> Observable<Quiz> in
                guard let self = self else { return .empty() }
                print("🔄 Fetching quiz with ID: \(id)")
                return self.provider.rx.request(.fetchOneQuiz(id: id))
                    .filterSuccessfulStatusCodes()
                    .map(Quiz.self)
                    .asObservable()
                    .do(onNext: { quiz in
                        print("✅ Quiz loaded: \(quiz.question)")
                    })
                    .catchAndReturn(
                        Quiz(quizId: 0, question: "불러오기 실패", options: [], coin: 0, imageUrl: nil)
                    )
            }
            .asDriver(onErrorDriveWith: .empty())
        
        let submitResult = input.submitTrigger
            .flatMapLatest { [weak self] (quizId, selectedIndex) -> Observable<QuizSubmitResponse> in
                guard let self = self else { return .empty() }
                print("🔄 Submitting quiz: quizId=\(quizId), selectedIndex=\(selectedIndex), userId=\(userId)")
                return self.provider.rx.request(.postQuizSubmit(quizId: quizId, selectedIndex: selectedIndex, userId: userId))
                    .filterSuccessfulStatusCodes()
                    .map(QuizSubmitResponse.self)
                    .asObservable()
                    .do(onNext: { result in
                        print("✅ Submit result: \(result)")
                    })
                    .catchAndReturn(
                        QuizSubmitResponse(correct: false, correctAnswer: "", explanation: "제출 실패", coinReward: 0)
                    )
            }
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(quizIds: quizIds, quiz: quiz, submitResult: submitResult)
    }
}
