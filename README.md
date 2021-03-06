# OverTap
![Swift 3.0](https://img.shields.io/badge/Swift-3.0-orange.svg)

OverTap is an app with two rectangles. See what happens when they overlap!

## Background

OverTap was written in Swift 3.0 with a touch of love and a tap of creativity..

## App Walkthrough

### Welcome Screen

First you are brought to the welcome screen. This screen explains the apps functionality:

* Move a shape around with your finger
* Resize shapes with a pinch
* Rotate shapes with a rotation gesture
* Change the color of a shape by single tapping it
* Change the shape by 3D-touching it and selecting a shape in the action menu
* Add or remove a third shape with the floating action button 

### Shape Screen

This is the canvas for your shapes. Feel free to move them around, resize and rotate them. Add a third shape if you'd like! Also, experiement with different shapes! 

When two (or more) shapes intersect the user is alerted in 3 ways:

* The clipping (intersection of the shape) is drawn in a blend of the intersecting shapes colors
* The 'Intersection' label appears on the top
* Haptic feedback is provided to the user

#### Color Change and Two Rectangles Intersecting

![Demo 1](/demos/demo1.gif)

#### Resizing Rectangles

![Demo2](/demos/demo2.gif)

#### Adding a Third Rectangle

![Demo3](/demos/demo3.gif)

#### Changing Shapes

![Demo4](/demos/demo4.gif)

### Credits

You'll find the credits  here and can share the repo link!

I used two open source libraries for this implemetation:

* [RSClipperWrapper](https://github.com/rusty1s/RSClipperWrapper) - A small and simple wrapper for Clipper - an open source freeware library for clipping polygons
* [KCFloatingActionButton](https://github.com/kciter/KCFloatingActionButton) - Simple Floating Action Button for iOS

