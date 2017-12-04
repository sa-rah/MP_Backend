//
//  PostsController.swift
//  BackendPackageDescription
//
//  Created by Sarah Sauseng on 30.11.17.
//

import Vapor
import Fluent
import FluentProvider
import Foundation

final class PostController {
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try Post.all().makeJSON()
    }
    
    func show(_ req: Request, post: Post) throws -> ResponseRepresentable {
        //return try req.parameters.next(Post.self).makeJSON()
        let id = try req.parameters.next(String.self)

        guard let post = try Post.find(id) else {
            throw Abort(.notFound)
        }
        
        do {
            return try post.makeJSON()
        } catch {
            return Response(status: .internalServerError)
        }
    }
    
    func store(_ req: Request, post: Post) -> ResponseRepresentable {
        return
    }
    
    func update(_ req: Request, post: Post) -> ResponseRepresentable {
        return
    }
    
    func destroy(_ req: Request, post: Post) -> ResponseRepresentable {
        return
    }
    
}
extension PostController: ResourceRepresentable {
    func makeResource() -> Resource<Post> {
        return Resource(
            index: index,
            show: show,
            store: store,
            update: update,
            destroy: destroy
        )
    }
}
