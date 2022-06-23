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
    
    struct Output {
        let loading: Driver<Bool>
        let repos: Driver<[Repo]>
        let selectedRepoUrl: Driver<String>
    }
    
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
    
}
