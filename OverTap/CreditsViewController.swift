//
//  CreditsViewController.swift
//  OverTap
//
//  Created by William Caruso on 12/1/16.
//  Copyright © 2016 wcaruso. All rights reserved.
//

import UIKit

class CreditsViewController: UIViewController {
    
    // MARK: - IBActions

    @IBAction func ShareButton(_ sender: Any) {
        let message = "Share OverTap! Checkout the project at "

        if let link = NSURL(string: "https://github.com/williamcaruso/OverTap")
        {
            let objectsToShare = [message,link] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func BackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - View Controllers
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
