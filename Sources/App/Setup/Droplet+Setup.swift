@_exported import Vapor
import HTTP
import AuthProvider

extension Droplet {
    
    public func setup() throws {
        try setupRoutes()
    }
}
