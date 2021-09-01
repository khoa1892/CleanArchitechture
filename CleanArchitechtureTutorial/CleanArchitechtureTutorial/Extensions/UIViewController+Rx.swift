
import Foundation
import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UIViewController {

    public var viewDidLoad: Observable<Void> {
        let selector = #selector(base.viewDidLoad)
        return base.rx.methodInvoked(selector).map { _ in () }
    }

    public var viewWillAppear: Observable<Void> {
        let selector = #selector(base.viewWillAppear(_:))
        return base.rx.methodInvoked(selector).map { _ in () }
    }

    public var viewDidAppear: Observable<Void> {
        let selector = #selector(base.viewDidAppear(_:))
        return base.rx.methodInvoked(selector).map { _ in () }
    }

    public var viewWillDisappear: Observable<Void> {
        let selector = #selector(base.viewWillDisappear(_:))
        return base.rx.methodInvoked(selector).map { _ in () }
    }

    public var viewDidDisappear: Observable<Void> {
        let selector = #selector(base.viewDidDisappear(_:))
        return base.rx.methodInvoked(selector).map { _ in () }
    }

    public var willMoveToParentViewController: ControlEvent<UIViewController?> {
        let source = self.methodInvoked(#selector(Base.willMove)).map { $0.first as? UIViewController }
        return ControlEvent(events: source)
    }

    public var didMoveToParentViewController: ControlEvent<UIViewController?> {
        let source = self.methodInvoked(#selector(Base.didMove)).map { $0.first as? UIViewController }
        return ControlEvent(events: source)
    }

    public var didReceiveMemoryWarning: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.didReceiveMemoryWarning)).map { _ in }
        return ControlEvent(events: source)
    }

    public var isVisible: Observable<Bool> {
        let viewDidAppearObservable = self.base.rx.viewDidAppear.map { _ in true }
        let viewWillDisappearObservable = self.base.rx.viewWillDisappear.map { _ in false }
        return Observable<Bool>.merge(viewDidAppearObservable, viewWillDisappearObservable)
    }

    /// Rx observable, triggered when the ViewController is being dismissed
    public var isDismissing: ControlEvent<Bool> {
        let source = self.sentMessage(#selector(Base.dismiss)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
}
