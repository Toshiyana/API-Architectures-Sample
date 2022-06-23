//
//  SearchViewModel.swift
//  Search-MVVM-RxSwift
//
//  Created by Toshiyana on 2022/06/18.
//

import RxSwift
import RxCocoa

protocol SearchViewModelInputs {
    func viewWillAppear()
    func didSelect(index: IndexPath)
    func didSearch(query: String)
}

protocol SearchViewModelOutputs {
    var loading: Driver<Bool> { get }
    var repos: Driver<[Repo]> { get }
    var selectedRepoUrl: Driver<String> { get }
}

protocol SearchViewModelType {
    var inputs: SearchViewModelInputs { get }
    var outputs: SearchViewModelOutputs { get }
}

final class SearchViewModel: SearchViewModelType, SearchViewModelInputs, SearchViewModelOutputs {
    init() {
        let loading = ActivityIndicator()
        self.loading = loading.asDriver()
        
        let initialRepos = self.viewWillAppearSubject
            .asObservable()
            .flatMap { _ in
                AppEnvironment.current.networkingService
                    .searchRepos(withQuery: "swift")
                    .trackActivity(loading)
            }
            .asDriver(onErrorJustReturn: [])
        
        let searchRepos = self.didSearchSubject
            .asObservable()
            .filter { $0.count > 2 }
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest { query in
                AppEnvironment.current.networkingService
                    .searchRepos(withQuery: query)
                    .trackActivity(loading)
            }
            .asDriver(onErrorJustReturn: [])
        
        self.repos = Driver.merge(initialRepos, searchRepos)
        
        self.selectedRepoUrl = self.didSelectSubject
            .asObservable()
            .withLatestFrom(repos, resultSelector: { (indexPath, repos) in
                return repos[indexPath.item]
            })
            .map { $0.repoUrl }
            .asDriver(onErrorJustReturn: "")
    }
    
    // MARK: - SearchViewModelInputs
    private let viewWillAppearSubject = PublishSubject<Void>()
    func viewWillAppear() {
        viewWillAppearSubject.onNext(())
    }
    
    private let didSelectSubject = PublishSubject<IndexPath>()
    func didSelect(index: IndexPath) {
        didSelectSubject.onNext(index)
    }
    
    private let didSearchSubject = PublishSubject<String>()
    func didSearch(query: String) {
        didSearchSubject.onNext(query)
    }
    
    // MARK: - SearchViewModelOutputs
    var loading: Driver<Bool>
    var repos: Driver<[Repo]>
    var selectedRepoUrl: Driver<String>
    
    // MARK: - SearchViewModelType
    var inputs: SearchViewModelInputs { return self }
    var outputs: SearchViewModelOutputs { return self }
}

//final class SearchViewModel: ViewModelType {
//    struct Input {
//        let ready: Driver<Void>
//        let selectedIndex: Driver<IndexPath>
//        let searchText: Driver<String>
//    }
//
//    struct Output {
//        let loading: Driver<Bool>
//        let repos: Driver<[Repo]>
//        let selectedRepoUrl: Driver<String>
//    }
//
//    struct Dependencies {
//        let networking: NetworkingService
//    }
//
//    private let dependencies: Dependencies
//
//    init(dependencies: Dependencies) {
//        self.dependencies = dependencies
//    }
//
//    func transform(input: Input) -> Output {
//        let loading = ActivityIndicator()
//
//        // 検索前に表示するリポジトリ
//        let initialRepos = input.ready
//            .flatMap { _ in
//                self.dependencies.networking.searchRepos(withQuery: "swift")
//                    .trackActivity(loading)
//                    .asDriver(onErrorJustReturn: [])
//            }
//
//        let searchRepos = input.searchText
//            .filter { $0.count > 2 }
//            .debounce(.milliseconds(300))
//            .distinctUntilChanged()
//            .flatMapLatest { query in
//                self.dependencies.networking.searchRepos(withQuery: query)
//                    .trackActivity(loading)
//                    .asDriver(onErrorJustReturn: [])
//            }
//
//        let repos = Driver.merge(initialRepos, searchRepos)
//
//        let selectedRepoUrl = input.selectedIndex
//            .withLatestFrom(repos) { (indexPath, repos) in
//                return repos[indexPath.item]
//            }
//            .map { $0.repoUrl }
//
//        return Output(loading: loading.asDriver(),
//                      repos: repos,
//                      selectedRepoUrl: selectedRepoUrl)
//    }
//
//}
