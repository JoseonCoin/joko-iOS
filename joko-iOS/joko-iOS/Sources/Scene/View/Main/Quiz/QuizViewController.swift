import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class QuizViewController: BaseViewController<QuizViewModel>, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private let fetchTrigger = PublishRelay<Void>()
    private let submitTrigger = PublishRelay<(quizId: Int, selectedIndex: Int)>()
    private var quizIds: [Int] = []
    private var currentQuiz: Quiz?

    private let coinPriceLabel = UILabel().then {
        $0.font = .JokoFont(.title3)
        $0.text = "조코 불러오는중..."
        $0.textColor = .main
    }
    
    private let quizImageView = UIImageView().then {
        $0.backgroundColor = .gray500
        $0.layer.cornerRadius = 24
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let questionLabel = UILabel().then {
        $0.font = .JokoFont(.title2)
        $0.text = "문제 불러오는 중..."
        $0.textColor = .white1
        $0.numberOfLines = 0
        $0.textAlignment = .center
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
        fetchTrigger.accept(())
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
                print("📋 Quiz IDs received in VC: \(ids)")
            })
            .disposed(by: disposeBag)

        output.quiz
            .drive(onNext: { [weak self] quiz in
                guard let self = self else { return }
                print("📝 Quiz received in VC: \(quiz.question)")
                self.currentQuiz = quiz
                self.updateUI(with: quiz)
            })
            .disposed(by: disposeBag)
        
        output.submitResult
            .drive(onNext: { [weak self] result in
                guard let self = self else { return }
                print("✅ Submit result received in VC: \(result)")
                self.handleSubmitResult(result)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateUI(with quiz: Quiz) {
        DispatchQueue.main.async {
            self.questionLabel.text = quiz.question
            self.coinPriceLabel.text = "\(quiz.coin)조코"
            
            // 이미지 처리 - imageUrl이 옵셔널이므로 안전하게 처리
            if let imageUrl = quiz.imageUrl, !imageUrl.isEmpty {
                self.loadImage(from: imageUrl)
            } else {
                print("ℹ️ No image URL provided, using default background")
                self.quizImageView.image = nil
                self.quizImageView.backgroundColor = .gray500
            }
            
            print("🎨 UI updated with quiz: \(quiz.question)")
        }
    }
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid image URL: \(urlString)")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.quizImageView.image = image
                        print("✅ Image loaded successfully")
                    }
                }
            } catch {
                print("❌ Image load error: \(error)")
                DispatchQueue.main.async {
                    self.quizImageView.backgroundColor = .gray500
                }
            }
        }
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
            print("🔄 Alert dismissed")
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
            $0.leading.trailing.equalToSuperview().inset(20)
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
        guard let currentQuiz = currentQuiz else {
            print("❌ No current quiz available")
            return
        }

        let selectedIndex = indexPath.item
        print("👆 Selected option \(selectedIndex) for quiz \(currentQuiz.quizId)")
        submitTrigger.accept((quizId: currentQuiz.quizId, selectedIndex: selectedIndex))
    }
}
