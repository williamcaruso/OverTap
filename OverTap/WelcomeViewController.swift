//
//  WelcomeViewController.swift
//  OverTap
//
//  Created by William Caruso on 12/1/16.
//  Copyright © 2016 wcaruso. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBAction func BeginButton(_ sender: Any) {
        self.performSegue(withIdentifier: "Begin", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
