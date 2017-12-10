import Vapor

extension Droplet {
    func setupRoutes() throws {
        let messageController = MessageController()
        messageController.addRoutes(to: self)
        
        let userController = UserController()
        userController.addRoutes(to: self)
        /*
        let postController = PostController()
        resource("posts", postController)*/
    }
}
