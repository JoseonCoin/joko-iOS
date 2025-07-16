import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class QuizViewController: BaseViewController<QuizViewModel>, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private let fetchTrigger = PublishRelay<Void>()
    private var quizIds: [Int] = []

    private let coinPriceLabel = UILabel().then {
        $0.font = .JokoFont(.title3)
        $0.text = "조코 불러오는중..."
        $0.textColor = .main
    }
    
    private let quizImageView = UIImageView().then {
        $0.backgroundColor = .red
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
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        bind()
//    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTrigger.accept(())
    }

    internal override func bind() {
        let input = QuizViewModel.Input(fetchTrigger: fetchTrigger.asObservable())
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
            $0.leading.trailing.equalToSuperview().inset(115)
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
}
