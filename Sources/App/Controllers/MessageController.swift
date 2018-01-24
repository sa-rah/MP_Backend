//
//  PostsController.swift
//  BackendPackageDescription
//
//  Created by Sarah Sauseng on 30.11.17.
//

import Vapor
import FluentProvider

final class MessageController {
    
    func addRoutes(to auth: RouteBuilder) {
        let messageGroup = auth.grouped("api", "messages")
        // messageGroup.get(handler: allMessages)
        messageGroup.post(handler: createMessage)
        messageGroup.delete(Message.parameter, handler: deleteMessage)
        messageGroup.get(Message.parameter, "user", handler: getMessageUser)
        messageGroup.get(Message.parameter, handler: getMessage)
    }
    
    func createMessage(_ req: Request) throws -> ResponseRepresentable {
        let userCredentials = try req.auth.assertAuthenticated(User.self)
        
        guard let content = req.data["content"]?.string else {
            throw Abort.badRequest
        }
        guard let signature = req.data["signature"]?.string else {
            throw Abort.badRequest
        }
        guard let sender_id = req.data["sender_id"]?.string else {
            throw Abort.badRequest
        }
        guard let receiver_id = req.data["receiver_id"]?.string else {
            throw Abort.badRequest
        }
      
        guard let user = try User.find(receiver_id) else {
            throw Abort.notFound
        }
        
        let message = try Message(content: content, signature: signature, user: user, sender_id: sender_id)
        try message.save()
        return message
    }
    /*
    func allMessages(_ req: Request) throws -> ResponseRepresentable {
        let messages = try Message.all()
        return try messages.makeJSON()
    }
    */
    func deleteMessage(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.auth.assertAuthenticated(User.self)
        let message = try req.parameters.next(Message.self)
        try message.delete()
        return message
    }
    
    func getMessage(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.auth.assertAuthenticated(User.self)
        let message = try req.parameters.next(Message.self)
        return message
    }
    
    func getMessageUser(_ req: Request) throws -> ResponseRepresentable {
        let userCredential = try req.auth.assertAuthenticated(User.self)
        let msg = try req.parameters.next(Message.self)
        guard let user = try msg.user.get() else {
            throw Abort.notFound
        }
        return user
    }
    
}
