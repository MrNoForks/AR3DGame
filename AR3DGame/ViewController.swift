//
//  ViewController.swift
//  AR3DGame
//
//  Created by Boppo on 08/05/19.
//  Copyright © 2019 Boppo. All rights reserved.
//
//https://code.tutsplus.com/tutorials/combining-the-power-of-spritekit-and-scenekit--cms-24049
import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController,ARSCNViewDelegate ,SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var torpedo : SCNNode?
    
    let spaceShipCategory  = 2
    
    let torpedoCategory  = 1
    
    private var virtualObjectNode = ModelLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //sceneView.debugOptions = .showPhysicsShapes
        
        // Create a new scene
      //  let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
     //   sceneView.scene = scene
        
        virtualObjectNode.loadModel(modelName: "UFO_A", positionX: 0, positionY: 0, positionZ: -0.7, modelSize: 0.05)
    
        virtualObjectNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: virtualObjectNode, options: [.scale:0.0005]))
        
      //  print( SCNPhysicsShape(node: virtualObjectNode, options: [.scale:0.0005]))
        
     //   virtualObjectNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: virtualObjectNode, options: nil))
        
        virtualObjectNode.name = "spaceship"
        
        virtualObjectNode.physicsBody?.categoryBitMask = spaceShipCategory
        
        virtualObjectNode.physicsBody?.contactTestBitMask = torpedoCategory
        
        virtualObjectNode.physicsBody?.collisionBitMask = torpedoCategory
        

        
        sceneView.scene.rootNode.addChildNode(virtualObjectNode)
        
        sceneView.scene.physicsWorld.gravity = SCNVector3(0,0,0)
        
        sceneView.scene.physicsWorld.contactDelegate = self
        
        let shooterButton = UIButton(frame: CGRect(x: 20, y: 20, width: 200, height: 70))
        
        shooterButton.setTitle("Shoot", for: .normal)
        
        shooterButton.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        
        view.addSubview(shooterButton)
        
        view.bringSubviewToFront(shooterButton)
        
        shooterButton.isHidden = true
        
    //    print(virtualObjectNode.physicsBody?.categoryBitMask)
        
    }
    
    func torepdo() {
        
        sceneView.scene.rootNode.runAction(SCNAction.playAudio(SCNAudioSource(named: "torpedo.mp3")!, waitForCompletion: false))
        
     //   SCNAction.playAudio(<#T##source: SCNAudioSource##SCNAudioSource#>, waitForCompletion: <#T##Bool#>)
        
        torpedo = SCNNode(geometry: SCNSphere(radius: 0.05))
        
        torpedo!.geometry?.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        
        guard let pointOfView = sceneView.pointOfView else { return}
        
        let transform = pointOfView.simdTransform
        let myPosInWorldSpace = simd_make_float4(0,0,-2,1)
        let myPosInCamSpace = simd_mul(transform,myPosInWorldSpace)
        
        torpedo?.name = "torpedo"
        torpedo?.position = pointOfView.position
        
        torpedo?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: torpedo!, options: nil))
        
        torpedo?.physicsBody?.categoryBitMask = torpedoCategory
        
        torpedo?.physicsBody?.contactTestBitMask = spaceShipCategory
        
        torpedo?.physicsBody?.collisionBitMask = spaceShipCategory
        

        
        
        print(torpedo!.categoryBitMask )
        
        sceneView.scene.rootNode.addChildNode(torpedo!)
        
        var actionArray = [SCNAction]()

        actionArray.append(SCNAction.move(to: SCNVector3(myPosInCamSpace.x,myPosInCamSpace.y,myPosInCamSpace.z), duration: 1))
       // actionArray.append(SCNAction.move(to: SCNVector3(0,0,-0.7), duration: 1))
        actionArray.append(SCNAction.removeFromParentNode())

        torpedo?.runAction(SCNAction.sequence(actionArray))
        
    }
    
    
    @objc func buttonClicked(sender:UIButton){
        print("hi")

        torepdo()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        torepdo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    
    
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        

        
//        if contact.nodeA.name == "spaceship"{
//            spaceshipNode = contact.nodeA
//            torpedoNode = contact.nodeB
//        } else{
//            torpedoNode = contact.nodeA
//            spaceshipNode = contact.nodeB
//        }
        
       
        if(contact.nodeA.physicsBody?.contactTestBitMask == spaceShipCategory && contact.nodeB.physicsBody?.contactTestBitMask == torpedoCategory){
            print("Node A is a spaceShipCategory and Node B is a torpedoCategory")
             torpedoDidCollideWithAlien(torpedoNode: contact.nodeA , spaceshipNode: contact.nodeB)
        }
        else if (contact.nodeA.physicsBody?.contactTestBitMask == torpedoCategory && contact.nodeB.physicsBody?.contactTestBitMask == spaceShipCategory){
            torpedoDidCollideWithAlien(torpedoNode: contact.nodeB , spaceshipNode: contact.nodeA)
        }
        
//        if (torpedoNode.categoryBitMask & 2) != 0 && (spaceshipNode.categoryBitMask & 1) != 0{
//            print("collide")
//        }
    
//        if (firstBody.categoryBitMask & torpedoCategory) != 0 && (secondBody.categoryBitMask & spaceShipCategory) != 0{
//             print("detected buddy")
//            torpedoDidCollideWithAlien(torpedoNode: firstBody , spaceshipNode: secondBody)
//        }
        
        
        
    }
    
    func torpedoDidCollideWithAlien(torpedoNode : SCNNode? , spaceshipNode : SCNNode?){
         guard let torpedoNode = torpedoNode ,let spaceshipNode = spaceshipNode else{return}
        
                sceneView.scene.rootNode.runAction(SCNAction.playAudio(SCNAudioSource(named: "explosion.mp3")!, waitForCompletion: false))
        
        let explosionNode = SCNNode()
        
        let explosion = SCNParticleSystem(named: "FireExplosion.scnp", inDirectory: nil)
        
        
        
        explosionNode.addParticleSystem(explosion!)
        
        explosionNode.position = spaceshipNode.presentation.position
      //  spaceshipNode.addParticleSystem(explosion!)
       // torpedoNode.removeFromParentNode()
        sceneView.scene.rootNode.addChildNode(explosionNode)
        
        torpedoNode.removeFromParentNode()
        spaceshipNode.removeFromParentNode()
        
        
        
        explosionNode.runAction(SCNAction.wait(duration: 1)) { [unowned self] in
            explosionNode.removeFromParentNode()
            
            
             let xPos = self.randomPosition(lower: -1.5, upper: 1.5)
            self.virtualObjectNode.position = self.virtualObjectNode.presentation.position
            self.virtualObjectNode.position = SCNVector3(x: xPos, y: 0, z: -0.7)
            
            self.sceneView.scene.rootNode.addChildNode(self.virtualObjectNode)
            
            
            
        }
//
    }
    
    func randomPosition(lower : Float , upper : Float) -> Float{
        return Float(arc4random())/Float(UInt32.max) * (lower - upper) + upper
    }
    
    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    
}
