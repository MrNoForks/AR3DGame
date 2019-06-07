//
//  GameVCExtension.swift
//  AR3DGame
//
//  Created by Boppo Technologies on 20/05/19.
//  Copyright © 2019 Boppo. All rights reserved.
//

//There is error in debug when 2 particle System comes it produces objc_weak_error error
//https://stackoverflow.com/questions/53568934/scnparticlesystem-weak-variable-at-addressx-holds-addressys
//https://stackoverflow.com/questions/45294324/how-do-you-get-the-point-in-arkit
import ARKit


struct BitMask {
    
    static let torpedoCategory : Int = 0x1
    static let spaceShipCategory : Int = 0x1 << 1
    static let brick : Int  = 0x1 << 2
    
}

extension GameVC{
    
    func createSpaceShipNode() -> SCNNode?{
        if let node = ModelLoader().loadModel(modelName: "UFO_Alpha", positionX: 0, positionY: 0, positionZ: -0.7, modelSize: 1){
            // ModelLoader().loadModel(modelName: "UFO_A", positionX: 0, positionY: 0, positionZ: -0.7, modelSize: 0.025)
            
            //CollisionBitMask 0 means Idc about collision as we are gonna handle it
            //we dont want to simulate any collision for the node
            
            //Set CollisionBitMask to 0 if we dont care about collision and | for adding more
            setupPhysicsBody(forNode: node, name: "SpaceShip", physicBodyType: .dynamic, categoryBitMask: BitMask.spaceShipCategory, collisionBitMask: BitMask.torpedoCategory | BitMask.brick, contactBitMask: BitMask.torpedoCategory | BitMask.brick)
            
            return node
        }
        return nil
    }
    
    func createTorpedoNode() -> SCNNode?{
        if let node =  ModelLoader().loadModel(modelName: "FiredScene.scn"){
            
            setupPhysicsBody(forNode: node, name: "Torpedo", physicBodyType: .dynamic, categoryBitMask: BitMask.torpedoCategory, collisionBitMask: BitMask.spaceShipCategory, contactBitMask: BitMask.spaceShipCategory)
            
            return node
        }
        
        return nil
    }
    
    func createExplosionNode()->SCNNode?{
        //named: Explosion.scnassets/FireExplosion.scnp
        if let explosionParticleSystem = SCNParticleSystem(named: "FireExplosion.scnp", inDirectory: nil){
            
            let node = SCNNode()
            
            node.addParticleSystem(explosionParticleSystem)
            
            return node
        }
        
        return nil
        
    }
    
    func  setupPhysicsBody(forNode  node: SCNNode,name : String,physicBodyType type : SCNPhysicsBodyType,categoryBitMask category : Int,collisionBitMask collsion : Int , contactBitMask contact : Int){
        
        //Defining nodes physics body and its shape (static it doesnt move, dynamic it moves on contact, kinematic it doesnt move but can apply force to other object when in contact)
        
        //MARK:- Fusing SCNShapes of childNodes to create a one geometry
        //Array of physicsShapes for combing geomtry of childNodes
        var physicsShapes : [SCNPhysicsShape] = []
        
        //Iterating childs of Node
        for child in node.childNodes {
            
            //If Child has geomtry we will append it to physicsShapes
            if let geometry = child.geometry {
                
                physicsShapes.append(SCNPhysicsShape(geometry: geometry, options: nil))
                
            }
            
        }
        
        //If node doesnt have child we use its geometry else we add all childNodes geomtry to create a more accurate body
        
        if node.childNodes.isEmpty{
            
         node.physicsBody = SCNPhysicsBody(type: type, shape: nil)
            
        }
        else{
            
        node.physicsBody = SCNPhysicsBody(type: type, shape: SCNPhysicsShape(shapes: physicsShapes,transforms: [NSValue(scnMatrix4: SCNMatrix4(float4x4(0.8)))] ))
            
        }
        
        //For bounding Box
        //    node.physicsBody = SCNPhysicsBody(type: type, shape: SCNPhysicsShape(node: node, options: [.type: SCNPhysicsShape.ShapeType.boundingBox]))
        
        //Giving node a name
        node.name = name
        
        //Giving node a bitmask to identified by
        node.physicsBody?.categoryBitMask = category
        
        //Bitmask to define which mask collides with it
        node.physicsBody?.collisionBitMask = collsion
        
        //Bitmask which defines interaction and trigger contactBegins
        node.physicsBody?.contactTestBitMask = contact
        
    }
    
    // For random spawner Logic
    func randomPosition(lower : Float , upper : Float) -> Float{
        return Float(arc4random())/Float(UInt32.max) * (lower - upper) + upper
    }
    
