//
//  UserController.swift
//  BackendPackageDescription
//
//  Created by Sarah Sauseng on 08.12.17.
//

import FluentProvider
import HTTP
import JSON

final class UserController {
    
    func addRoutes(to auth: RouteBuilder, drop: Droplet) {
        drop.post("api/user", handler: createUser)
        let userGroup = auth.grouped("api", "user")
        userGroup.put(User.parameter, handler: updateUser)
        userGroup.get(User.parameter, ":user_id", handler: getUserKey)
        userGroup.delete(User.parameter, handler: deleteUser)
        userGroup.get(User.parameter, "messages", handler: getUserMessages)
        userGroup.delete(User.parameter, "messages", handler: deleteUserMessages)
    }
    
    func createUser(_ req: Request) throws -> ResponseRepresentable {
        guard let device_info = req.data["device_info"]?.string else {
            throw Abort.badRequest
        }
        guard let push_token = req.data["push_token"]?.string else {
            throw Abort.badRequest
        }
        guard let public_key = req.data["public_key"]?.string else {
            throw Abort.badRequest
        }
        
        let user = try User(device_info: device_info, push_token: push_token, public_key: public_key)
        try user.save()
        
        let tok = try Token(user: user)
        try tok.save()
        
        return tok
    }
    
    func getUserKey(_ req: Request) throws -> ResponseRepresentable {
        let userAuth = try req.auth.assertAuthenticated(User.self)
        
        let user_id =  req.parameters["user_id"]?.string
        guard let user = try User.find(user_id) else {
            throw Abort.notFound
        }
        
        var json = JSON()
        try json.set("public_key", user.public_key)
        
        return json
    }
    
    func updateUser(_ req: Request) throws -> ResponseRepresentable {
        let userAuth = try req.auth.assertAuthenticated(User.self)
        
        guard let push_token = req.data["push_token"]?.string else {
            throw Abort.badRequest
        }
        
        userAuth.push_token = push_token
        try userAuth.save()
        
        var json = JSON()
        try json.set("success", true)
        
        return json
    }

    func deleteUser(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.auth.assertAuthenticated(User.self)
        try user.delete()
        return user
    }
    
    func getUserMessages(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.auth.assertAuthenticated(User.self)
        let messages = try user.messages.all().makeJSON()
        
        try deleteUserMessages(req)
        
        return messages
    }
    
    func deleteUserMessages(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.auth.assertAuthenticated(User.self) 
        let messages = try Message.makeQuery().filter("user__id" == user.id).all()
        
        for msg in messages {
            try msg.delete()
        }
        
        var json = JSON()
        try json.set("success", true)
        
        return json
    }
    
}
