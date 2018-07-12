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

@IBDesignable
class StarRatingControl: NSStackView {

    //MARK: Properties

    private var ratingStars = [StarView]()

    @IBInspectable var rating: Int = 0 {
        didSet {
            updateStarsStates()
        }
    }

    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupStars()
        }
    }

    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupStars()
        }
    }

    @IBInspectable var starsFillColor: NSColor = NSColor(red: 0.929, green: 0.541, blue: 0.098, alpha: 1) {
        didSet {
            setupStars()
        }
    }

    @IBInspectable var starsStrokeColor: NSColor = NSColor(red: 0.8, green: 0.32, blue: 0.32, alpha: 1) {
        didSet {
            setupStars()
        }
    }

    //MARK: Initialization
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        initialization()
        setupStars()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)

        initialization()
        setupStars()
    }

    //MARK: Private Methods
    private func initialization() {
        orientation = .horizontal
        spacing = 5
        distribution = .fill
    }

    private func setupStars() {
        setWidthConstraint()

        // Clear any existing buttons
        for starView in ratingStars {
            removeArrangedSubview(starView)

            starView.removeFromSuperview()
        }
        ratingStars.removeAll()

        for index in 0..<starCount {
            let starView = StarView(frame: NSRect(origin: CGPoint(x: 0, y: 0), size: starSize), fillColor: starsFillColor, strokeColor: starsStrokeColor)
            starView.starFilled = index < rating

            // Add constraints
            starView.translatesAutoresizingMaskIntoConstraints = false
            starView.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            starView.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            addArrangedSubview(starView)

            ratingStars.append(starView)
        }

    }

    private func updateStarsStates() {
        for (index, starView) in ratingStars.enumerated() {
            starView.starFilled = index < rating
        }
    }

    private func setWidthConstraint() {
        var found = false

        for constraint in self.constraints {
            if constraint.firstAttribute == .width {
                constraint.constant = CGFloat((starCount * Int(starSize.width)) + (Int(spacing) * (starCount - 1)))
                found = true
                break;
            }
        }

        if !found {
            self.widthAnchor.constraint(equalToConstant: CGFloat((starCount * Int(starSize.width)) + (Int(spacing) * (starCount - 1)))).isActive = true
        }
    }
}
