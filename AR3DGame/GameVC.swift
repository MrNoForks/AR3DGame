//
//  GameVC.swift
//  AR3DGame
//
//  Created by Boppo Technologies on 20/05/19.
//  Copyright © 2019 Boppo. All rights reserved.
//https://code.tutsplus.com/tutorials/combining-the-power-of-spritekit-and-scenekit--cms-24049

import UIKit
import ARKit

class GameVC: UIViewController , SCNPhysicsContactDelegate{
    
    // SpaceShipNode
    var spaceShipNode : SCNNode?
    
    // TorpedoNode
    var torpedoNode  : SCNNode?
    
    // ExplosionNode
    //   var explosionNode : SCNNode?
    
    @IBOutlet weak var sceneView: ARSCNView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spaceShipNode = createSpaceShipNode()
        
        //  torpedoNode   = createTorpedoNode()
        
        //   explosionNode = createExplosionNode()
        
        
        if let spaceShipNode = spaceShipNode {
            
            sceneView.scene.rootNode.addChildNode(spaceShipNode)
            
            //Setting  gravity to 0 from default(which is 9.8)
            sceneView.scene.physicsWorld.gravity = SCNVector3Zero
            
            //Setting that VC I am delegate for physicContact
            sceneView.scene.physicsWorld.contactDelegate = self
            
            //    sceneView.debugOptions = .showPhysicsShapes
            
        }
        
        sceneView.showsStatistics = true
        
        
        
        let button = UIButton()
        button.setTitle("add", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        button.frame = CGRect(x: 70, y: 120, width: 50, height: 50)
        button.addTarget(self, action: #selector(addObject(sender:)), for: .touchUpInside)
        view.addSubview(button)
        
        let button2 = UIButton()
        button2.setTitle("remove", for: .normal)
        button2.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        button2.frame = CGRect(x: 70, y: 70, width: 50, height: 50)
        button2.addTarget(self, action: #selector(removeObject(sender:)), for: .touchUpInside)
        view.addSubview(button2)
        
        view.bringSubviewToFront(button)
        view.bringSubviewToFront(button2)
        
    }
    var a : Float = 0
    @objc func addObject(sender:UIButton){
        print("hi")
        spaceShipNode?.position.x = a + 0.5
        sceneView.scene.rootNode.addChildNode((spaceShipNode?.clone())!)
    }
    
    @objc func removeObject(sender:UIButton){
        print("hi")
        spaceShipNode?.position.x = a + 0.5
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
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
        
    }
    
    //    override var prefersStatusBarHidden: Bool{
    //        return false
    //    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        fireTorpedo()
        
        print(sceneView.scene.rootNode.childNodes.count)
        
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
