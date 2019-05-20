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

extension GameVC
{
   
    func randomPosition(lower : Float , upper : Float) -> Float{
        return Float(arc4random())/Float(UInt32.max) * (lower - upper) + upper
    }
    
    //Setting Up SpaceNode
    func setupSpaceShipNode(){
        
        spaceShipNode.loadModel(modelName: "UFO_A.scnassets/UFO_A", positionX: 0, positionY: 0, positionZ: -0.7, modelSize: 0.025)
        
        
        setupPhysicsBody(forNode: spaceShipNode, name: "SpaceShip", physicBodyType: .static, categoryBitMask: BitMask.spaceShipCategory, collisionBitMask: 0, contactBitMask: BitMask.torpedoCategory)
        
    }
    
    func fireTorepdo() {
       
        print("Number of nodes \(sceneView.scene.rootNode.childNodes.count)")
        
        sceneView.scene.rootNode.runAction(SCNAction.playAudio(SCNAudioSource(named: "torpedo.mp3")!, waitForCompletion: false))
        
        torpedoNode = ModelLoader()
        
        torpedoNode.loadModel(modelName : "Torpedo.scnassets/FiredScene.scn")
        
        guard let pointOfView = sceneView.pointOfView else { return}
        
        let transform = pointOfView.simdTransform
        let myPosInWorldSpace = simd_make_float4(0,0,-2,1)
        let myPosInCamSpace = simd_mul(transform,myPosInWorldSpace)
        
        // pointOfView.position is position of ARCamera in scene
        torpedoNode.position = pointOfView.position
        
        
        setupPhysicsBody(forNode: torpedoNode, name: "Torpedo", physicBodyType: .static, categoryBitMask: BitMask.torpedoCategory, collisionBitMask: 0, contactBitMask: BitMask.spaceShipCategory)
        
        // Adding torrpedoNode
        sceneView.scene.rootNode.addChildNode(torpedoNode)
        
        var actionArray = [SCNAction]()
        
        //Moving torpedo in from current location to specified location
        actionArray.append(SCNAction.move(to: SCNVector3(myPosInCamSpace.x,myPosInCamSpace.y,myPosInCamSpace.z), duration: 3))
        
        // actionArray.append(SCNAction.move(to: SCNVector3(0,0,-0.7), duration: 1))
        actionArray.append(SCNAction.removeFromParentNode())
        
        //running all sequence of actions
        torpedoNode.runAction(SCNAction.sequence(actionArray))
        
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
    
    func torpedoDidCollideWithAlien(torpedoNode : SCNNode? , spaceshipNode : SCNNode?){
        guard let torpedoNode = torpedoNode ,let spaceshipNode = spaceshipNode else{return}
        
        sceneView.scene.rootNode.runAction(SCNAction.playAudio(SCNAudioSource(named: "explosion.mp3")!, waitForCompletion: false))
        
        torpedoNode.runAction(SCNAction.fadeOut(duration: 0.15)){ [unowned self] in
            
            
            let explosionNode = SCNNode()
            
            let explosion = SCNParticleSystem(named: "Explosion.scnassets/FireExplosion.scnp", inDirectory: nil)
            
            explosionNode.addParticleSystem(explosion!)
            
            explosionNode.position = spaceshipNode.presentation.position
            
            self.sceneView.scene.rootNode.addChildNode(explosionNode)
            
            torpedoNode.removeFromParentNode()
            spaceshipNode.removeFromParentNode()
            
            explosionNode.runAction(SCNAction.wait(duration: 1)) { [unowned self] in
                explosionNode.removeFromParentNode()
                
                let xPos = self.randomPosition(lower: -1.5, upper: 1.5)
                self.spaceShipNode.position = self.spaceShipNode.presentation.position
                self.spaceShipNode.position = SCNVector3(x: xPos, y: 0, z: -0.7)
                
                self.sceneView.scene.rootNode.addChildNode(self.spaceShipNode)
                
            }
        }
    }
    
}


