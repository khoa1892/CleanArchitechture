
import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UIScrollView {
    
    public var reachedBottom: ControlEvent<Void> {
        let observable = contentOffset.flatMapLatest { [weak base] contentOffset -> Observable<Void> in
            guard let scrollView = base else {
                return Observable.empty()
            }
            let currentOffset = scrollView.contentOffset.y
            let maximunOffset = scrollView.contentSize.height - scrollView.frame.size.height
            
            if maximunOffset - currentOffset <= 10 {
                return Observable.just(())
            }
            return Observable.empty()
        }
        
        return ControlEvent(events: observable)
    }
    
    public var reachedTop: ControlEvent<Void> {
        let observable = contentOffset.flatMapLatest { contentOffset -> Observable<Void> in
            if contentOffset.y <= 0 {
                return Observable.just(())
            }
            return Observable.empty()
        }
        
        return ControlEvent(events: observable)
    }
}
