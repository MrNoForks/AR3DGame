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
        
        //extracting Node from the Scene
        for child in virtualObjectScene.rootNode.childNodes{
            addChildNode(child)
        }
        
        // adding the wrapperNode to MainNode
       // addChildNode(wrapperNode)
    }
    
    
    func loadModel(modelName : String){
        
        guard let virtualObjectScene = SCNScene(named: modelName) else {return}
        
        for child in virtualObjectScene.rootNode.childNodes{
            addChildNode(child)
        }

    }
    
    func loadModel(modelName : String,positionX x : Float,positionY y : Float,positionZ z : Float,modelSize size : Float,appearanceAnimation : Bool = false,withDuration time : Double = 5){
        
        guard let virtualObjectScene = SCNScene(named: modelName) else {return}

        
        for child in virtualObjectScene.rootNode.childNodes{
            addChildNode(child)
        }
        position = SCNVector3(x: x, y: y, z: z)
        

        if appearanceAnimation{
            
            scale = SCNVector3(x: size/2, y: size/2, z: size/2)
            
            let appearanceAction = SCNAction.scale(to: CGFloat(size), duration: time)
            
            appearanceAction.timingMode = .easeOut
            
            runAction(appearanceAction)
            
        }
        else{
          scale = SCNVector3(x: size, y: size, z: size)
        }
        
    }
}
