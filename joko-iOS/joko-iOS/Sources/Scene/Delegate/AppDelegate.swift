import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        return true
//    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
    
    // AppDelegate의 didFinishLaunchingWithOptions에서
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        JokoFontLoader.registerFonts()
        
        // 폰트 등록 확인
        checkChosunFont()
        
        return true
    }

    func checkChosunFont() {
        print("=== 폰트 등록 상태 확인 ===")
        
        // 1. 번들에서 폰트 파일 찾기
        if let fontURL = Bundle.main.url(forResource: "ChosunCentennial", withExtension: "ttf") {
            print("✅ TTF 파일 찾음: \(fontURL)")
        } else if let fontURL = Bundle.main.url(forResource: "ChosunCentennial", withExtension: "otf") {
            print("✅ OTF 파일 찾음: \(fontURL)")
        } else {
            print("❌ 폰트 파일을 찾을 수 없음")
        }
        
        // 2. 폰트 생성 테스트
        if let font = UIFont(name: "ChosunCentennial", size: 20) {
            print("✅ 폰트 생성 성공: \(font.fontName)")
        } else {
            print("❌ 폰트 생성 실패")
        }
        
        // 3. 등록된 모든 폰트 확인
        print("\n=== 등록된 폰트 목록 ===")
        for family in UIFont.familyNames.sorted() {
            let fonts = UIFont.fontNames(forFamilyName: family)
            if family.contains("Chosun") || fonts.contains(where: { $0.contains("Chosun") }) {
                print("Family: \(family)")
                for font in fonts {
                    print("  - \(font)")
                }
            }
        }
    }
}

