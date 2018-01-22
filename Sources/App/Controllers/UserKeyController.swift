//
//  UserKeyController.swift
//  BackendPackageDescription
//
//  Created by Sarah Sauseng on 21.01.18.
//

import Vapor
import FluentProvider

final class UserKeyController {
    
    func addRoutes(to drop: Droplet) {
        let userKeyGroup = drop.grouped("api", "keys")
        userKeyGroup.post(handler: createUserKey)
        userKeyGroup.get(UserKey.parameter, handler: getUserKey)
        userKeyGroup.delete(UserKey.parameter, handler: deleteUserKey)
    }
    
    func createUserKey(_ req: Request) throws -> ResponseRepresentable {
        guard let public_key = req.data["public_key"]?.string else {
            throw Abort.badRequest
        }
        guard let public_id = req.data["public_id"]?.string else {
            throw Abort.badRequest
        }
        let userKey = try UserKey(public_key: public_key, public_id: public_id)
        try userKey.save()
        return userKey
    }
    
    func getUserKey(_ req: Request) throws -> ResponseRepresentable {
        let userKey = try req.parameters.next(UserKey.self)
        return userKey
    }
    
    func deleteUserKey(_ req: Request) throws -> ResponseRepresentable {
        let userKey = try req.parameters.next(UserKey.self)
        try userKey.delete()
        return userKey
    }
    
}
