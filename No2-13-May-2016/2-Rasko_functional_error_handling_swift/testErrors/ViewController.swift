//
//  ViewController.swift
//  testErrors
//
//  Created by Rasko Gojkovic on 5/13/16.
//  Copyright © 2016 Plantronics. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let testE = TestErrorExc()
        let testR = TestErrorRes()
        testE.doTest()
        testR.doTest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

