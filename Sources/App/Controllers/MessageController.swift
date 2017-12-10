//
//  PostsController.swift
//  BackendPackageDescription
//
//  Created by Sarah Sauseng on 30.11.17.
//

import Vapor
import FluentProvider

final class MessageController {
    
    func addRoutes(to drop: Droplet) {
        let messageGroup = drop.grouped("api", "messages")
        messageGroup.get(handler: allMessages)
        messageGroup.post("create", handler: createMessage)
        messageGroup.delete(Message.parameter, handler: deleteMessage)
        messageGroup.get(Message.parameter, "user", handler: getMessageUser)
        messageGroup.get(Message.parameter, handler: getMessage)
    }
    
    func createMessage(_ req: Request) throws -> ResponseRepresentable {
        guard let content = req.data["content"]?.string else {
            throw Abort.badRequest
        }
        guard let sender_id = req.data["sender_id"]?.string else {
            throw Abort.badRequest
        }
        guard let receiver_id = req.data["receiver_id"]?.string else {
            throw Abort.badRequest
        }
      
        let user = try User.makeQuery().filter("public_id" == receiver_id).all()
        
        let message = try Message(content: content, user: user[0], sender_id: sender_id)
        try message.save()
        return message
    }
    
    func allMessages(_ req: Request) throws -> ResponseRepresentable {
        let messages = try Message.all()
        return try messages.makeJSON()
    }
    
    func deleteMessage(_ req: Request) throws -> ResponseRepresentable {
        let message = try req.parameters.next(Message.self)
        try message.delete()
        return message
    }
    
    func getMessage(_ req: Request) throws -> ResponseRepresentable {
        let message = try req.parameters.next(Message.self)
        return message
    }
    
    func getMessageUser(_ req: Request) throws -> ResponseRepresentable {
        let msg = try req.parameters.next(Message.self)
        guard let user = try msg.user.get() else {
            throw Abort.notFound
        }
        return user
    }
    
}
    
    /*
    func getAll(_ req: Request) throws -> ResponseRepresentable {
        print("index")
        return try Post.all().makeJSON()
    }
    
    func show(_ req: Request,  _ post: Post) throws -> ResponseRepresentable {
        let post = try req.parameters.next(Post.self)
        return post
    }
    
    func getOne(_ req: Request) throws -> ResponseRepresentable {
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
    
    func store(_ req: Request) throws -> ResponseRepresentable {
        guard let content = req.data["content"]?.string else {
                throw Abort(.badRequest)
        }
        
        do {
            try Post(name: content).save()
            var json = JSON()
            try json.set("msg","successfully created")
            return json
        } catch {
            return Response(status: .internalServerError)
        }
    }
    
    func update(_ req: Request,  _ post: Post) throws -> ResponseRepresentable {
        guard let id = req.data["id"]?.string else {
            throw Abort(.badRequest)
        }
        
        guard let content = req.data["content"]?.string else {
            throw Abort(.badRequest)
        }
        
        guard let post = try Post.find(id) else {
            throw Abort(.notFound)
        }
        
        let newPost = post
        
        do {
            newPost.name = content
            try newPost.save()
            return try newPost.makeJSON()
        } catch {
            return Response(status: .failedDependency)
        }
    }
  
    func destroy(_ req: Request,  _ post: Post) throws -> ResponseRepresentable {
        print("Test deletet")
        let id = try req.parameters.next(String.self)

        guard let post = try Post.find(id) else {
            throw Abort(.notFound)
        }
        
        do {
            try post.delete()
            var json = JSON()
            try json.set("msg","successfully deleted")
            return json
        } catch {
            return Response(status: .internalServerError)
        }
    }
    
}

extension PostController: ResourceRepresentable {
    typealias Model = Post
    
    func makeResource() -> Resource<PostController.Model> {
        return Resource(
            index: getAll,
            store: store,
            show: show,
            update: update,
            destroy: destroy
        )
    }
}

extension Request {
    fileprivate func post() throws -> Post {
        guard let json = json else { throw Abort.badRequest }
        
        return try Post(json: json)
    }
} */
