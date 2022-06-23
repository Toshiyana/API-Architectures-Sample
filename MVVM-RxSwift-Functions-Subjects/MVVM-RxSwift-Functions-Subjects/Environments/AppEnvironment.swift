//
//  AppEnvironment.swift
//  MVVM-RxSwift-Functions-Subjects
//
//  Created by Toshiyana on 2022/06/24.
//

import Foundation

final class AppEnvironment {
    static var current = Environment()
}

struct Environment {
    let networkingService: NetworkingService
    
    init(networkingService: NetworkingService = NetworkingApi()) {
        self.networkingService = networkingService
    }
}
