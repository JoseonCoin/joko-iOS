import UIKit

final class MyPageViewController: UIViewController {
    
    private let loginOutButton = JokoButton(
        buttonText: "로그아웃",
        isHidden: false
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        title = "마이페이지"

        view.addSubview(loginOutButton)
        loginOutButton.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(100)
        }

        loginOutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }

    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "로그아웃", message: "정말 로그아웃 하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive) { _ in
            self.logout()
        })
        present(alert, animated: true, completion: nil)
    }

    private func logout() {
        // 1. 토큰 삭제
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "refresh_token")

        // 2. 로그인 화면으로 전환
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = scene.delegate as? SceneDelegate else { return }

        let loginVC = LoginViewController(viewModel: LoginViewModel())
        let navController = UINavigationController(rootViewController: loginVC)

        UIView.transition(with: sceneDelegate.window!,
                          duration: 0.3,
                          options: .transitionFlipFromRight,
                          animations: {
                              sceneDelegate.window?.rootViewController = navController
                          },
                          completion: nil)
    }
}