    //MARK: - Fire torpedo
    func fireTorpedo(at location : SCNVector3){
        
        torpedoNode = createTorpedoNode()
        
        //Checking if torpedoNode is present else return to avoid no torpedo exceptions
        guard let torpedo = torpedoNode else {return}
        
       // let torpedo = torpedoNode.clone()
        
        //Adding sounds for firing of torpedo
        sceneView.scene.rootNode.runAction(SCNAction.playAudio(SCNAudioSource(named: "torpedo.mp3")!, waitForCompletion: false))
        
//        //trying to get pointView i.e. camera position
//        guard let pointOfView = sceneView.pointOfView else {return}
//
//        //Converting pointView properties to 4x4 matrix for manipulating
//        //rotation,position,scale,(world or local) position OpenGL 4x4 matrix
//        let cameraTransform = pointOfView.simdTransform
//        //For where to place In CameraView in worldspace i.e. location to travel for torpedo -2 in z dimension
//        let newPos = simd_make_float4(0,0,-2,1)
//
//        // Now multiplying cameraTransform  and newPos to place object with respect to camera
//        let newPosInWorldSpace = simd_mul(cameraTransform,newPos)
        
        torpedo.position = getCameraPosition()
        
        // Adding torrpedoNode
        sceneView.scene.rootNode.addChildNode(torpedo)
        
        

        
        torpedo.physicsBody?.applyForce(location, asImpulse: true)
        
        
        
        //Creating a blank SCNACtion Array to hold sequence of actions
        var actionArray = [SCNAction]()
        
        //Moving torpedo in from current location to specified location
        //  actionArray.append(SCNAction.move(to: SCNVector3(x: newPosInWorldSpace.x, y: newPosInWorldSpace.y, z: newPosInWorldSpace.z), duration: 3))
        
        //Moving torpedo in from current location to specified location
        //actionArray.append(SCNAction.wait(duration: 3))
        actionArray.append(SCNAction.fadeOpacity(to: 0, duration: 2))
        
        actionArray.append(SCNAction.wait(duration: 2))
        
        //Removing torpedo from scene
        actionArray.append(SCNAction.removeFromParentNode())
        
        //running all sequence of actions
        torpedo.runAction(SCNAction.sequence(actionArray))
        
        print("Nodes in scene are \(sceneView.scene.rootNode.childNodes.count)")
        
        for child in sceneView.scene.rootNode.childNodes{
            print(child.name ?? "default")
        }
        
    }
    
    //For collision between torpedo and spaceNode
    func torpedoDidCollideWithAlien(torpedoNode : SCNNode?, spaceShipNode : SCNNode?,explosionNode : SCNNode?){
        
        
        //Checking if nodes ain't empty else return to avoid exceptions
        guard let _ = torpedoNode ,let spaceShipNode = spaceShipNode , let explosionNode = explosionNode else{return}

        //Creating array of SCNAction animation
        var spaceShipNodeActionArray = [SCNAction]()
        
        //Fadaout animation
        spaceShipNodeActionArray.append(SCNAction.fadeOut(duration: 2))
        
        //Removing spaceShip Node
      //  spaceShipNodeActionArray.append(SCNAction.removeFromParentNode())
        
        spaceShipNode.runAction(SCNAction.sequence(spaceShipNodeActionArray)){
            
            
            
            // For playing audio of explosion
            self.sceneView.scene.rootNode.runAction(SCNAction.playAudio(SCNAudioSource(named: "explosion.mp3")!, waitForCompletion: false))
            
            explosionNode.position = spaceShipNode.presentation.position
            
            self.sceneView.scene.rootNode.addChildNode(explosionNode)
            
            spaceShipNode.removeFromParentNode()
            
            //ExplosionAnimation array
            var explosionNodeActionArray = [SCNAction]()
            
            //Wait for 0.7 seconds
            explosionNodeActionArray.append(SCNAction.wait(duration: 0.7))
            
            // remove once wait is done
            explosionNodeActionArray.append(SCNAction.removeFromParentNode())
            
            //Run all animation on explosionNode
            explosionNode.runAction(SCNAction.sequence(explosionNodeActionArray)){
           
            
            //Variable to check if torpedo collided to with spaceship setting it true didRender
                self.torpedoCollidedSpaceship = true
            }
            
        }
   
        
    }
    
