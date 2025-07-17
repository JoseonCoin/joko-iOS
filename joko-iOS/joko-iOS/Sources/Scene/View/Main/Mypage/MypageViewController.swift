import UIKit
import SnapKit
import Then

final class MyPageViewController: BaseViewController<MypageViewModel> {
    
    private let myPageImageView = UIImageView().then {
        $0.image = UIImage(named: "mypageview")?.withRenderingMode(.alwaysOriginal)
    }
    
    private let loginOutButton = JokoButton(
        buttonText: "로그아웃",
        isHidden: false
    ).then {
        $0.backgroundColor = .clear
    }
    
    public override func addView() {
        view.addSubview(loginOutButton)
        view.addSubview(myPageImageView)
    }
    
    public override func attribute() {
        view.backgroundColor = .background
        hideKeyboardWhenTappedAround()
        loginOutButton.backgroundColor = .clear
        
        loginOutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }
    
    public override func setLayout() {
        loginOutButton.snp.makeConstraints {
            $0.top.equalTo(665)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(350)
            $0.height.equalTo(60)
        }

        myPageImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
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
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "refresh_token")
        
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
