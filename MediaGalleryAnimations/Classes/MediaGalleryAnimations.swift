import Foundation
import UIKit

@available(iOS 10.0, *)
class MediaGalleryAnimations {
    
    //    MARK: Variables
    var animator: UIViewPropertyAnimator!
    var currentState: Bool = true
    var blur: Bool?
    lazy var blurEffectView = UIVisualEffectView(effect: blurEffect)
    
    private let blurEffect = UIBlurEffect(style: .dark)
    private var runningAnimators = [UIViewPropertyAnimator]()
    private var animationProgress = [CGFloat]()
    
    //    MARK: Methods
    private func animateTransitionIfNeeded(to state: Bool, duration: TimeInterval, vc: UIViewController?) {
        guard runningAnimators.isEmpty else {
            return
        }
        
        guard let vc = vc else {
            return
        }
        
        let width = vc.view.frame.width
        let height = vc.view.frame.height
        
        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            vc.view.frame = CGRect(
                x: 0,
                y: height,
                width: width,
                height: height)
        })
        
        transitionAnimator.addCompletion { position in
            if position == .end {
                vc.dismiss(animated: false, completion: nil)
            }
        }
        
        blurEffectView.frame = UIScreen.main.bounds
        
        let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            self.blurEffectView.effect = nil
        }
        
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