    //Trying Extra Node contact
    func shootCube(){
        
        let node = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.05))
        
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        
        node.position = SCNVector3(0,0,-0.2)
        
        // node.runAction(SCNAction.move(to: (spaceShipNode?.presentation.position)!, duration: 5))
        
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        node.physicsBody?.categoryBitMask = BitMask.brick
        
        node.physicsBody?.collisionBitMask = BitMask.spaceShipCategory
        
        
        sceneView.scene.rootNode.addChildNode(node)
        print(spaceShipNode?.presentation.position)
        node.physicsBody?.applyForce((spaceShipNode?.presentation.position)!, asImpulse: true)
        
        node.runAction(SCNAction.wait(duration: 5)){
            [unowned node] in
            node.removeFromParentNode()
        }
        
    }
    
    //MARK: -  Get Camera Direction
    func getDirection(for point: CGPoint, in view: SCNView) -> SCNVector3 {
        let farPoint  = view.unprojectPoint(SCNVector3(Float(point.x), Float(point.y), 1))
        let nearPoint = view.unprojectPoint(SCNVector3(Float(point.x), Float(point.y), 0))
        
        return SCNVector3(farPoint.x - nearPoint.x, farPoint.y - nearPoint.y, farPoint.z - nearPoint.z)
    }
    
    //MARK: -  Get Camera Position
    func getCameraPosition() -> SCNVector3 {
   //     let transform = sceneView.session.currentFrame?.camera.transform
      //  let pos = MDLTransform(matrix:transform!)
     //   return SCNVector3(pos.translation.x, pos.translation.y, pos.translation.z)
        return sceneView.pointOfView!.position
    }
    
    
    //MARK: - Render Functions
    
    //Function called when a scene gets rendered
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        //If torpedoCollidedSpaceship
        if torpedoCollidedSpaceship{
            
          //  print(self.spaceShipNode?.position)
            
            //Random number from -1.5 to 1.5
            let xPos = randomPosition(lower: -1.5, upper: 1.5)
            
            //self.spaceShipNode = createSpaceShipNode()
            
            spaceShipNode?.position.x = xPos
            
            if let spaceShipNode = spaceShipNode?.clone(){
                
                
                
                spaceShipNode.opacity = 0
                
                SCNTransaction.begin()
                
                SCNTransaction.animationDuration = 3
                
                spaceShipNode.opacity = 1
                
                sceneView.scene.rootNode.addChildNode(spaceShipNode)
                
                SCNTransaction.commit()
            }
            
            
            torpedoCollidedSpaceship = false
            
        }
    }
    
    //Called before each frame
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let camera = sceneView.pointOfView{
            
            // Distance from world Origin
            let distance = length( camera.simdTransform.columns.3 - sceneView.scene.rootNode.simdTransform.columns.3)

            DispatchQueue.main.async {
                
                if distance > 2 && !self.alertVisible{
                    
                    self.alertVisible = true
                    
                    let alert = UIAlertController(title: "Distance", message: "Try moving back to where you initiated your game from", preferredStyle: .alert)
                    
                    
                    let uiImageAlertAction = UIAlertAction(title: "", style: .default)
                    
                    let image = #imageLiteral(resourceName: "ARWarning.jpg")
                    
                  //  let maxsize = CGSize(width: 245, height: 300)
                    
                    let scaleSize = CGSize(width: 245, height: 245/image.size.width*image.size.height)
                    let reSizedImage = image.resize(with: scaleSize)
                    
                    uiImageAlertAction.setValue(reSizedImage?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), forKey: "Image")
                    
                    alert.addAction(uiImageAlertAction)
                    
                    
                    let okAlert = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        self.alertVisible = false
                    })
                    
                    
                    alert.addAction(okAlert)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            
        }
    }
    
    
    // Triggered when a anchor is detected
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if let imageAnchor = anchor as? ARImageAnchor{
            
            
            sceneView.scene.rootNode.addChildNode(smokeyNode)
            
            var actionArray : [SCNAction] = []
            
            actionArray.append( SCNAction.wait(duration: 5))
            
            actionArray.append( SCNAction.removeFromParentNode())
            
            smokeyNode.runAction(SCNAction.sequence(actionArray))
            
            
            
            if let spaceShipNode = self.spaceShipNode?.clone() {
                
                
                spaceShipNode.position = SCNVector3(x: imageAnchor.transform.columns.3.x, y: imageAnchor.transform.columns.3.y, z: imageAnchor.transform.columns.3.z  )
                
                
                spaceShipNode.scale = SCNVector3(0, 0, 0)
                
                spaceShipNode.runAction(SCNAction.scale(to: 2, duration: 5))
                
                
                self.sceneView.scene.rootNode.addChildNode(spaceShipNode)
                print("found model")
                
            }
          
        }
        return nil
        
    }
}


extension UIImage {
    
    func resize(with size: CGSize) -> UIImage? {
        // size has to be integer, otherwise it could get white lines
        // let size = CGSize(width: floor(self.size.width * scale), height: floor(self.size.height * scale))
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension SCNVector3 {
    /// Returns the length of the vector
    var length: Float {
        return sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
    }
    var normalized: SCNVector3 {
        let length = self.length
        return SCNVector3(self.x/length, self.y/length, self.z/length)
    }
}
