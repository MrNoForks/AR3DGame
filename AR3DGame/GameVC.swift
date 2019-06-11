//
//  GameVC.swift
//  AR3DGame
//
//  Created by Boppo Technologies on 20/05/19.
//  Copyright © 2019 Boppo. All rights reserved.
//https://code.tutsplus.com/tutorials/combining-the-power-of-spritekit-and-scenekit--cms-24049

import UIKit
import ARKit

class GameVC: UIViewController ,ARSCNViewDelegate, SCNPhysicsContactDelegate{
    
    // SpaceShipNode
    var spaceShipNode : SCNNode?
    
    var torpedoCollidedSpaceship : Bool = false
    
    // TorpedoNode
    var torpedoNode  : SCNNode?
    
    // ExplosionNode
    //   var explosionNode : SCNNode?
    
     var smokeyNode : SCNNode = {
        let particleNode = SCNNode()
        particleNode.addParticleSystem(SCNParticleSystem(named: "smkey", inDirectory: nil)!)
        particleNode.position = SCNVector3(x: -1, y: -0.5, z: 0)
        return particleNode
    }()
    
    
    var alertVisible : Bool = false
    
    @IBOutlet weak var sceneView: ARSCNView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
      //  spaceShipNode = createSpaceShipNode()

        //Setting  gravity to 0 from default(which is 9.8)
        sceneView.scene.physicsWorld.gravity = SCNVector3Zero
        
        //Setting that VC I am delegate for physicContact
        sceneView.scene.physicsWorld.contactDelegate = self
        
        //sceneView.debugOptions = .showPhysicsShapes
        
        
        sceneView.delegate = self
        
        sceneView.showsStatistics = true
        
        
        
        let button = UIButton()
        button.setTitle("add", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        button.frame = CGRect(x: 70, y: 120, width: 50, height: 50)
        button.addTarget(self, action: #selector(addObject(sender:)), for: .touchUpInside)
        //  2 collision
        //     view.addSubview(button)
        
        let button2 = UIButton()
        button2.setTitle("remove", for: .normal)
        button2.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        button2.frame = CGRect(x: 70, y: 70, width: 50, height: 50)
        button2.addTarget(self, action: #selector(removeObject(sender:)), for: .touchUpInside)
      //  view.addSubview(button2)
        
       // view.bringSubviewToFront(button)
       // view.bringSubviewToFront(button2)
        
    }
    var a : Float = 0
    @objc func addObject(sender:UIButton){
        print("hi")
//        spaceShipNode?.position.x = a + 0.5
//        sceneView.scene.rootNode.addChildNode((spaceShipNode?.clone())!)
        shootCube()
    }

    @objc func removeObject(sender:UIButton){
        print("hi")
        spaceShipNode?.position.x = a + 0.5
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        
    }
    
    
    //Configuring Setting of AR
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        
        guard let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "ARPhotos", bundle: nil) else {print("No images"); return}
        
        configuration.detectionImages = trackedImages
        
        configuration.maximumNumberOfTrackedImages = 1
        
        sceneView.session.run(configuration, options: [.resetTracking,.removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        
    }
    
    ///Protocol method of SCNPhysics for Contact trigger when contact is detected
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        if (contact.nodeA.physicsBody?.categoryBitMask == BitMask.spaceShipCategory && contact.nodeB.physicsBody?.categoryBitMask == BitMask.torpedoCategory){
            
            torpedoDidCollideWithAlien(torpedoNode: contact.nodeB, spaceShipNode: contact.nodeA, explosionNode: createExplosionNode())
            
        }
        else if(contact.nodeA.physicsBody?.categoryBitMask == BitMask.torpedoCategory && contact.nodeB.physicsBody?.categoryBitMask == BitMask.spaceShipCategory){
            
            torpedoDidCollideWithAlien(torpedoNode: contact.nodeA, spaceShipNode: contact.nodeB, explosionNode: createExplosionNode())
        }
        
        else if(contact.nodeA.physicsBody?.categoryBitMask == BitMask.brick && contact.nodeB.physicsBody?.categoryBitMask == BitMask.spaceShipCategory){
            
            print("Brick hits space")
        }
        
        else if(contact.nodeA.physicsBody?.categoryBitMask == BitMask.spaceShipCategory && contact.nodeB.physicsBody?.categoryBitMask == BitMask.brick){
            
            print("Space hits Brick")
        }
        
    }
    
    //    override var prefersStatusBarHidden: Bool{
    //        return false
    //    }
    
    
    // Triggered when user taps screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let firstTouch = touches.first{
            
            let pos = getCameraPosition()
            
            let dir = getDirection(for: firstTouch.location(in: sceneView), in: sceneView).normalized
            
            fireTorpedo(at : SCNVector3(pos.x + dir.x, pos.y + dir.y, pos.z + dir.z))
            
            print(sceneView.scene.rootNode.childNodes.count)
            
        }

    }
    
}
