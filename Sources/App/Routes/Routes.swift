import Vapor

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
        
        let postController = PostController()
        postController.addRoutes(to: self)
        
        let userController = UserController()
        userController.addRoutes(to: self)
        /*
        let postController = PostController()
        resource("posts", postController)*/
    }
}
