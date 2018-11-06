import Foundation
import UIKit

@available(iOS 10.0, *)
open class MediaGalleryAnimations {
    
    // MARK: Variables
    open var animator: UIViewPropertyAnimator!
    open var currentState: Bool = true
    open var blurEffect = UIBlurEffect(style: .dark)

    private lazy var blurEffectView = UIVisualEffectView(effect: blurEffect)
    private var runningAnimators = [UIViewPropertyAnimator]()
    private var animationProgress = [CGFloat]()

    // MARK: Methods

    open func translationAnimator(
        for vc: UIViewController,
        with duration: TimeInterval) -> UIViewPropertyAnimator {
        let width = vc.view.frame.width
        let height = vc.view.frame.height

        return UIViewPropertyAnimator(
            duration: duration,
            dampingRatio: 1,
            animations: {
                vc.view.frame = CGRect(
                    x: 0,
                    y: height,
                    width: width,
                    height: height)
        })
    }

    open func blurAnimator(
        for blurView: UIVisualEffectView,
        with duration: TimeInterval) -> UIViewPropertyAnimator {

        blurView.frame = UIScreen.main.bounds

        return UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            blurView.effect = nil
        }
    }

    private func animateTransitionIfNeeded(to state: Bool, duration: TimeInterval, vc: UIViewController?) {
        guard
            runningAnimators.isEmpty,
            let vc = vc
            else { return }

        let transitionAnimator = translationAnimator(for: vc, with: duration)
        
        transitionAnimator.addCompletion { position in
            if position == .end {
                vc.dismiss(animated: false, completion: nil)
            }
        }

        let blurAnimator = self.blurAnimator(for: blurEffectView, with: duration)
        
        if #available(iOS 11.0, *) {
            blurAnimator.scrubsLinearly = false
        }
        
        transitionAnimator.startAnimation()
        blurAnimator.startAnimation()
        
        runningAnimators.append(transitionAnimator)
        runningAnimators.append(blurAnimator)
    }
    
    private func beginPanRecognizer(_ vc: UIViewController) {
        animateTransitionIfNeeded(to: !currentState, duration: 1, vc: vc)
        assert(runningAnimators.count == 2)
        runningAnimators.forEach { $0.pauseAnimation() }
        animationProgress = runningAnimators.map { $0.fractionComplete }
    }
    
    private func changePanRecognizer(_ sender: UIPanGestureRecognizer, _ vc: UIViewController) {
        let translation = sender.translation(in: vc.view)
        let screenBounds = UIScreen.main.bounds
        
        var fraction = translation.y / screenBounds.height
        
        assert(runningAnimators.count == 2)
        
        if runningAnimators[0].isReversed {
            fraction *= -1
        }
        
        for (index, animator) in runningAnimators.enumerated() {
            animator.fractionComplete = fraction + animationProgress[index]
        }
    }
    
    private func endPanRecognizer(_ sender: UIPanGestureRecognizer, _ vc: UIViewController) {
        let velocity = sender.velocity(in: vc.view)
        let shouldClose = velocity.y > 0
        
        if currentState == true {
            if !shouldClose && !runningAnimators[0].isReversed {
                runningAnimators.forEach { $0.isReversed = !$0.isReversed }
            }
            
            if shouldClose && runningAnimators[0].isReversed {
                runningAnimators.forEach { $0.isReversed = !$0.isReversed }
            }
        }
        assert(runningAnimators.count == 2)
        runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
        runningAnimators.removeAll()
    }
    
    func handlePanGesture(_ sender: UIPanGestureRecognizer, vc: UIViewController) {
        switch sender.state {
        case .began:
            beginPanRecognizer(vc)
        case .changed:
            changePanRecognizer(sender, vc)
        case .ended:
            endPanRecognizer(sender, vc)
        default:
            ()
        }
    }
}
