import UIKit

public class MainTabBarController2: BaseTabBarController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        homeVC.tabBarItem = JokoTabBarTypeItem(.home)
        
        let quizVC = UINavigationController(rootViewController: QuizViewController())
        quizVC.tabBarItem = JokoTabBarTypeItem(.quiz)
        
        let myPageVC = UINavigationController(rootViewController: MyPageViewController())
        myPageVC.tabBarItem = JokoTabBarTypeItem(.mypage)
        
        self.viewControllers = [homeVC, quizVC, myPageVC]
    }
}
