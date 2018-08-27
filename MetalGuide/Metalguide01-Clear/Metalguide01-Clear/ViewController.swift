//
//  ViewController.swift
//  Metalguide01-ClearScreen
//
//  Created by meitu on 2018/8/27.
//  Copyright © 2018年 meitu. All rights reserved.
//

import UIKit
import  MetalKit

class ViewController: UIViewController {
    
    var render: Renderer? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mtkView = MTKView.init(frame: view.bounds)
        
        view .addSubview(mtkView)
        
        render = Renderer.init(mtkView: mtkView)
    }
}

