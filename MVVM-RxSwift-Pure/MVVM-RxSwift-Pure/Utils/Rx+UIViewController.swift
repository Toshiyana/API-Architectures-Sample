//
//  Rx+UIViewController.swift
//  Search-MVVM-RxSwift
//
//  Created by Toshiyana on 2022/06/22.
//

import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    var viewWillAppear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear(_:)))
            .map { _ in }
        return ControlEvent(events: source)
    }
}
