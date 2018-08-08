//
//  ViewController.swift
//  Metal01_Triangle
//
//  Created by meitu on 2018/7/31.
//  Copyright © 2018年 meitu. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
    
//    var mtkView:MTKView! = nil
//    var renderer:HMXRenderer! = nil
    
    public var renderer: Renderer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mtkView = self.view as! MTKView
        
        renderer = Renderer.init(mtkView: mtkView)
        if renderer == nil {
            print("Renderer failed initializetion!")
            return
        }
        
//        mtkView = self.view as! MTKView
//
//        mtkView.preferredFramesPerSecond = 60
//
//        mtkView.device = MTLCreateSystemDefaultDevice()
//        if (mtkView.device == nil) {
//            print("Metal is not supported on this device!")
//            return
//        }
//
//        renderer = HMXRenderer.init(mtkView: mtkView)
//        if renderer == nil {
//            print("Renderer failed initializetion!")
//            return
//        }
    }
    
}

