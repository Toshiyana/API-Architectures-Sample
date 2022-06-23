//
//  ViewModelType.swift
//  MVVM-RxSwift-Pure
//
//  Created by Toshiyana on 2022/06/23.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
