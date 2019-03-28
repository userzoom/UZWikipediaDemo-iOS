import UIKit

final class WelcomeAnimationViewController: UIViewController {
    private var completedAnimation = false
    let animationView: WelcomeAnimationView
    private let shouldAnimateWhenViewAppears: Bool

    init(animationView: WelcomeAnimationView, shouldAnimateWhenViewAppears: Bool = true) {
        self.animationView = animationView
        self.shouldAnimateWhenViewAppears = shouldAnimateWhenViewAppears
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wmf_addSubviewWithConstraintsToEdges(animationView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard shouldAnimateWhenViewAppears else {
            return
        }
        animate()
    }

    func animate() {
        guard !completedAnimation else {
            return
        }
        animationView.animate()
        completedAnimation = true
    }
}
