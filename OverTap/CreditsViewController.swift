//
//  CreditsViewController.swift
//  OverTap
//
//  Created by William Caruso on 12/1/16.
//  Copyright © 2016 wcaruso. All rights reserved.
//

import UIKit

class CreditsViewController: UIViewController {
    
    // MARK: - Variables

    @IBOutlet weak var creditsLabel: UILabel!
    
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
        let bulletPoint: String = "\u{2022}"

        let line1 = "OverTap was developed by William Caruso for the Siri Advanced Development Group at Apple Inc."
        let line2 = "\nWhen two shapes overlap the user is alerted in three ways:"
        let bullet1 = "\(bulletPoint) The clipping (intersection of the shapes) is drawn in a blend of the intersecting shapes colors"
        let bullet2 = "\(bulletPoint) The 'Intersection' label appears on the top"
        let bullet3 = "\(bulletPoint) Haptic feedback is provided to the user"
        let line3 = "\nOpen-Source Libraries"
        let bullet4 = "\(bulletPoint) RSClipperWrapper - A small and simple wrapper for Clipper - an open source freeware library for clipping polygons"
        let bullet5 = "\(bulletPoint) KCFloatingActionButton - Simple Floating Action Button for iOS"

        
        let strings = [line1, line2, bullet1, bullet2, bullet3, line3, bullet4, bullet5]
        
        var fullString = ""
        
        for string: String in strings {
            let formattedString: String = "\(string)\n"
            
            fullString = fullString + formattedString
        }
        
        creditsLabel.text = fullString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
