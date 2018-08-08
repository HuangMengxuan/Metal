//
//  ViewController.swift
//  Metal02_meetTexture
//
//  Created by 黄梦轩 on 2018/8/8.
//  Copyright © 2018年 黄梦轩. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
    
    private var renderer: Renderer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mtkView = self.view as! MTKView
        
        renderer = Renderer.init(mtkView: mtkView)
        if renderer == nil {
            print("Renderer failed initializetion!")
            return
        }
    }
}

