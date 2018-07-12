/*
 * Copyright 2018 Dionysios Karatzas
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


import Cocoa

@IBDesignable class StarView: NSView {

    //MARK: Properties

    @IBInspectable var starFilled: Bool = true {
        didSet {
            needsDisplay = true
        }
    }

    @IBInspectable var fillColor: NSColor = NSColor(red: 0.929, green: 0.541, blue: 0.098, alpha: 1) {
        didSet {
            needsDisplay = true
        }
    }

    @IBInspectable var strokeColor: NSColor = NSColor(red: 0.8, green: 0.32, blue: 0.32, alpha: 1) {
        didSet {
            needsDisplay = true
        }
    }

    //MARK: Initialization

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    convenience init(frame: NSRect, fillColor: NSColor, strokeColor: NSColor) {
        self.init(frame: frame)
        self.fillColor = fillColor
        self.strokeColor = strokeColor
    }


    //MARK: Drawing Methods
    public override func draw(_ dirtyRect: NSRect) {
        drawStarRating(frame: dirtyRect)
    }

    func drawStarRating(frame: NSRect) {
        //// Star Drawing
        let starPath = NSBezierPath()
        starPath.move(to: NSPoint(x: frame.minX + 0.54828 * frame.width, y: frame.minY + 0.96861 * frame.height))
        starPath.line(to: NSPoint(x: frame.minX + 0.66107 * frame.width, y: frame.minY + 0.72964 * frame.height))
        starPath.curve(to: NSPoint(x: frame.minX + 0.70162 * frame.width, y: frame.minY + 0.69884 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.66891 * frame.width, y: frame.minY + 0.71302 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.68407 * frame.width, y: frame.minY + 0.70150 * frame.height))
        starPath.line(to: NSPoint(x: frame.minX + 0.95383 * frame.width, y: frame.minY + 0.66051 * frame.height))
        starPath.curve(to: NSPoint(x: frame.minX + 0.98368 * frame.width, y: frame.minY + 0.56448 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.99801 * frame.width, y: frame.minY + 0.65380 * frame.height), controlPoint2: NSPoint(x: frame.minX + 1.01564 * frame.width, y: frame.minY + 0.59704 * frame.height))
        starPath.line(to: NSPoint(x: frame.minX + 0.80118 * frame.width, y: frame.minY + 0.37847 * frame.height))
        starPath.curve(to: NSPoint(x: frame.minX + 0.78570 * frame.width, y: frame.minY + 0.32863 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.78850 * frame.width, y: frame.minY + 0.36553 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.78270 * frame.width, y: frame.minY + 0.34688 * frame.height))
        starPath.line(to: NSPoint(x: frame.minX + 0.82878 * frame.width, y: frame.minY + 0.06597 * frame.height))
        starPath.curve(to: NSPoint(x: frame.minX + 0.75064 * frame.width, y: frame.minY + 0.00659 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.83633 * frame.width, y: frame.minY + 0.01997 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.79015 * frame.width, y: frame.minY + -0.01511 * frame.height))
        starPath.line(to: NSPoint(x: frame.minX + 0.52506 * frame.width, y: frame.minY + 0.13060 * frame.height))
        starPath.curve(to: NSPoint(x: frame.minX + 0.47494 * frame.width, y: frame.minY + 0.13060 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.50938 * frame.width, y: frame.minY + 0.13921 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.49062 * frame.width, y: frame.minY + 0.13921 * frame.height))
        starPath.line(to: NSPoint(x: frame.minX + 0.24936 * frame.width, y: frame.minY + 0.00659 * frame.height))
        starPath.curve(to: NSPoint(x: frame.minX + 0.17122 * frame.width, y: frame.minY + 0.06597 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.20985 * frame.width, y: frame.minY + -0.01513 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.16367 * frame.width, y: frame.minY + 0.01997 * frame.height))
        starPath.line(to: NSPoint(x: frame.minX + 0.21430 * frame.width, y: frame.minY + 0.32863 * frame.height))
        starPath.curve(to: NSPoint(x: frame.minX + 0.19882 * frame.width, y: frame.minY + 0.37847 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.21730 * frame.width, y: frame.minY + 0.34688 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.21150 * frame.width, y: frame.minY + 0.36553 * frame.height))
        starPath.line(to: NSPoint(x: frame.minX + 0.01632 * frame.width, y: frame.minY + 0.56448 * frame.height))
        starPath.curve(to: NSPoint(x: frame.minX + 0.04617 * frame.width, y: frame.minY + 0.66051 * frame.height), controlPoint1: NSPoint(x: frame.minX + -0.01564 * frame.width, y: frame.minY + 0.59706 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.00199 * frame.width, y: frame.minY + 0.65382 * frame.height))
        starPath.line(to: NSPoint(x: frame.minX + 0.29838 * frame.width, y: frame.minY + 0.69884 * frame.height))
        starPath.curve(to: NSPoint(x: frame.minX + 0.33893 * frame.width, y: frame.minY + 0.72964 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.31593 * frame.width, y: frame.minY + 0.70150 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.33109 * frame.width, y: frame.minY + 0.71302 * frame.height))
        starPath.line(to: NSPoint(x: frame.minX + 0.45172 * frame.width, y: frame.minY + 0.96861 * frame.height))
        starPath.curve(to: NSPoint(x: frame.minX + 0.54828 * frame.width, y: frame.minY + 0.96861 * frame.height), controlPoint1: NSPoint(x: frame.minX + 0.47145 * frame.width, y: frame.minY + 1.01046 * frame.height), controlPoint2: NSPoint(x: frame.minX + 0.52853 * frame.width, y: frame.minY + 1.01046 * frame.height))
        starPath.close()
        if starFilled {
            fillColor.setFill()
            starPath.fill()
        }
        strokeColor.setStroke()
        starPath.lineWidth = 1.5
        starPath.miterLimit = 4
        starPath.stroke()
    }


}
