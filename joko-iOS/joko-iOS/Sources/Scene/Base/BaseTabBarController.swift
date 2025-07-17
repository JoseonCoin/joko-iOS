import UIKit

public class BaseTabBarController: UITabBarController {
    public enum AnimationType {
        case slide
        case fade
        case scale
        case flip
        case bounce
        case spring
        case none
    }

    public var animationType: AnimationType = .none

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }

    private func setupTabBar() {
        self.tabBar.tintColor = .main
        self.tabBar.isTranslucent = false
        self.tabBar.backgroundColor = .background
        self.delegate = self
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .gray100
        appearance.backgroundColor = .background
        self.tabBar.scrollEdgeAppearance = appearance
    }
}

extension BaseTabBarController: UITabBarControllerDelegate {
    public func tabBarController(
        _ tabBarController: UITabBarController,
        animationControllerForTransitionFrom fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        // 애니메이션 타입이 none이면 nil 반환 (기본 전환 사용)
        if animationType == .none {
            return nil
        }
        
        switch animationType {
        case .slide:
            return SlideTransitionAnimator(viewControllers: viewControllers)
        case .fade:
            return FadeTransitionAnimator()
        case .scale:
            return ScaleTransitionAnimator(viewControllers: viewControllers)
        case .flip:
            return FlipTransitionAnimator(viewControllers: viewControllers)
        case .bounce:
            return BounceTransitionAnimator(viewControllers: viewControllers)
        case .spring:
            return SpringTransitionAnimator(viewControllers: viewControllers)
        case .none:
            return nil
        }
    }
}

// MARK: - Slide Transition Animator
class SlideTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.35

    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to),
              let fromIndex = getIndex(for: fromVC),
              let toIndex = getIndex(for: toVC)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        let frame = transitionContext.initialFrame(for: fromVC)

        var toStart = frame
        toStart.origin.x = toIndex > fromIndex ? frame.width : -frame.width
        toVC.view.frame = toStart

        container.addSubview(toVC.view)

        UIView.animate(withDuration: transitionDuration, animations: {
            fromVC.view.frame.origin.x = toIndex > fromIndex ? -frame.width : frame.width
            toVC.view.frame = frame
        }, completion: { finished in
            // 상태 복원
            fromVC.view.frame = frame
            transitionContext.completeTransition(finished)
        })
    }

    private func getIndex(for vc: UIViewController) -> Int? {
        viewControllers?.firstIndex(where: { $0 == vc })
    }
}

// MARK: - Fade Transition Animator
class FadeTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let transitionDuration: Double = 0.25

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        toView.alpha = 0
        container.addSubview(toView)

        UIView.animate(withDuration: transitionDuration, animations: {
            fromView.alpha = 0
            toView.alpha = 1
        }, completion: { finished in
            // 상태 복원
            fromView.alpha = 1
            transitionContext.completeTransition(finished)
        })
    }
}

// MARK: - Scale Transition Animator
class ScaleTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.3

    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        let frame = transitionContext.initialFrame(for: fromVC)
        
        // 초기 상태 설정
        toVC.view.frame = frame
        toVC.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        toVC.view.alpha = 0
        container.addSubview(toVC.view)

        UIView.animate(withDuration: transitionDuration, animations: {
            fromVC.view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            fromVC.view.alpha = 0
            toVC.view.transform = .identity
            toVC.view.alpha = 1
        }, completion: { finished in
            // 상태 복원
            fromVC.view.transform = .identity
            fromVC.view.alpha = 1
            transitionContext.completeTransition(finished)
        })
    }
}

// MARK: - Flip Transition Animator
class FlipTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.5

    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to),
              let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to),
              let fromIndex = getIndex(for: fromVC),
              let toIndex = getIndex(for: toVC) else {
            transitionContext.completeTransition(false)
            return
        }

        let direction: UIView.AnimationOptions = toIndex > fromIndex ? .transitionFlipFromRight : .transitionFlipFromLeft
        let container = transitionContext.containerView
        
        // 프레임 설정
        let frame = transitionContext.initialFrame(for: fromVC)
        toView.frame = frame
        
        UIView.transition(from: fromView, to: toView, duration: transitionDuration, options: [direction, .curveEaseInOut]) { finished in
            transitionContext.completeTransition(finished)
        }
    }

    private func getIndex(for vc: UIViewController) -> Int? {
        viewControllers?.firstIndex(where: { $0 == vc })
    }
}

// MARK: - Bounce Transition Animator
class BounceTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.6

    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        let frame = transitionContext.initialFrame(for: fromVC)

        // 초기 상태 설정
        toVC.view.frame = frame
        toVC.view.transform = CGAffineTransform(translationX: 0, y: frame.height)
        toVC.view.alpha = 1
        container.addSubview(toVC.view)

        UIView.animate(withDuration: transitionDuration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [.curveEaseInOut]) {
            fromVC.view.transform = CGAffineTransform(translationX: 0, y: -frame.height * 0.3)
            fromVC.view.alpha = 0
            toVC.view.transform = .identity
            toVC.view.alpha = 1
        } completion: { finished in
            // 상태 복원
            fromVC.view.transform = .identity
            fromVC.view.alpha = 1
            transitionContext.completeTransition(finished)
        }
    }
}

// MARK: - Spring Transition Animator
class SpringTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.4

    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to),
              let fromIndex = getIndex(for: fromVC),
              let toIndex = getIndex(for: toVC) else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        let frame = transitionContext.initialFrame(for: fromVC)
        let isRight = toIndex > fromIndex
        let offset = isRight ? frame.width : -frame.width

        // 초기 상태 설정
        toVC.view.frame = frame
        toVC.view.transform = CGAffineTransform(translationX: offset, y: 0)
        container.addSubview(toVC.view)

        UIView.animate(withDuration: transitionDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [.curveEaseInOut]) {
            fromVC.view.transform = CGAffineTransform(translationX: -offset * 0.3, y: 0)
            fromVC.view.alpha = 0.7
            toVC.view.transform = .identity
            toVC.view.alpha = 1
        } completion: { finished in
            // 상태 복원
            fromVC.view.transform = .identity
            fromVC.view.alpha = 1
            transitionContext.completeTransition(finished)
        }
    }

    private func getIndex(for vc: UIViewController) -> Int? {
        viewControllers?.firstIndex(where: { $0 == vc })
    }
}
