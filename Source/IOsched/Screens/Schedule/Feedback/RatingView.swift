//
//  Copyright (c) 2017 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

class RatingView: UIControl {

  var rating: Int? {
    didSet {
      if let value = rating {
        setHighlighted(index: value - 1)
      } else {
        clearAll()
      }

      // highlight the appropriate amount of stars.
      sendActions(for: .valueChanged)
    }
  }

  private let starLayers: [CAShapeLayer]

  private let poorLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.enableAdjustFontForContentSizeCategory()
    label.font = UIFont.preferredFont(forTextStyle: .caption1)
    label.textColor = UIColor(red: 95 / 255, green: 99 / 255, blue: 104 / 255, alpha: 1)
    label.numberOfLines = 1
    label.text = NSLocalizedString("Poor",
                                   comment: "Label on a rating selection UI of 1-5 where 1 is poor")
    return label
  }()

  private let outstandingLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.enableAdjustFontForContentSizeCategory()
    label.font = UIFont.preferredFont(forTextStyle: .caption1)
    label.textColor = UIColor(red: 95 / 255, green: 99 / 255, blue: 104 / 255, alpha: 1)
    label.numberOfLines = 1
    label.text = NSLocalizedString(
      "Outstanding",
      comment: "Label on a rating selection UI of 1-5 where 5 is outstanding"
    )
    return label
  }()

  override init(frame: CGRect) {
    starLayers = (0 ..< 5).map {
      let layer = RatingView.starLayer()
      layer.frame = CGRect(x: $0 * 55, y: 0, width: 25, height: 25)
      return layer
    }
    super.init(frame: frame)

    starLayers.forEach {
      layer.addSublayer($0)
    }

    addSubview(poorLabel)
    addSubview(outstandingLabel)

    setupLabelConstraints()
  }

  private var starWidth: CGFloat {
    return intrinsicContentSize.width / 5
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    guard let touch = touches.first else { return }
    let point = touch.location(in: self)
    let index = clamp(Int(point.x / starWidth))
    setHighlighted(index: index)
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    guard let touch = touches.first else { return }
    let point = touch.location(in: self)
    let index = clamp(Int(point.x / starWidth))
    setHighlighted(index: index)
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    guard let touch = touches.first else { return }
    let point = touch.location(in: self)
    let index = clamp(Int(point.x / starWidth))
    rating = index + 1 // Ratings are 1-indexed; things can be between 1-5 stars.
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    guard touches.first != nil else { return }

    // Cancelled touches should preserve the value before the interaction.
    if let oldRating = rating {
      let oldIndex = oldRating - 1
      setHighlighted(index: oldIndex)
    } else {
      clearAll()
    }
  }

  /// This is an awful func name. Index must be within 0 ..< 4, or crash.
  private func setHighlighted(index: Int) {
    // Highlight everything up to and including the star at the index.
    (0 ... index).forEach {
      let star = starLayers[$0]
      star.strokeColor = Constants.highlightedColor
      star.fillColor = Constants.highlightedColor
    }

    // Unhighlight everything after the index, if applicable.
    guard index < 4 else { return }
    ((index + 1) ..< 5).forEach {
      let star = starLayers[$0]
      star.strokeColor = Constants.unhighlightedColor
      star.fillColor = nil
    }
  }

  /// Unhighlights every star.
  private func clearAll() {
    (0 ..< 5).forEach {
      let star = starLayers[$0]
      star.strokeColor = Constants.unhighlightedColor
      star.fillColor = nil
    }
  }

  private func clamp(_ index: Int) -> Int {
    if index < 0 { return 0 }
    if index >= 5 { return 4 }
    return index
  }

  override var intrinsicContentSize: CGSize {
    var starsSize = CGSize(width: 270, height: 50)
    let extraHeight = 16 + poorLabel.intrinsicContentSize.height
    starsSize.height += extraHeight
    return starsSize
  }

  static var viewHeight: CGFloat {
    let fontHeight = UIFont.preferredFont(forTextStyle: .caption1).lineHeight
    return fontHeight + 50 + 16
  }

  override var isMultipleTouchEnabled: Bool {
    get {
      return false
    }
    set {}
  }

  private static func starLayer() -> CAShapeLayer {
    let layer = CAShapeLayer()

    let mutablePath = CGMutablePath()

    let outerRadius: CGFloat = 14
    let outerPoints = stride(from: CGFloat.pi / -5, to: .pi * 2, by: 2 * .pi / 5).map {
      return CGPoint(x: outerRadius * sin($0) + 25,
                     y: outerRadius * cos($0) + 25)
    }

    let innerRadius: CGFloat = 6.5
    let innerPoints = stride(from: 0, to: .pi * 2, by: 2 * .pi / 5).map {
      return CGPoint(x: innerRadius * sin($0) + 25,
                     y: innerRadius * cos($0) + 25)
    }

    let points = zip(outerPoints, innerPoints).reduce([CGPoint]()) { (aggregate, pair) -> [CGPoint] in
      return aggregate + [pair.0, pair.1]
    }

    mutablePath.move(to: points[0])
    points.forEach {
      mutablePath.addLine(to: $0)
    }
    mutablePath.closeSubpath()

    layer.path = mutablePath.copy()
    layer.strokeColor = UIColor(red: 26 / 255, green: 115 / 255, blue: 232 / 255, alpha: 1).cgColor
    layer.lineWidth = 2
    layer.fillColor = nil

    return layer
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private enum Constants {
    static let unhighlightedColor = UIColor(red: 26 / 255, green: 115 / 255, blue: 232 / 255, alpha: 1).cgColor
    static let highlightedColor = UIColor(red: 26 / 255, green: 115 / 255, blue: 232 / 255, alpha: 1).cgColor
  }

  // MARK: Rating View Accessibility

  override var isAccessibilityElement: Bool {
    get { return true }
    set {}
  }

  override var accessibilityValue: String? {
    get {
      if let rating = rating {
        return NSLocalizedString("\(rating) out of 5", comment: "Format string for indicating a variable amount of stars out of five")
      }
      return NSLocalizedString("No rating", comment: "Read by VoiceOver to vision-impaired users indicating a rating that hasn't been filled out yet")
    }
    set {}
  }

  override var accessibilityTraits: UIAccessibilityTraits {
    get { return UIAccessibilityTraits.adjustable }
    set {}
  }

  override func accessibilityIncrement() {
    let currentRatingIndex = (rating ?? 0) - 1
    let highlightedIndex = clamp(currentRatingIndex + 1)
    rating = highlightedIndex + 1
  }

  override func accessibilityDecrement() {
    guard let rating = rating else { return } // Doesn't make sense to decrement no rating and get 1.
    let currentRatingIndex = rating - 1
    let highlightedIndex = clamp(currentRatingIndex - 1)
    self.rating = highlightedIndex + 1
  }

  // MARK: - Constraints

  private func setupLabelConstraints() {
    let constraints = [
      NSLayoutConstraint(item: poorLabel,
                         attribute: .left,
                         relatedBy: .equal,
                         toItem: self,
                         attribute: .left,
                         multiplier: 1,
                         constant: 0),
      NSLayoutConstraint(item: poorLabel,
                         attribute: .bottom,
                         relatedBy: .equal,
                         toItem: self,
                         attribute: .bottom,
                         multiplier: 1,
                         constant: 0),
      NSLayoutConstraint(item: outstandingLabel,
                         attribute: .right,
                         relatedBy: .equal,
                         toItem: self,
                         attribute: .right,
                         multiplier: 1,
                         constant: 0),
      NSLayoutConstraint(item: outstandingLabel,
                         attribute: .bottom,
                         relatedBy: .equal,
                         toItem: self,
                         attribute: .bottom,
                         multiplier: 1,
                         constant: 0)
    ]

    addConstraints(constraints)
  }

}
