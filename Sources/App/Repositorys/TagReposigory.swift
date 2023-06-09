//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/9.
//

import Vapor
import Fluent

/// tag 增删改查
protocol TagRepository: Repository {
  func add(inTag: InTag, ownerId: User.IDValue) async throws -> Tag
  func page(ownerId: User.IDValue) async throws -> Page<Tag.Public>
}

extension RepositoryFactory {
    var tag: TagRepository {
        guard let result = resolve(TagRepository.self) as? TagRepository else {
            fatalError("Tag repository is not configured")
        }
        return result
    }
}

