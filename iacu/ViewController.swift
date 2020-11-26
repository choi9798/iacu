//
//  ViewController.swift
//  iacu
//
//  Created by mac on 13/12/2017.
//  Copyright © 2017 lens. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var diagnose_btn: UIButton!
    @IBOutlet weak var learn_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //learn_btn.layer.cornerRadius = 5
        //self.diagnose_btn.layer.cornerRadius = 5
        navigationController?.navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

