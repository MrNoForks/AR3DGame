//
//  GameVC.swift
//  AR3DGame
//
//  Created by Boppo Technologies on 20/05/19.
//  Copyright © 2019 Boppo. All rights reserved.
//
//https://code.tutsplus.com/tutorials/combining-the-power-of-spritekit-and-scenekit--cms-24049
import ARKit

class GameVC: UIViewController , ARSCNViewDelegate , SCNPhysicsContactDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var torpedoNode = ModelLoader()
    
    var spaceShipNode = ModelLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        setupSpaceShipNode()
        
        sceneView.scene.rootNode.addChildNode(spaceShipNode)
        
        sceneView.scene.physicsWorld.gravity = SCNVector3Zero
        
        sceneView.scene.physicsWorld.contactDelegate = self
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Run the view's session
        sceneView.session.run(ARWorldTrackingConfiguration())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    

    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        if(contact.nodeA.physicsBody?.contactTestBitMask == BitMask.spaceShipCategory && contact.nodeB.physicsBody?.contactTestBitMask == BitMask.torpedoCategory){
            print("Node A is a torpedoCategory and Node B is a spaceShipCategory")
            torpedoDidCollideWithAlien(torpedoNode: contact.nodeA , spaceshipNode: contact.nodeB)
        }
        else if (contact.nodeA.physicsBody?.contactTestBitMask == BitMask.torpedoCategory && contact.nodeB.physicsBody?.contactTestBitMask == BitMask.spaceShipCategory){
             print("Node A is a spaceShipCategory and Node B is a torpedoCategory")
            torpedoDidCollideWithAlien(torpedoNode: contact.nodeB , spaceshipNode: contact.nodeA)
        }
        
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        fireTorepdo()
        
    }
    
}
