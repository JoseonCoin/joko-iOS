import UIKit

// MARK: - BaseTabBarController
public class BaseTabBarController: UITabBarController {
    public enum AnimationType {
        case slide
        case fade
        case scale
        case flip
        case bounce
        case spring
    }
    
    public var animationType: AnimationType = .spring
    
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
        }
    }
}

class SlideTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.35
    
    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let fromView = fromVC.view,
              let fromIndex = getIndex(forViewController: fromVC),
              let toVC = transitionContext.viewController(forKey: .to),
              let toView = toVC.view,
              let toIndex = getIndex(forViewController: toVC)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let frame = transitionContext.initialFrame(for: fromVC)
        var fromFrameEnd = frame
        var toFrameStart = frame
        fromFrameEnd.origin.x = toIndex > fromIndex ? -frame.width : +frame.width
        toFrameStart.origin.x = toIndex > fromIndex ? +frame.width : -frame.width
        toView.frame = toFrameStart
        
        transitionContext.containerView.addSubview(toView)
        
        UIView.animate(withDuration: transitionDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut]) {
            fromView.frame = fromFrameEnd
            toView.frame = frame
        } completion: { success in
            fromView.removeFromSuperview()
            transitionContext.completeTransition(success)
        }
    }
    
    func getIndex(forViewController vc: UIViewController) -> Int? {
        guard let viewControllers = self.viewControllers else { return nil }
        for (index, viewController) in viewControllers.enumerated() {
            if viewController == vc { return index }
        }
        return nil
    }
}

// MARK: - 2. 페이드 애니메이션
class FadeTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let transitionDuration: Double = 0.25
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        toView.alpha = 0
        containerView.addSubview(toView)
        
        UIView.animate(withDuration: transitionDuration, delay: 0, options: [.curveEaseInOut]) {
            fromView.alpha = 0
            toView.alpha = 1
        } completion: { success in
            fromView.removeFromSuperview()
            transitionContext.completeTransition(success)
        }
    }
}

// MARK: - 3. 스케일 애니메이션
class ScaleTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.3
    
    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let fromView = fromVC.view,
              let fromIndex = getIndex(forViewController: fromVC),
              let toVC = transitionContext.viewController(forKey: .to),
              let toView = toVC.view,
              let toIndex = getIndex(forViewController: toVC)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        let frame = transitionContext.initialFrame(for: fromVC)
        
        toView.frame = frame
        toView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        toView.alpha = 0
        
        containerView.addSubview(toView)
        
        UIView.animate(withDuration: transitionDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.curveEaseInOut]) {
            fromView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            fromView.alpha = 0
            toView.transform = CGAffineTransform.identity
            toView.alpha = 1
        } completion: { success in
            fromView.removeFromSuperview()
            fromView.transform = CGAffineTransform.identity
            transitionContext.completeTransition(success)
        }
    }
    
    func getIndex(forViewController vc: UIViewController) -> Int? {
        guard let viewControllers = self.viewControllers else { return nil }
        for (index, viewController) in viewControllers.enumerated() {
            if viewController == vc { return index }
        }
        return nil
    }
}

// MARK: - 4. 플립 애니메이션
class FlipTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.5
    
    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let fromView = fromVC.view,
              let fromIndex = getIndex(forViewController: fromVC),
              let toVC = transitionContext.viewController(forKey: .to),
              let toView = toVC.view,
              let toIndex = getIndex(forViewController: toVC)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        let frame = transitionContext.initialFrame(for: fromVC)
        
        toView.frame = frame
        containerView.addSubview(toView)
        
        let direction: UIView.AnimationOptions = toIndex > fromIndex ? .transitionFlipFromRight : .transitionFlipFromLeft
        
        UIView.transition(from: fromView, to: toView, duration: transitionDuration, options: [direction, .curveEaseInOut]) { success in
            transitionContext.completeTransition(success)
        }
    }
    
    func getIndex(forViewController vc: UIViewController) -> Int? {
        guard let viewControllers = self.viewControllers else { return nil }
        for (index, viewController) in viewControllers.enumerated() {
            if viewController == vc { return index }
        }
        return nil
    }
}

// MARK: - 5. 바운스 애니메이션
class BounceTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.6
    
    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let fromView = fromVC.view,
              let fromIndex = getIndex(forViewController: fromVC),
              let toVC = transitionContext.viewController(forKey: .to),
              let toView = toVC.view,
              let toIndex = getIndex(forViewController: toVC)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        let frame = transitionContext.initialFrame(for: fromVC)
        
        toView.frame = frame
        toView.transform = CGAffineTransform(translationX: 0, y: frame.height)
        containerView.addSubview(toView)
        
        UIView.animate(withDuration: transitionDuration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [.curveEaseInOut]) {
            fromView.transform = CGAffineTransform(translationX: 0, y: -frame.height)
            fromView.alpha = 0.5
            toView.transform = CGAffineTransform.identity
        } completion: { success in
            fromView.removeFromSuperview()
            fromView.transform = CGAffineTransform.identity
            fromView.alpha = 1
            transitionContext.completeTransition(success)
        }
    }
    
    func getIndex(forViewController vc: UIViewController) -> Int? {
        guard let viewControllers = self.viewControllers else { return nil }
        for (index, viewController) in viewControllers.enumerated() {
            if viewController == vc { return index }
        }
        return nil
    }
}

// MARK: - 6. 스프링 애니메이션 (추천!)
class SpringTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.4
    
    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let fromView = fromVC.view,
              let fromIndex = getIndex(forViewController: fromVC),
              let toVC = transitionContext.viewController(forKey: .to),
              let toView = toVC.view,
              let toIndex = getIndex(forViewController: toVC)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        let frame = transitionContext.initialFrame(for: fromVC)
        
        let isMovingRight = toIndex > fromIndex
        let offsetX = isMovingRight ? frame.width : -frame.width
        
        toView.frame = frame
        toView.transform = CGAffineTransform(translationX: offsetX, y: 0)
        containerView.addSubview(toView)
        
        // 첫 번째 단계: 빠른 이동
        UIView.animate(withDuration: transitionDuration * 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: [.curveEaseOut]) {
            fromView.transform = CGAffineTransform(translationX: -offsetX * 0.3, y: 0)
            fromView.alpha = 0.7
            toView.transform = CGAffineTransform(translationX: offsetX * 0.1, y: 0)
        } completion: { _ in
            // 두 번째 단계: 부드러운 완료
            UIView.animate(withDuration: self.transitionDuration * 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [.curveEaseInOut]) {
                fromView.transform = CGAffineTransform(translationX: -offsetX, y: 0)
                fromView.alpha = 0
                toView.transform = CGAffineTransform.identity
            } completion: { success in
                fromView.removeFromSuperview()
                fromView.transform = CGAffineTransform.identity
                fromView.alpha = 1
                transitionContext.completeTransition(success)
            }
        }
    }
    
    func getIndex(forViewController vc: UIViewController) -> Int? {
        guard let viewControllers = self.viewControllers else { return nil }
        for (index, viewController) in viewControllers.enumerated() {
            if viewController == vc { return index }
        }
        return nil
    }
}
