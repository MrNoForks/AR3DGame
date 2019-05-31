//
//  GameVCExtension.swift
//  AR3DGame
//
//  Created by Boppo Technologies on 20/05/19.
//  Copyright © 2019 Boppo. All rights reserved.
//

//There is error in debug when 2 particle System comes it produces objc_weak_error error
//https://stackoverflow.com/questions/53568934/scnparticlesystem-weak-variable-at-addressx-holds-addressys

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
    
    //Fire torpedo
    func fireTorpedo(){
        
        torpedoNode = createTorpedoNode()
        
        //Checking if torpedoNode is present else return to avoid no torpedo exceptions
        guard let torpedo = torpedoNode else {return}
        
       // let torpedo = torpedoNode.clone()
        
        //Adding sounds for firing of torpedo
        sceneView.scene.rootNode.runAction(SCNAction.playAudio(SCNAudioSource(named: "torpedo.mp3")!, waitForCompletion: false))
        
        //trying to get pointView i.e. camera position
        guard let pointOfView = sceneView.pointOfView else {return}
        
        //Converting pointView properties to 4x4 matrix for manipulating
        //rotation,position,scale,(world or local) position OpenGL 4x4 matrix
        let cameraTransform = pointOfView.simdTransform
        
        //For where to place In CameraView in worldspace i.e. location to travel for torpedo -2 in z dimension
        let newPos = simd_make_float4(0,0,-2,1)
        
        // Now multiplying cameraTransform  and newPos to place object with respect to camera
        let newPosInWorldSpace = simd_mul(cameraTransform,newPos)
        
        torpedo.position = pointOfView.position
        
        // Adding torrpedoNode
        sceneView.scene.rootNode.addChildNode(torpedo)
        
        torpedo.physicsBody?.applyForce(SCNVector3(x: newPosInWorldSpace.x, y: newPosInWorldSpace.y, z: newPosInWorldSpace.z), asImpulse: true)
        
        
        
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
        guard let torpedoNode = torpedoNode ,let spaceShipNode = spaceShipNode , let explosionNode = explosionNode else{return}
        
        
        

        
        
        
//        //Removing previous animation on node
//        torpedoNode.removeAllActions()
//
//        //begin transaction of animation mention properties to be animated in middle of begin and commit
//        SCNTransaction.begin()
//
//        //Duration of animation in seconds
//        SCNTransaction.animationDuration = 2
//
//        // setting transparency of node
//        torpedoNode.opacity = 0
//
//        //Commiting animation
//        SCNTransaction.commit()
//
 
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
}
