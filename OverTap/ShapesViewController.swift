//
//  ShapesViewController.swift
//  OverTap
//
//  Created by William Caruso on 11/22/16.
//  Copyright © 2016 wcaruso. All rights reserved.
//

import UIKit
import RSClipperWrapper
import KCFloatingActionButton

class ShapesViewController: UIViewController, UIGestureRecognizerDelegate {
    
    
    // MARK: - Variables
    var layersToRemove = [String: CAShapeLayer]()
    
    var pointsInView = [UIView: Array<CGPoint>]()
    var shapesInView = [UIView: CAShapeLayer]()
    var shapeIdInView = [UIView: Int]()

    var VIEW_IDS = [UIView: String]()
    
    let NUM_SHAPES = 6
    let VIEW_HASHES = ["view1view2", "view1view3", "view2view3"]

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    
    
    // MARK: - View Controllers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named:"back.jpg")!)
        headerLabel.isHidden = true
        
        view1.backgroundColor = UIColor.clear
        view2.backgroundColor = UIColor.clear
        view3.backgroundColor = UIColor.clear
        
        view1.alpha = 0.6
        view2.alpha = 0.6
        view3.alpha = 0.6
        
        VIEW_IDS = [view1: "view1", view2: "view2", view3: "view3"]
        
        let recognizer1 = UITapGestureRecognizer(target: self, action:#selector(handleTap(_:)))
        recognizer1.delegate = self
        view1.addGestureRecognizer(recognizer1)

        let recognizer2 = UITapGestureRecognizer(target: self, action:#selector(handleTap(_:)))
        recognizer2.delegate = self
        view2.addGestureRecognizer(recognizer2)

        let recognizer3 = UITapGestureRecognizer(target: self, action:#selector(handleTap(_:)))
        recognizer3.delegate = self
        view3.addGestureRecognizer(recognizer3)
        
        drawShape(drawInView: view1, shapeId: 1, color: UIColor.red)
        drawShape(drawInView: view2, shapeId: 1, color: UIColor.blue)
        drawShape(drawInView: view3, shapeId: 1, color: UIColor.green)
        
        view3.isHidden = true
        
        let fab = KCFloatingActionButton()

        fab.addItem("Credits", icon: UIImage(named: "credits.png")!, handler: { item in
            self.performSegue(withIdentifier: "Credits", sender: nil)
            fab.close()
        })
        fab.addItem("Remove Third Shape", icon: UIImage(named: "delete.jpg")!, handler: { item in
            self.view3.isHidden = true
            self.findIntersections()
            fab.close()
        })
        fab.addItem("Add Third Shape", icon: UIImage(named: "shapes.png")!, handler: { item in
            self.view3.isHidden = false
            self.findIntersections()
            fab.close()
        })
        self.view.addSubview(fab)
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
                        break
                    }
                }
            }
        }
    }

    func handleTap(_ recognizer:UITapGestureRecognizer) {
        if let view = recognizer.view {
            
            let shape = shapesInView[view]!
            
            switch shape.fillColor! {
            case UIColor.red.cgColor:
                shape.fillColor = UIColor.orange.cgColor
            case UIColor.orange.cgColor:
                shape.fillColor = UIColor.green.cgColor
            case UIColor.green.cgColor:
                shape.fillColor = UIColor.blue.cgColor
            case UIColor.blue.cgColor:
                shape.fillColor = UIColor.purple.cgColor
            default:
                shape.fillColor = UIColor.red.cgColor
            }
        }
        findIntersections()
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
        findIntersections()
    }
    
    @IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
            pointsInView[view] = getShapePoints(subview: view)
        }
        findIntersections()
    }
    
    @IBAction func handleRotate(recognizer : UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
        findIntersections()
    }
    
    // MARK: - Methods
    
    /**
     Changes the shape in a view
     
     - parameter subview: The view to change the shape in.
     - parameter newShape: The shape to draw in the view
     
     - return The coordinates of the shape.
     */
    func changeShape(subview: UIView, newShape: Int) {
        let oldShape = shapesInView[subview]
        let col = UIColor(cgColor: (oldShape?.fillColor!)!)
        
        // remove old shape from subview
        oldShape?.removeFromSuperlayer()
        drawShape(drawInView: subview, shapeId: newShape, color: col)
        findIntersections()
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
        
        switch shapeIdInView[subview]! {
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
                      CGPoint(x: o.x + width,y: o.y + height / 2.0),
                      CGPoint(x: o.x + 3 * width / 4.0,y: o.y + height),
                      CGPoint(x: o.x + width / 4.0,y: o.y + height),
                      CGPoint(x: o.x,y: o.y + height / 2.0)]
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
        
        shapeIdInView[drawInView] = shapeId
        
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
        
        pointsInView[drawInView] = points
        shapesInView[drawInView] = shape
    }
    
    /**
     Rotates a point by a certain amount of radians around an origin
     
     - parameter target: The point to rotate.
     - parameter aroundOrigin: The origin to rotate about.
     - parameter byRadians: The angle of rotation (radians).
     
     - return The transformed point.
     */
    func rotatePoint(target: CGPoint, origin: CGPoint, byRadians: CGFloat) -> CGPoint {
        print("ORIGIN ROTATION \(origin)")
        let dx = target.x - origin.x
        let dy = target.y - origin.y
        let radius = sqrt(dx * dx + dy * dy)
        let alpha = atan2(dy, dx) // in radians
        let newAlpha = alpha + byRadians
        let x = origin.x + radius * cos(newAlpha)
        let y = origin.y + radius * sin(newAlpha)
        
        return CGPoint(x: x, y: y)
    }
    
    /**
     Transforms a subviews points to the coordinate frame of the superview
     
     - parameter subview: The view whose points to transform.
     
     - return The transformed points.
     */
    func transformPointsToSuperview( subview: UIView ) -> Array<CGPoint> {
        
        let points = pointsInView[subview]!
        var transPoints = Array<CGPoint>()
        let origin = subview.frame.origin
        var transPoint = CGPoint()
        let refPoint = CGPoint(x: origin.x + (subview.frame.width / 2.0),y: origin.y + (subview.frame.height / 2.0))
        
        for point in points {
            // check if view has been rotated
            transPoint = CGPoint(x: point.x + origin.x, y: point.y + origin.y)
            
            if (subview.transform.b != 0) { // rotation
                let radians = CGFloat(atan2f(Float(subview.transform.b), Float(subview.transform.a)))
                let rotatedPoint = rotatePoint(target: transPoint, origin: refPoint, byRadians: radians)
                transPoints.append(rotatedPoint)
            } else { // no scaling or rotation
                transPoints.append(transPoint)
            }
        }
        
        print("Points in View: \(points)")
        print("Transformed Point: \(transPoints)")
        
        return transPoints
    }
    
    /**
     Blends two UIColors together
     
     - parameter subview: The view whose points to transform.
     
     - return The transformed points.
     */
    func blendColor(color1: UIColor, withColor color2: UIColor) -> UIColor {
        var r1:CGFloat = 0, g1:CGFloat = 0, b1:CGFloat = 0, a1:CGFloat = 0
        var r2:CGFloat = 0, g2:CGFloat = 0, b2:CGFloat = 0, a2:CGFloat = 0
        
        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return UIColor(red: max(r1, r2), green: max(g1, g2), blue: max(b1, b2), alpha: max(a1, a2))
    }
    
    /**
     Finds the intersections of the non-hidden UIViews and then draws them
     */
    func findIntersections() {
        
        // first remove the old shapes
        for hash in VIEW_HASHES {
            if (layersToRemove[hash]?.superlayer != nil) {
                layersToRemove[hash]?.removeFromSuperlayer()
            }
        }
        
        var intersections = [(UIView, UIView)]()
        
        if (!view1.isHidden && !view2.isHidden && !view3.isHidden) {
            if view1.frame.intersects(view2.frame) { intersections.append((view1, view2)) }
            if view1.frame.intersects(view3.frame) { intersections.append((view1, view3)) }
            if view2.frame.intersects(view3.frame) { intersections.append((view2, view3)) }
        } else if (!view1.isHidden && !view2.isHidden) {
            if view1.frame.intersects(view2.frame) { intersections.append((view1, view2)) }
        } else {
            // no intersections
            headerLabel.isHidden = true
        }
        
        if intersections.count == 0 {
            headerLabel.isHidden = true
        } else {
            for pair in intersections {
                drawIntersection(pair: pair)
            }
        }
    }
    
    /**
     Draw the intersection of the polgyons
     */
    func drawIntersection(pair : (UIView, UIView)) {
        
        let viewA = pair.0
        let viewB = pair.1
        
        let hash = VIEW_IDS[viewA]! + VIEW_IDS[viewB]!
        
        // get transform points
        let points1 = transformPointsToSuperview(subview: viewA)
        let points2 = transformPointsToSuperview(subview: viewB)
        
        print("Points 1 with scale \(viewA.transform.a) and rotation \(viewA.transform.b): \(points1)")
        
        let intersection = Clipper.intersectPolygons([points2], withPolygons: [points1])
        
        print("Intersection \(hash): \(intersection)")
        
        // draw the intersection
        let shape = CAShapeLayer()
        view.layer.addSublayer(shape)
        shape.opacity = 0.5
        shape.lineWidth = 2
        shape.lineJoin = kCALineJoinMiter
        shape.strokeColor = UIColor.white.cgColor
        shape.fillColor = blendColor(color1: UIColor(cgColor: (shapesInView[viewA]?.fillColor)!), withColor: UIColor(cgColor: (shapesInView[viewB]?.fillColor)!)).cgColor
        
        if (layersToRemove[hash] != shape) {
            // haptic feedback becasue a new intersection is being made
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            // remove the old sublayer
            if (layersToRemove[hash]?.superlayer != nil) {
                layersToRemove[hash]?.removeFromSuperlayer()
            }
            layersToRemove[hash] = shape
            
            var intersectionIterator = intersection.makeIterator()
            while let polygon = intersectionIterator.next() {
                
                let firstPoint = polygon[0]
                let path = UIBezierPath()
                path.move(to: CGPoint(x: firstPoint.x,y: firstPoint.y))
                
                var polygonIterator = polygon.makeIterator()
                while let point = polygonIterator.next() {
                    path.addLine(to: CGPoint(x: point.x,y: point.y))
                }
                
                path.close()
                shape.path = path.cgPath
                headerLabel.isHidden = false
            }
        }
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
            self.changeShape(subview: subview, newShape: 4)
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
