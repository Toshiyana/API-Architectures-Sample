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
