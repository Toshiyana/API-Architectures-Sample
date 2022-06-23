//
//  SearchViewModel.swift
//  Search-MVVM-RxSwift
//
//  Created by Toshiyana on 2022/06/18.
//

import RxSwift
import RxCocoa

final class SearchViewModel {
    // Inputs
    let selectedIndexSubject = PublishSubject<IndexPath>()
    let searchQuerySubject = BehaviorSubject(value: "")
    
    // Outputs
    var loading: Driver<Bool>
    var repos: Driver<[Repo]>
    var selectedRepoUrl: Driver<String>
    
    private let networkingService: NetworkingService
    
    init(networkingService: NetworkingService) {
        self.networkingService = networkingService
        
        let loading = ActivityIndicator()
        self.loading = loading.asDriver()
                
        let searchRepos = searchQuerySubject
            .asObservable()
            .filter { $0.count > 2 } // 3文字以上の時のみ検索
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance) // サーバー負荷を考慮して、APIを叩きすぎるのを防ぐ
            .distinctUntilChanged()
            .flatMapLatest { query in
                networkingService.searchRepos(withQuery: query)
                    .trackActivity(loading)
            }
            .asDriver(onErrorJustReturn: [])
            
        self.repos = searchRepos
        
        selectedRepoUrl = selectedIndexSubject
            .asObservable()
            .withLatestFrom(repos) { indexPath, repos in
                return repos[indexPath.item]
            } // あるObservableにもう一方のObservableの最新値を合成
            .map { $0.repoUrl }
            .asDriver(onErrorJustReturn: "")
    }
}
