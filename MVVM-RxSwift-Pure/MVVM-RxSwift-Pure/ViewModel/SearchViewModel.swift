//
//  SearchViewModel.swift
//  Search-MVVM-RxSwift
//
//  Created by Toshiyana on 2022/06/18.
//

import RxSwift
import RxCocoa

final class SearchViewModel: ViewModelType {
    struct Input {
        let ready: Driver<Void>
        let selectedIndex: Driver<IndexPath>
        let searchText: Driver<String>
    }
//    let viewWillAppearSubject = PublishSubject<Void>()
//    let selectedIndexSubject = PublishSubject<IndexPath>()
//    let searchQuerySubject = BehaviorSubject(value: "")
    
    struct Output {
        let loading: Driver<Bool>
        let repos: Driver<[Repo]>
        let selectedRepoUrl: Driver<String>
    }
//    var loading: Driver<Bool>
//    var repos: Driver<[Repo]>
//    var selectedRepoUrl: Driver<String>
    
    struct Dependencies {
        let networking: NetworkingService
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func transform(input: Input) -> Output {
        let loading = ActivityIndicator()
        
        // 検索前に表示するリポジトリ
        let initialRepos = input.ready
            .flatMap { _ in
                self.dependencies.networking.searchRepos(withQuery: "swift")
                    .trackActivity(loading)
                    .asDriver(onErrorJustReturn: [])
            }
        
        let searchRepos = input.searchText
            .filter { $0.count > 2 }
            .debounce(.milliseconds(300))
            .distinctUntilChanged()
            .flatMapLatest { query in
                self.dependencies.networking.searchRepos(withQuery: query)
                    .trackActivity(loading)
                    .asDriver(onErrorJustReturn: [])
            }
        
        let repos = Driver.merge(initialRepos, searchRepos)
        
        let selectedRepoUrl = input.selectedIndex
            .withLatestFrom(repos) { (indexPath, repos) in
                return repos[indexPath.item]
            }
            .map { $0.repoUrl }
        
        return Output(loading: loading.asDriver(),
                      repos: repos,
                      selectedRepoUrl: selectedRepoUrl)
    }
    
//    private let networkingService: NetworkingService
//
//    init(networkingService: NetworkingService) {
//        self.networkingService = networkingService
//
//        let loading = ActivityIndicator()
//        self.loading = loading.asDriver()
//
//        // 検索前に表示するリポジトリ
//        let initialRepos = viewWillAppearSubject
//            .asObservable()
//            .flatMap { _ in
//                networkingService.searchRepos(withQuery: "rxswift")
//                    .trackActivity(loading)
//            }
//            .asDriver(onErrorJustReturn: [])
//
//        let searchRepos = searchQuerySubject
//            .asObservable()
//            .filter { $0.count > 2 } // 3文字以上の時のみ検索
//            .debounce(.milliseconds(300), scheduler: MainScheduler.instance) // サーバー負荷を考慮して、APIを叩きすぎるのを防ぐ
//            .distinctUntilChanged()
//            .flatMapLatest { query in
//                networkingService.searchRepos(withQuery: query)
//                    .trackActivity(loading)
//            }
//            .asDriver(onErrorJustReturn: [])
//
//        let repos = Driver.merge(initialRepos, searchRepos) // 2つの同じ方のデータストリームを1つに統合
//        self.repos = repos
//
//        selectedRepoUrl = selectedIndexSubject
//            .asObservable()
//            .withLatestFrom(repos) { indexPath, repos in
//                return repos[indexPath.item]
//            } // あるObservableにもう一方のObservableの最新値を合成
//            .map { $0.repoUrl }
//            .asDriver(onErrorJustReturn: "")
//    }
}
