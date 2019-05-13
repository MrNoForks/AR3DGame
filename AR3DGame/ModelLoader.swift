//
//  ModelLoader.swift
//  3DR&D
//
//  Created by boppo on 3/5/19.
//  Copyright © 2019 boppo. All rights reserved.
//

import ARKit

class ModelLoader: SCNNode {
    func loadModel(){
        
        //loading model from directory
        guard let virtualObjectScene = SCNScene(named: "art.scnassets/ship.scn") else{ return }
        
        //creating a wrapperNode for scene
        let wrapperNode = SCNNode()
        
        //extracting Node from the Scene
        for child in virtualObjectScene.rootNode.childNodes{
            wrapperNode.addChildNode(child)
        }
        
        // adding the wrapperNode to MainNode
        self.addChildNode(wrapperNode)
    }
    
    
    func loadModel(modelName : String){
        
        guard let virtualObjectScene = SCNScene(named: modelName) else {return}
        
        let wrapperNode = SCNNode()
        
        for child in virtualObjectScene.rootNode.childNodes{
            wrapperNode.addChildNode(child)
        }
        
        self.addChildNode(wrapperNode)
    }
    
    func loadModel(modelName : String,positionX x : Float,positionY y : Float,positionZ z : Float,modelSize size : Float,appearanceAnimation : Bool = false,withDuration time : Double = 5){
        
        guard let virtualObjectScene = SCNScene(named: modelName) else {return}
        
        let wrapperNode = SCNNode()
        
        for child in virtualObjectScene.rootNode.childNodes{
            wrapperNode.addChildNode(child)
        }
        
        self.addChildNode(wrapperNode)
        
        self.position = SCNVector3(x: x, y: y, z: z)
        
        self.scale = SCNVector3(x: size/2, y: size/2, z: size/2)
        
        
        
        if appearanceAnimation{
            let appearanceAction = SCNAction.scale(to: CGFloat(size), duration: time)
            
            appearanceAction.timingMode = .easeOut
            
            self.runAction(appearanceAction)
            
        }
        
    }
}
