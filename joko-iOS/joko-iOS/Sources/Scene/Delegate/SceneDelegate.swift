import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        if let accessToken = UserDefaults.standard.string(forKey: "access_token"), !accessToken.isEmpty {
            print("✅ accessToken 있음 → 자동 로그인")
            window?.rootViewController = MainTabBarController2()
        } else {
            print("🚫 accessToken 없음 → 로그인 뷰 진입")
            let loginVC = LoginViewController(viewModel: LoginViewModel())
            let navController = UINavigationController(rootViewController: loginVC)
            window?.rootViewController = navController
        }

        window?.makeKeyAndVisible()
    }

    func switchToMainTabBar() {
        let tabBarController = MainTabBarController2()

        UIView.transition(with: window!, duration: 0.5, options: [.transitionFlipFromRight], animations: {
            self.window?.rootViewController = tabBarController
        }, completion: nil)
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
