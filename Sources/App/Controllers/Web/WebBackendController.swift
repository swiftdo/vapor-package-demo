//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/4.
//

import Fluent
import Vapor
import AnyCodable

struct WebBackendController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    // 必须要登录
    let tokenGroup = routes.grouped(WebSessionAuthenticator(), User.guardMiddleware())
    tokenGroup.get(use: toIndex)
    tokenGroup.get("tagMgt", use: toTagMgt)
    tokenGroup.get("categoryMgt", use: toCategoryMgt)
    tokenGroup.get("postMgt", use: toPostMgt)
    tokenGroup.get("linkMgt", use: toLinkMgt)
    
    // 标签
    tokenGroup.post("tag", use: addTag)
    
    // 分类
    
    // 文章
    
    // 链接
    
    
  }
}

extension WebBackendController {
  
  private func genPageMetadata(pageMeta: PageMetadata) -> AnyEncodable {
    let maxPage = pageMeta.pageCount
    let curPage = pageMeta.page

    var showMaxMore: Bool = true
    var showMinMore: Bool = true
    var showPages: [Int] = []
    
    if (maxPage <= 3) {
      showMaxMore = false
      showMinMore = false
      showPages = [Int](1...maxPage)
    } else {
      if(curPage < 3) {
        showMinMore = false
        showMaxMore = true
      }
      else if (curPage > maxPage - 3) {
        showMinMore = true
        showMaxMore = false
      }
      
      if (curPage == 1) {
        showPages = [curPage, curPage + 1, curPage + 2]
      } else if (curPage == maxPage) {
        showPages = [curPage - 2, curPage - 1, curPage]
      } else {
        showPages = [curPage - 1,curPage, curPage + 1]
      }
    }
    
    return [
      "maxPage": maxPage,
      "minPage": 1,
      "curPage": curPage,
      "showMinMore": showMinMore,
      "showMaxMore": showMaxMore,
      "showPages": showPages,
      "total": pageMeta.total,
      "page":pageMeta.page,
      "per": pageMeta.per,
      "perOptions": [
        ["value": "10", "label": "10条/页"],
        ["value": "20", "label": "20条/页"],
        ["value": "30", "label": "30条/页"],
        ["value": "50", "label": "50条/页"]
      ],
    ]
  }
  private func backendWrapper(_ req: Request, tabName: String, data: AnyEncodable? = nil, pageMeta:PageMetadata? = nil) async throws -> [String: AnyEncodable?] {
    let user = try req.auth.require(User.self)
    let context: [String: AnyEncodable?] = [
      "tabName": .init(tabName),
      "user": .init(user.asPublic()),
      "data": data,
      "pageMeta": pageMeta != nil ? genPageMetadata(pageMeta: pageMeta!): nil,
      "menus": [
        ["href": "/web/backend/tagMgt", "label": "标签管理"],
        ["href": "/web/backend/categoryMgt", "label": "分类管理"],
        ["href": "/web/backend/postMgt", "label": "文章管理"],
        ["href": "/web/backend/linkMgt", "label": "友情链接"]
      ]
    ]
    return context
  }
  
  private func toIndex(_ req: Request) async throws -> View {
    return try await toTagMgt(req)
  }
  
  private func toTagMgt(_ req: Request) async throws -> View {
    let user = try req.auth.require(User.self)
    let tags = try await req.repositories.tag.page(ownerId: user.requireID())
    let context = try await backendWrapper(req,
                                           tabName: "标签管理",
                                           data: .init(tags),
                                           pageMeta: tags.metadata
    )
    return try await req.view.render("backend/tagMgt", context)
  }
  
  private func toCategoryMgt(_ req: Request) async throws -> View {
    let context = try await backendWrapper(req, tabName: "分类管理")
    return try await req.view.render("backend/categoryMgt", context)
  }
  
  private func toPostMgt(_ req: Request) async throws -> View {
    let context = try await backendWrapper(req, tabName: "文章管理")
    return try await req.view.render("backend/postMgt", context)
  }

  private func toLinkMgt(_ req: Request) async throws -> View {
    let context = try await backendWrapper(req, tabName: "友情链接")
    return try await req.view.render("backend/linkMgt", context)
  }
  
  
  /// tag 管理
  private func addTag(_ req: Request) async throws -> Response {
    let user = try req.auth.require(User.self)
    try InTag.validate(content: req)
    let inTag = try req.content.decode(InTag.self)
    let _ = try await req.repositories.tag.add(inTag: inTag, ownerId: user.requireID())

    return req.redirect(to: "/web/backend/tagMgt");
  }
}
