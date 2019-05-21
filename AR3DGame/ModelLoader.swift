//
//  ModelLoader.swift
//  AR3DGame
//
//  Created by Boppo Technologies on 20/05/19.
//  Copyright © 2019 Boppo. All rights reserved.
//

import SceneKit

class ModelLoader : SCNNode{
    
    func loadModel(modelName : String)->SCNNode?{
        
        guard let model = SCNScene(named: modelName) else { return nil}
        
        for child in model.rootNode.childNodes{
            addChildNode(child)
        }
        
        return self
        
    }
    
    func loadModel(modelName : String,positionX x : Float,positionY y : Float,positionZ z : Float,modelSize size : Float,appearanceAnimation : Bool = false,withDuration time : Double = 5) -> SCNNode?{
        
        guard let virtualObjectScene = SCNScene(named: modelName) else {return nil}
        
        
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
        
        return self
        
    }
    
}
