//
//  NetworkingAPI.swift
//  Search-MVVM-RxSwift
//
//  Created by Toshiyana on 2022/06/18.
//

import Foundation
import RxSwift
import RxCocoa

protocol NetworkingService {
    func searchRepos(withQuery query: String) -> Observable<[Repo]>
}

final class NetworkingApi: NetworkingService {
    func searchRepos(withQuery query: String) -> Observable<[Repo]> {
        let request = URLRequest(url: URL(string: "https://api.github.com/search/repositories?q=\(query)")!)
        
        // 1. rx拡張にする事でObservable<Data>を返す
        // 2. mapで、Observable<Data>をObservable<[Repo]>にデコード
        return URLSession.shared.rx.data(request: request)
            .map { data -> [Repo] in
                guard let response = try? JSONDecoder().decode(RepoItems.self, from: data) else {
                    return []
                }
                return response.items
            }
    }
    
}
