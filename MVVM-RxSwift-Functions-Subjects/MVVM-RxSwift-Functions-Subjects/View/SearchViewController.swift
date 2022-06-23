//
//  ViewController.swift
//  Search-MVVM-RxSwift
//
//  Created by Toshiyana on 2022/06/15.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices

class SearchViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    private let viewModel = SearchViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ArticleCell.nib(), forCellReuseIdentifier: ArticleCell.identifier)
        tableView.rowHeight = 80
        
        bindViewModel()
    }

    private func bindViewModel() {
        // MARK: - Inputs
        tableView.rx.itemSelected
            .asObservable()
            .subscribe(onNext: { [weak self] indexPath in
                guard let strongSelf = self else { return }
                strongSelf.viewModel.didSelect(index: indexPath)
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.text
            .orEmpty
            .asObservable()
            .subscribe(onNext: { [weak self] query in
                guard let strongSelf = self else { return }
                strongSelf.viewModel.didSearch(query: query)
            })
            .disposed(by: disposeBag)
        
        // MARK: - Outputs
        viewModel.loading
            .drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)
        
        viewModel.repos
            .drive(
                tableView.rx.items(cellIdentifier: ArticleCell.identifier,
                                   cellType: ArticleCell.self)
            ) { (row, element, cell) in
                cell.configure(repo: element)
            }
            .disposed(by: disposeBag)
        
        viewModel.selectedRepoUrl
            .drive(onNext: { [weak self] repoUrl in
                guard let strongSelf = self else { return }
                let safariViewController = SFSafariViewController(url: URL(string: repoUrl)!)
                strongSelf.present(safariViewController, animated: true)
            })
            .disposed(by: disposeBag)        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

