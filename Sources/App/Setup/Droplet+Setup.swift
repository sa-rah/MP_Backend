@_exported import Vapor
import HTTP

extension Droplet {
    
    public func setup() throws {
        try setupRoutes()
        // Do any additional droplet setup
    }
}
