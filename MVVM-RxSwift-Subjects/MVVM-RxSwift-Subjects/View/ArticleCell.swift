//
//  ArticleCell.swift
//  Search-MVVM-RxSwift
//
//  Created by Toshiyana on 2022/06/18.
//

import UIKit
import Kingfisher

class ArticleCell: UITableViewCell {
    static let identifier = "ArticleCell"
    
    static func nib() -> UINib {
        UINib(nibName: "ArticleCell", bundle: nil)
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!

    func configure(repo: Repo) {
        titleLabel.text = repo.name
        iconImageView.kf.setImage(with: URL(string: repo.owner.iconImageUrl))
    }
}
