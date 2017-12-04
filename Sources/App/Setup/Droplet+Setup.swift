@_exported import Vapor
import HTTP

extension Droplet {
    
    public func setup() throws {
        //try setupDatabase()
        try setupRoutes()
        // Do any additional droplet setup
    }
    
    private func setupDatabase() throws {
       /* let server = try MongoKitten.Server("mongodb://msgadm:$msgadm_39@cluster0-shard-00-00-4dv29.mongodb.net:27017,cluster0-shard-00-01-4dv29.mongodb.net:27017,cluster0-shard-00-02-4dv29.mongodb.net:27017/posts?ssl=true&replicaSet=Cluster0-shard-0&authSource=admin")
        
        let database = server["posts"]
        let ctn = database["post"]
        
        if server.isConnected {
            print("Successfully connected!")
        } else {
            print("Connection failed")
        }
        
        get("posts") { req in
            return Document(array: Array(try ctn.find()))
        } */
    }
}

/*
extension Document : ResponseRepresentable {
    public func makeResponse() throws -> Response {
        return Response(status: .ok, headers: [
            "Content-Type": "application/json; charset=utf-8"
            ], body: Body(self.makeExtendedJSON().serialize()))
    }
}

extension Request {
    public var document: Document? {
        guard let bytes = self.body.bytes else {
            return nil
        }
        
        do {
            return try Document(extendedJSON: bytes)
        } catch {
            return nil
        }
    }
}*/
