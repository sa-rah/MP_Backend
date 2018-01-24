//
//  MessageMiddleware.swift
//  BackendPackageDescription
//
//  Created by Sarah Sauseng on 10.12.17.
//

import HTTP
import Vapor

final class TokenAuthMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        guard let validToken = request.data["token"]?.string else {
            throw Abort.badRequest
        }
        
        guard let authHeader = request.headers["Authorization"]?.string else {
            throw Abort.unauthorized
        }
        
        if authHeader != validToken {
            throw Abort.unauthorized
        } else {
            return try next.respond(to: request)
        }
    }
}
