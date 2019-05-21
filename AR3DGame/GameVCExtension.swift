//
//  GameVCExtension.swift
//  AR3DGame
//
//  Created by Boppo Technologies on 20/05/19.
//  Copyright © 2019 Boppo. All rights reserved.
//


import ARKit


struct BitMask {
    
    static let torpedoCategory : Int = 0x1
    static let spaceShipCategory : Int = 0x1 << 1
    static let brick : Int  = 0x1 << 2
    
}

extension GameVC{
    
    func createSpaceShipNode() -> SCNNode?{
        if let node = ModelLoader().loadModel(modelName: "UFO_A", positionX: 0, positionY: 0, positionZ: -0.7, modelSize: 0.025){
            
            //CollisionBitMask 0 means Idc about collision as we are gonna handle it
            //we dont want to simulate any collision for the node
            setupPhysicsBody(forNode: node, name: "SpaceShip", physicBodyType: .static, categoryBitMask: BitMask.spaceShipCategory, collisionBitMask: BitMask.torpedoCategory, contactBitMask: BitMask.torpedoCategory)
            
            return node
        }
        return nil
    }
    
    func createTorpedoNode() -> SCNNode?{
        if let node =  ModelLoader().loadModel(modelName: "FiredScene.scn"){
            
            setupPhysicsBody(forNode: node, name: "Torpedo", physicBodyType: .static, categoryBitMask: BitMask.torpedoCategory, collisionBitMask: BitMask.spaceShipCategory, contactBitMask: BitMask.spaceShipCategory)
            
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
        node.physicsBody = SCNPhysicsBody(type: type, shape: SCNPhysicsShape(node: node, options: [.type: SCNPhysicsShape.ShapeType.boundingBox]))
        
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
        guard let torpedoNode = torpedoNode else {return}
        
        let torpedo = torpedoNode.clone()
        
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
        
        //Creating a blank SCNACtion Array to hold sequence of actions
        var actionArray = [SCNAction]()
        
        //Moving torpedo in from current location to specified location
        actionArray.append(SCNAction.move(to: SCNVector3(x: newPosInWorldSpace.x, y: newPosInWorldSpace.y, z: newPosInWorldSpace.z), duration: 3))
        
        //Removing torpedo from scene
        actionArray.append(SCNAction.removeFromParentNode())
        
        //running all sequence of actions
        torpedo.runAction(SCNAction.sequence(actionArray))
        
        print("Nodes in scene are \(sceneView.scene.rootNode.childNodes.count)")
        
    }
    
    //For collision between torpedo and spaceNode
    func torpedoDidCollideWithAlien(torpedoNode : SCNNode?, spaceShipNode : SCNNode?,explosionNode : SCNNode?){
        
        //Checking if nodes ain't empty else return to avoid exceptions
        guard let torpedoNode = torpedoNode ,let spaceShipNode = spaceShipNode , let explosionNode = explosionNode else{return}
        
        // For playing audio of explosion
        sceneView.scene.rootNode.runAction(SCNAction.playAudio(SCNAudioSource(named: "explosion.mp3")!, waitForCompletion: false))
        
        explosionNode.position = spaceShipNode.presentation.position
        
        self.sceneView.scene.rootNode.addChildNode(explosionNode)
        
        var torpedoNodeActionArray = [SCNAction]()
        
        torpedoNodeActionArray.append(SCNAction.fadeOut(duration: 0.15))
        
        torpedoNodeActionArray.append(SCNAction.removeFromParentNode())
        
        torpedoNode.runAction(SCNAction.sequence(torpedoNodeActionArray))
        
        spaceShipNode.removeFromParentNode()
        
        var explosionNodeActionArray = [SCNAction]()
        
        explosionNodeActionArray.append(SCNAction.wait(duration: 1))
        
        explosionNodeActionArray.append(SCNAction.removeFromParentNode())
        
        explosionNode.runAction(SCNAction.sequence(explosionNodeActionArray))
        
        //Random number from -1.5 to 1.5
        let xPos = randomPosition(lower: -1.5, upper: 1.5)
        
        if let spaceShipNode = self.spaceShipNode{
            
            spaceShipNode.position.x = xPos
            
            sceneView.scene.rootNode.addChildNode(spaceShipNode)
        }
        
        
        
        
    }
    
}
