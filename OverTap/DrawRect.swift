//
//  DrawRect.swift
//  OverTap
//
//  Created by William Caruso on 11/22/16.
//  Copyright © 2016 wcaruso. All rights reserved.
//

import UIKit

class DrawRect: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
         Drawing code
    }
    */
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.move(to: CGPoint(x: 100, y: 100))
        context?.addLine(to: CGPoint(x: 150, y: 150))
        context?.addLine(to: CGPoint(x: 100, y: 200))
        context?.addLine(to: CGPoint(x: 50, y: 150))
        context?.addLine(to: CGPoint(x: 100, y: 100))
        context?.setFillColor(UIColor.green.cgColor)
        context?.fillPath()
    }

}
