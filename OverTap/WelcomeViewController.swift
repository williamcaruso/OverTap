//
//  WelcomeViewController.swift
//  OverTap
//
//  Created by William Caruso on 12/1/16.
//  Copyright © 2016 wcaruso. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UIGestureRecognizerDelegate {

    
    // MARK: - Variables
    let instruction1 = "Tap the shape to change its color"
    let instruction2 = "Move the shapes around with your finger"
    let instruction3 = "Resize and rotate the shapes with a pinch"
    let instruction4 = "Press hard (3D-touch) on a shape to change it"
    let instruction5 = "That's the basics! Enjoy OverTap!"
    
    let redColor = UIColor(colorLiteralRed: 0.733, green: 0.027, blue: 0.067, alpha: 1.00)
    let orangeColor = UIColor(colorLiteralRed: 0.992, green: 0.553, blue: 0.180, alpha: 1.00)
    let yellowColor = UIColor(colorLiteralRed: 0.843, green: 0.992, blue: 0.208, alpha: 1.00)
    let greenColor = UIColor(colorLiteralRed: 0.061, green: 0.984, blue: 0.100, alpha: 1.00)
    let blueColor = UIColor(colorLiteralRed: 0.141, green: 0.043, blue: 0.824, alpha: 1.00)
    let purpleColor = UIColor(colorLiteralRed: 0.584, green: 0.145, blue: 0.984, alpha: 1.00)

    var shape = CAShapeLayer()
    var shapeId = Int()
    
    var flag1 = false
    var flag2 = false
    var flag3 = false
    var flag4 = false
    var flag5 = false
    
    @IBOutlet weak var beginButton: UIButton!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var tutorialView: UIView!
    @IBOutlet weak var tutorialLabel: UILabel!
    @IBOutlet weak var feedbackLabel: UILabel!

    @IBAction func BeginButton(_ sender: Any) {
        self.performSegue(withIdentifier: "Begin", sender: nil)
    }
    
    // MARK: -View Controllers
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
                
        // set up tap gesture recognizer
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(handleTap(_:)))
        recognizer.delegate = self
        tutorialView.addGestureRecognizer(recognizer)
        
        tutorialView.backgroundColor = UIColor.clear
        feedbackLabel.isHidden = true
        
        beginButton.setTitle("Skip", for: .normal)
        shapeId = 1
        drawShape(drawInView: tutorialView, shapeId: 1, color: redColor)
        
        tutorialLabel.text = "Let's go through a quick tutorial..."
        let deadlineTime = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.tutorialLabel.text = self.instruction1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Gesture Handlers
    
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            if touch.force == touch.maximumPossibleForce {
                let loc:CGPoint = touch.location(in: self.view)
                for view in view.subviews {
                    if view.frame.contains(loc) {
                        showActionMenu(subview: view)
                        if flag1 && flag2 && flag3 {
                            flag4 = true
                        }
                        break
                    }
                }
            }
        }
    }
    
    func handleTap(_ recognizer:UITapGestureRecognizer) {
        if recognizer.view != nil {
            switch shape.fillColor! {
            case redColor.cgColor:
                shape.fillColor = orangeColor.cgColor
            case orangeColor.cgColor:
                shape.fillColor = yellowColor.cgColor
            case yellowColor.cgColor:
                shape.fillColor = greenColor.cgColor
            case greenColor.cgColor:
                shape.fillColor = blueColor.cgColor
            case blueColor.cgColor:
                shape.fillColor = purpleColor.cgColor
            default:
                shape.fillColor = redColor.cgColor
            }
            if !flag1 && !flag2 && !flag3 && !flag4 {
                self.flag1 = true
                self.feedbackLabel.isHidden = false
                let deadlineTime = DispatchTime.now() + .seconds(2)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.loadTutorial()
                }
            }
        }
    }
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
            if flag1 && !flag2 && !flag3 && !flag4 {
                flag2 = true
                self.feedbackLabel.isHidden = false
                let deadlineTime = DispatchTime.now() + .seconds(2)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.loadTutorial()
                }
            }
        }
        recognizer.setTranslation(CGPoint(), in: self.view)
        
        if recognizer.state == UIGestureRecognizerState.ended {
            let velocity = recognizer.velocity(in: self.view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 200
            
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
    }
    
    @IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
            if flag1 && flag2 {
                flag3 = true
                feedbackLabel.isHidden = false
                let deadlineTime = DispatchTime.now() + .seconds(2)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.loadTutorial()
                }
            }
        }
    }
    
    @IBAction func handleRotate(recognizer : UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }

    // MARK: - Methods
    
    /**
     Moves the tutorial forward
     */
    func loadTutorial() {
        if flag1 && flag2 && flag3 && flag4 {
            // last step
            tutorialLabel.text = instruction5
            if beginButton.titleLabel?.text != "Begin" {
                beginButton.setTitle("Begin", for: .normal)
            }
        } else if flag1 && flag2 && flag3 {
            // pinch
            tutorialView.transform = CGAffineTransform.identity
            tutorialLabel.text = instruction4
            self.feedbackLabel.isHidden = true
        } else if flag1 && flag2 {
            // pinch
            tutorialLabel.text = instruction3
            self.feedbackLabel.isHidden = true
        } else if flag1  {
            // pan
            tutorialLabel.text = instruction2
            self.feedbackLabel.isHidden = true
        }
    }
    
    /**
     Changes the shape in a view
     
     - parameter subview: The view to change the shape in.
     - parameter newShape: The shape to draw in the view
     
     - return The coordinates of the shape.
     */
    func changeShape(subview: UIView, newShape: Int) {
        let col = UIColor(cgColor: (shape.fillColor)!)
        shapeId = newShape
        // remove old shape from subview
        shape.removeFromSuperlayer()
        drawShape(drawInView: subview, shapeId: newShape, color: col)
        
        if flag1 && flag2 && flag3 {
            flag4 = true
            feedbackLabel.isHidden = false
            let deadlineTime = DispatchTime.now() + .seconds(2)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                self.loadTutorial()
            }
        }
    }
    
    /**
     Caclulates points of the shape in the subview
     
     - parameter subview: The view thta the shape is in.
     
     - return The coordinates of the shape.
     */
    func getShapePoints( subview: UIView ) -> Array<CGPoint> {
        
        var points:Array<CGPoint> = []
        let o = CGPoint(x: 0, y: 0)
        let height = subview.frame.height
        let width = subview.frame.width
        
        switch shapeId {
        case 0:     //Triangle
            points = [CGPoint(x: o.x,y: o.y),
                      CGPoint(x: o.x + width,y: o.y),
                      CGPoint(x: o.x + width,y: o.y + height)]
        case 1:     // Square
            points = [CGPoint(x: o.x,y: o.y),
                      CGPoint(x: o.x + width,y: o.y),
                      CGPoint(x: o.x + width,y: o.y + height),
                      CGPoint(x: o.x ,y: o.y + height)]
        case 2:     // Rectangle
            points = [CGPoint(x: o.x,y: o.y),
                      CGPoint(x: o.x + width / 2.0,y: o.y),
                      CGPoint(x: o.x + width / 2.0,y: o.y + height),
                      CGPoint(x: o.x ,y: o.y + height)]
        case 3:     // Pentagon
            points = [CGPoint(x: o.x + width / 2.0,y: o.y),
                      CGPoint(x: o.x + width,y: o.y + 2 * height / 5.0),
                      CGPoint(x: o.x + 4 * width / 5,y: o.y + height),
                      CGPoint(x: o.x + width / 5.0,y: o.y + height),
                      CGPoint(x: o.x,y: o.y + 2.0 * height / 5.0)]
        case 4:     // Hexagon
            points = [CGPoint(x: o.x + width / 4.0,y: o.y),
                      CGPoint(x: o.x + 3 * width / 4.0,y: o.y),
                      CGPoint(x: o.x + width,y: o.y + 7 * height / 16.0),
                      CGPoint(x: o.x + 3 * width / 4.0,y: o.y + 7 * height / 8.0),
                      CGPoint(x: o.x + width / 4.0,y: o.y + 7 * height / 8.0),
                      CGPoint(x: o.x,y: o.y + 7 * height / 16.0)]
        case 5:     // Octagon
            points = [CGPoint(x: o.x +  width / 3.0,y: o.y),
                      CGPoint(x: o.x + 2 * width / 3.0,y: o.y),
                      CGPoint(x: o.x + width,y: o.y + height / 3.0),
                      CGPoint(x: o.x + width,y: o.y + 2 * height / 3.0),
                      CGPoint(x: o.x + 2 * width / 3.0,y: o.y + height),
                      CGPoint(x: o.x + width / 3.0,y: o.y + height),
                      CGPoint(x: o.x,y: o.y + 2 * height / 3.0),
                      CGPoint(x: o.x,y: o.y + height / 3.0)]
        default:
            points = []
        }
        
        return points
    }
    
    /**
     Draws a shape inside of a view and adds a sublayer
     
     - parameter drawInView: The view to draw in.
     - parameter shape: The shape to draw.
     */
    func drawShape( drawInView: UIView, shapeId: Int, color: UIColor) {
        
        self.shapeId = shapeId
        var points:Array<CGPoint> = getShapePoints(subview: drawInView)
        
        let shape = CAShapeLayer()
        drawInView.layer.addSublayer(shape)
        shape.opacity = 1
        shape.lineWidth = 2
        shape.lineJoin = kCALineJoinMiter
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = color.cgColor
        
        let firstPoint = points[0]
        let path = UIBezierPath()
        path.move(to: firstPoint)
        
        var polygonIterator = points.makeIterator()
        while let point = polygonIterator.next() {
            path.addLine(to: point)
        }
        
        path.close()
        shape.path = path.cgPath
        self.shape = shape
    }

    
    /**
     Displays an action menu to change a view's shape
     
     -parameter subview: The subview whose shape to change
     */
    func showActionMenu(subview: UIView) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Shape", preferredStyle: .actionSheet)
        
        let triangleAction = UIAlertAction(title: "Triangle", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.changeShape(subview: subview, newShape: 0)
        })
        
        let squareAction = UIAlertAction(title: "Square", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.changeShape(subview: subview, newShape: 1)
        })
        
        let rectangleAction = UIAlertAction(title: "Rectangle", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.changeShape(subview: subview, newShape: 2)
        })
        
        let pentagonAction = UIAlertAction(title: "Pentagon", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.changeShape(subview: subview, newShape: 3)
        })
        
        let hexagonAction = UIAlertAction(title: "Hexagon", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.changeShape(subview: subview, newShape: 4)
        })
        
        let octagonAction = UIAlertAction(title: "Octagon", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.changeShape(subview: subview, newShape: 5)
        })
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(triangleAction)
        optionMenu.addAction(squareAction)
        optionMenu.addAction(rectangleAction)
        optionMenu.addAction(pentagonAction)
        optionMenu.addAction(hexagonAction)
        optionMenu.addAction(octagonAction)
        optionMenu.addAction(dismissAction)
        
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
}
