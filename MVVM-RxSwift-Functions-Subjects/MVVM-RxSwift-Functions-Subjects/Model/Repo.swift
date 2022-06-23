//
//  Repo.swift
//  Search-MVVM-RxSwift
//
//  Created by Toshiyana on 2022/06/18.
//

import Foundation

struct RepoItems: Decodable {
    let items: [Repo]
}

struct Repo: Decodable {
    let id: Int
    let name: String
    let owner: Owner
    let repoUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case owner
        case repoUrl = "html_url"
    }
}

struct Owner: Decodable {
    let iconImageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case iconImageUrl = "avatar_url"
    }
}
