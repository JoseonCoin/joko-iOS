import UIKit

public class TabBarController: BaseTabBarController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.animationType = .slide
        let homeVC = UINavigationController(rootViewController: HomeViewController(viewModel: HomeViewModel()))
        homeVC.tabBarItem = JokoTabBarTypeItem(.home)
        
        let quizVC = UINavigationController(rootViewController: QuizViewController(viewModel: QuizViewModel()))
        quizVC.tabBarItem = JokoTabBarTypeItem(.quiz)
        
        let myPageVC = UINavigationController(rootViewController: MyPageViewController(viewModel: MypageViewModel()))
        myPageVC.tabBarItem = JokoTabBarTypeItem(.mypage)
        
        self.viewControllers = [homeVC, quizVC, myPageVC]
    }
}
