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
    
    @IBOutlet weak var sceneView: ARSCNView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
  //      spaceShipNode = createSpaceShipNode()
        
       //   torpedoNode   = createTorpedoNode()
        
        //   explosionNode = createExplosionNode()
        
        
        if let spaceShipNode = createSpaceShipNode() {
            
            sceneView.scene.rootNode.addChildNode(spaceShipNode)
            
            //Setting  gravity to 0 from default(which is 9.8)
            sceneView.scene.physicsWorld.gravity = SCNVector3Zero
            
            //Setting that VC I am delegate for physicContact
            sceneView.scene.physicsWorld.contactDelegate = self
            
                //sceneView.debugOptions = .showPhysicsShapes
            
            
            sceneView.delegate = self
        }
        
        sceneView.showsStatistics = true
        
        
        
        let button = UIButton()
        button.setTitle("add", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        button.frame = CGRect(x: 70, y: 120, width: 50, height: 50)
        button.addTarget(self, action: #selector(addObject(sender:)), for: .touchUpInside)
       // view.addSubview(button)
        
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
        print(spaceShipNode?.position)
        node.physicsBody?.applyForce((spaceShipNode?.presentation.position)!, asImpulse: true)
        
        node.runAction(SCNAction.wait(duration: 5)){
            [unowned node] in
            node.removeFromParentNode()
        }
        
        
        
        
        
        
        
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
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let camera = sceneView.pointOfView{
            
            let distance = length( camera.simdTransform.columns.3 - sceneView.scene.rootNode.simdTransform.columns.3)
            //  print(camera.simdTransform.columns.3 - node!.simdTransform.columns.3)
            // label2.text = " distance is \(length(camera.simdTransform.columns.3 - node!.simdTransform.columns.3))"
            DispatchQueue.main.async {

                
                if distance > 2 {
                    let alert = UIAlertController(title: "Distance", message: "Try moving back to where you initiated your game from", preferredStyle: .alert)
                    
                    
                    let uiImageAlertAction = UIAlertAction(title: "", style: .default)
                    
                    let image = #imageLiteral(resourceName: "ARWarning.jpg")
                    
                    let maxsize = CGSize(width: 245, height: 300)
                    
                    let scaleSize = CGSize(width: 245, height: 245/image.size.width*image.size.height)
                    let reSizedImage = image.resize(with: scaleSize)
                    
                    uiImageAlertAction.setValue(reSizedImage?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), forKey: "Image")
                    
                    alert.addAction(uiImageAlertAction)
                    
                    
                    let okAlert = UIAlertAction(title: "Ok", style: .default)
                    
                    
                    alert.addAction(okAlert)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            
        }
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
