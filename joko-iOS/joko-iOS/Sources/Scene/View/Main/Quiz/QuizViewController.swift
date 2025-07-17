import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class QuizViewController: BaseViewController<QuizViewModel>, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private let fetchTrigger = PublishRelay<Void>()
    private let submitTrigger = PublishRelay<(quizId: Int, selectedIndex: Int, userId: Int)>()
    private var quizIds: [Int] = []
    private var currentQuiz: Quiz?
    private var userId: Int = 1 // 기본값 설정, 실제로는 로그인 시 받아온 값을 사용

    private let coinPriceLabel = UILabel().then {
        $0.font = .JokoFont(.title3)
        $0.text = "조코 불러오는중..."
        $0.textColor = .main
    }
    
    private let quizImageView = UIImageView().then {
        $0.backgroundColor = .gray500
        $0.layer.cornerRadius = 24
    }
    
    private let questionLabel = UILabel().then {
        $0.font = .JokoFont(.title2)
        $0.text = "문제 불러오는 중..."
        $0.textColor = .white1
    }
    
    private lazy var oxCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 144, height: 160)
        layout.minimumInteritemSpacing = 20
        layout.sectionInset = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(OXCollectionViewCell.self, forCellWithReuseIdentifier: OXCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserId() // 유저 아이디를 먼저 가져옴
        fetchTrigger.accept(())
    }
    
    // 유저 아이디를 가져오는 메서드 (기존 코드에서 추출)
    private func fetchUserId() {
        // 여기서는 로그에 보인 userId가 1이므로 하드코딩
        // 실제로는 UserAPI를 통해 가져와야 함
        self.userId = 1
    }

    internal override func bind() {
        let input = QuizViewModel.Input(
            fetchTrigger: fetchTrigger.asObservable(),
            submitTrigger: submitTrigger.asObservable()
        )
        let output = viewModel.transform(input: input)

        output.quizIds
            .drive(onNext: { [weak self] ids in
                guard let self = self else { return }
                self.quizIds = ids
                print("Fetched Quiz IDs: \(ids)")
            })
            .disposed(by: disposeBag)

        output.quiz
            .drive(onNext: { [weak self] quiz in
                guard let self = self else { return }
                self.currentQuiz = quiz
                self.questionLabel.text = quiz.question
                self.coinPriceLabel.text = " \(quiz.coin)조코"
                
                if let url = URL(string: quiz.imageUrl) {
                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: url),
                           let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.quizImageView.image = image
                            }
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output.submitResult
            .drive(onNext: { [weak self] result in
                guard let self = self else { return }
                self.handleSubmitResult(result)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleSubmitResult(_ result: QuizSubmitResponse) {
        let alertTitle = result.correct ? "정답!" : "오답!"
        let alertMessage = """
        \(result.correctAnswer)
        
        \(result.explanation)
        
        보상: \(result.coinReward)조코
        """
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            // 다음 문제로 이동하거나 다른 액션 수행
        })
        present(alert, animated: true)
    }

    public override func addView() {
        [coinPriceLabel, quizImageView, questionLabel, oxCollectionView].forEach { view.addSubview($0) }
    }
    
    public override func attribute() {
        view.backgroundColor = .background
        hideKeyboardWhenTappedAround()
    }
    
    public override func setLayout() {
        coinPriceLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(86)
            $0.centerX.equalToSuperview()
        }
        
        quizImageView.snp.makeConstraints {
            $0.top.equalTo(coinPriceLabel.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(160)
        }
        
        questionLabel.snp.makeConstraints {
            $0.top.equalTo(quizImageView.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
        }
        
        oxCollectionView.snp.makeConstraints {
            $0.top.equalTo(questionLabel.snp.bottom).offset(60)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(308)
            $0.height.equalTo(160)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OXCollectionViewCell.identifier, for: indexPath) as? OXCollectionViewCell else {
            return UICollectionViewCell()
        }
        let isOSelected = indexPath.item == 0
        cell.configure(isOSelected: isOSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let currentQuiz = currentQuiz else { return }

        let selectedIndex = indexPath.item
        submitTrigger.accept((quizId: currentQuiz.quizId, selectedIndex: selectedIndex, userId: userId))
    }
}
