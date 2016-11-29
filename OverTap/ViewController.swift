//
//  ViewController.swift
//  OverTap
//
//  Created by William Caruso on 11/22/16.
//  Copyright © 2016 wcaruso. All rights reserved.
//

import UIKit
import RSClipperWrapper

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var layerToRemove:CAShapeLayer = CAShapeLayer()
    
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    
    func handleTap(_ recognizer:UITapGestureRecognizer) {
        if let view = recognizer.view {
            switch view.backgroundColor! {
            case UIColor.red:
                view.backgroundColor = UIColor.orange
            case UIColor.orange:
                view.backgroundColor = UIColor.yellow
            case UIColor.yellow:
                view.backgroundColor = UIColor.green
            case UIColor.green:
                view.backgroundColor = UIColor.blue
            case UIColor.blue:
                view.backgroundColor = UIColor.purple
            default:
                view.backgroundColor = UIColor.red
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let recognizer1 = UITapGestureRecognizer(target: self, action:#selector(handleTap(_:)))
        recognizer1.delegate = self
        view1.addGestureRecognizer(recognizer1)
        
        let recognizer2 = UITapGestureRecognizer(target: self, action:#selector(handleTap(_:)))
        recognizer2.delegate = self
        view2.addGestureRecognizer(recognizer2)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint(), in: self.view)
        
        if recognizer.state == UIGestureRecognizerState.ended {
            let velocity = recognizer.velocity(in: self.view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 200
            print("magnitude: \(magnitude), slideMultiplier: \(slideMultiplier)")
            
            let slideFactor = 0.1 * slideMultiplier     //Increase for more of a slide
            var finalPoint = CGPoint(x:recognizer.view!.center.x + (velocity.x * slideFactor),
                                     y:recognizer.view!.center.y + (velocity.y * slideFactor))
            finalPoint.x = min(max(finalPoint.x, 0), self.view.bounds.size.width)
            finalPoint.y = min(max(finalPoint.y, 0), self.view.bounds.size.height)
            
            UIView.animate(withDuration: Double(slideFactor * 2),
                           delay: 0,
                           options: UIViewAnimationOptions.curveEaseOut,
                           animations: {recognizer.view!.center = finalPoint },
                           completion: nil)
        }
        
        if (view1.frame.intersects(view2.frame)) {
            drawIntersection()
        } else {
            // remove the old sublayer
            if (layerToRemove.superlayer != nil) {
                layerToRemove.removeFromSuperlayer()
            }
        }
    }
    
    @IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
        
        if (view1.frame.intersects(view2.frame)) {
            drawIntersection()
        } else {
            // remove the old sublayer
            if (layerToRemove.superlayer != nil) {
                layerToRemove.removeFromSuperlayer()
            }
        }
    }
    
    @IBAction func handleRotate(recognizer : UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
        
        if (view1.frame.intersects(view2.frame)) {
            drawIntersection()
        } else {
            // remove the old sublayer
            if (layerToRemove.superlayer != nil) {
                layerToRemove.removeFromSuperlayer()
            }
        }
    }
    
    func drawIntersection() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        // determine polygon clip
        let o1 = view1.frame.origin
        let height1 = view1.frame.height
        let width1 = view1.frame.width
        
        let o2 = view2.frame.origin
        let height2 = view2.frame.height
        let width2 = view2.frame.width
        
        let points1:Array<CGPoint> = [CGPoint(x: o1.x,y: o1.y),
                                      CGPoint(x: o1.x + width1,y: o1.y),
                                      CGPoint(x: o1.x + width1,y: o1.y + height1),
                                      CGPoint(x: o1.x ,y: o1.y + height1)]
        let points2:Array<CGPoint> = [CGPoint(x: o2.x,y: o2.y),
                                      CGPoint(x: o2.x + width2,y: o2.y),
                                      CGPoint(x: o2.x + width2,y: o2.y + height2),
                                      CGPoint(x: o2.x ,y: o2.y + height2)]
        
        let intersection = Clipper.intersectPolygons([points2], withPolygons: [points1])
        
        print("Intersection \(intersection)")
        
        // remove the old sublayer
        layerToRemove.removeFromSuperlayer()
        
        // draw the intersection
        let shape = CAShapeLayer()
        view.layer.addSublayer(shape)
        layerToRemove = shape
        shape.opacity = 0.5
        shape.lineWidth = 2
        shape.lineJoin = kCALineJoinMiter
        shape.strokeColor = UIColor(hue: 0.786, saturation: 0.79, brightness: 0.53, alpha: 1.0).cgColor
        shape.fillColor = UIColor(hue: 0.786, saturation: 0.15, brightness: 0.89, alpha: 1.0).cgColor
        
        var intersectionIterator = intersection.makeIterator()
        while let polygon = intersectionIterator.next() {
            print("NUM POINTS \(polygon.count)")
            
            let firstPoint = polygon[0]
            let path = UIBezierPath()
            path.move(to: CGPoint(x: firstPoint.x,y: firstPoint.y))
            
            var polygonIterator = polygon.makeIterator()
            while let point = polygonIterator.next() {
                path.addLine(to: CGPoint(x: point.x,y: point.y))
            }
            
            path.close()
            shape.path = path.cgPath
        }
    }

}
