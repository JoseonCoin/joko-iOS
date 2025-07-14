import UIKit

public enum JokoTabBarType: Int {
    case home, quiz, mypage

    func tabItemTuple() -> TabItemInfo {
        switch self {
        case .home:
            return .init(
                title: "홈",
                image: .home,
                selectedImage: .selectHome,
                tag: 0
            )
        case .quiz:
            return .init(
                title: "퀴즈",
                image: .quiz,
                selectedImage: .selectQuiz,
                tag: 1
            )
        case .mypage:
            return .init(
                title: "마이페이지",
                image: .mypage,
                selectedImage: .selectMypage,
                tag: 2
            )
        }
    }

}

public class JokoTabBarTypeItem: UITabBarItem {
    public init(_ type: JokoTabBarType) {
        super.init()
        let info = type.tabItemTuple()

        self.title = info.title
        self.image = info.image
        self.selectedImage = info.selectedImage
        self.tag = info.tag
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
