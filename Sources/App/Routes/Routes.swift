import Vapor
import HTTP
import MongoKitten
import Cheetah
import BSON

extension Droplet {
    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
        //try resource("posts", PostController.self)
        
    }
}
