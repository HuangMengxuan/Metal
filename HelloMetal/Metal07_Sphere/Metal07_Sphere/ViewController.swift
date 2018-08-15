//
//  ViewController.swift
//  Metal07_Sphere
//
//  Created by meitu on 2018/8/15.
//  Copyright © 2018年 meitu. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mtkView: MTKView!
    @IBOutlet weak var xSwitch: UISwitch!
    @IBOutlet weak var ySwitch: UISwitch!
    @IBOutlet weak var zSwitch: UISwitch!
    
    var render: Renderer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        render = Renderer.init(mtkView: mtkView)
        render?.needRotateX = xSwitch.isOn
        render?.needRotateY = ySwitch.isOn
        render?.needRotateZ = zSwitch.isOn
    }
    
    @IBAction func actionXSwitch(_ sender: UISwitch) {
        render?.needRotateX = sender.isOn
    }
    
    @IBAction func actionYSwitch(_ sender: UISwitch) {
        render?.needRotateY = sender.isOn
    }
    
    @IBAction func actionZSwitch(_ sender: UISwitch) {
        render?.needRotateZ = sender.isOn
    }
}

