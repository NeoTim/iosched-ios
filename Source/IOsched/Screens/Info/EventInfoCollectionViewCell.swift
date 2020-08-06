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

import Firebase
import MaterialComponents

class EventInfoCollectionViewCell: MDCCollectionViewCell {

  struct Constants {
    static let headerHeight: CGFloat = 200

    // swiftlint:disable large_tuple
    static let headerInsets: (left: CGFloat, right: CGFloat) = (
      left: 16, right: 16
    )
    // swiftlint:enable large_tuple

    static let titleTopPadding: CGFloat = 16
    static let titleLabelFont = UIFont.preferredFont(forTextStyle: .title1)

    static let titleTextColor = UIColor(red: 74 / 255, green: 74 / 255, blue: 74 / 255, alpha: 1)

    static let titleLabelTopSpacing: CGFloat = 14

    static let summaryLabelFont = { () -> UIFont in
      return UIFont.preferredFont(forTextStyle: .body)
    }

    static let summaryLabelTopSpacing: CGFloat = 16
    static let summaryLabelBottomSpacing: CGFloat = 102
    static let summaryTextColor = UIColor(red: 66 / 255, green: 66 / 255, blue: 66 / 255, alpha: 1)
    static let summaryParagraphStyle = { () -> NSMutableParagraphStyle in
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.lineHeightMultiple = 24 / 15
      return paragraphStyle
    }()

    static let viewSessionsText = NSLocalizedString("View sessions",
                                                    comment: "Button text to open the schedule view")
    static let viewMapText = NSLocalizedString("View map",
                                               comment: "Button text to open the map view")
    static let buttonTextColor = UIColor(red: 26 / 255, green: 115 / 255, blue: 232 / 255, alpha: 1)
  }

  private let titleImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
  private let titleLabel = UILabel()
  private let headerBackgroundView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()

  // MARK: - Public

  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.addSubview(headerBackgroundView)
    contentView.addSubview(titleImageView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(summaryLabel)
    contentView.addSubview(viewSessionsButton)
    contentView.addSubview(viewMapButton)
    setupHeaderBackgroundView()
    setupSummaryLabel()
    setupConstraints()
    setupButtons()

    contentView.layer.cornerRadius = 8
    contentView.layer.borderColor = UIColor(hex: 0xdadce0).cgColor
    contentView.layer.borderWidth = 1
    contentView.clipsToBounds = true
  }

  var summary: String? {
    get {
      return summaryLabel.text ?? summaryLabel.attributedText?.string
    }
    set {
      guard let string = newValue else {
        summaryLabel.text = nil
        return
      }

      let attributed = NSMutableAttributedString(string: string)
      attributed.addAttribute(NSAttributedString.Key.paragraphStyle,
                              value: Constants.summaryParagraphStyle,
                              range: NSRange(location: 0, length: attributed.length))
      summaryLabel.attributedText = attributed
    }
  }

  var title: String? {
    get {
      return titleLabel.text ?? titleLabel.attributedText?.string
    }
    set {
      titleLabel.text = newValue
    }
  }

  var titleIcon: UIImage? {
    get {
      return headerBackgroundView.image
    }
    set {
      headerBackgroundView.image = newValue
    }
  }

  // MARK: - Private layout code

  private let summaryLabel = UILabel()

  fileprivate let viewSessionsButton = MDCFlatButton()
  fileprivate let viewMapButton = MDCFlatButton()

  private static func boundingRect(forText text: String,
                                   attributes: [NSAttributedString.Key: Any]? = nil,
                                   maxWidth: CGFloat) -> CGRect {
    let rect = text.boundingRect(with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
                                 options: [.usesLineFragmentOrigin, .usesFontLeading],
                                 attributes: attributes,
                                 context: nil)
    return rect
  }

  static func minimumHeight(title: String, summary: String, maxWidth: CGFloat) -> CGFloat {
    let effectiveMaxWidth = maxWidth - Constants.headerInsets.left - Constants.headerInsets.right
    let summaryHeight = boundingRect(forText: summary,
                                     attributes: [
                                      NSAttributedString.Key.font: Constants.summaryLabelFont(),
                                      NSAttributedString.Key.paragraphStyle: Constants.summaryParagraphStyle
      ],
                                     maxWidth: effectiveMaxWidth).size.height
    let titleHeight = boundingRect(forText: title,
                                   attributes: [NSAttributedString.Key.font: Constants.titleLabelFont],
                                   maxWidth: effectiveMaxWidth).size.height
    return Constants.headerHeight
        + Constants.titleTopPadding
        + titleHeight
        + Constants.summaryLabelTopSpacing
        + summaryHeight
        + Constants.summaryLabelBottomSpacing
  }

  private func setupHeaderBackgroundView() {
    headerBackgroundView.translatesAutoresizingMaskIntoConstraints = false
    titleImageView.contentMode = .scaleAspectFit
    titleImageView.translatesAutoresizingMaskIntoConstraints = false

    titleLabel.numberOfLines = 0
    titleLabel.lineBreakMode = .byWordWrapping
    titleLabel.font = Constants.titleLabelFont
    titleLabel.textColor = Constants.titleTextColor
    titleLabel.enableAdjustFontForContentSizeCategory()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
  }

  private func setupSummaryLabel() {
    summaryLabel.font = Constants.summaryLabelFont()
    summaryLabel.numberOfLines = 0
    summaryLabel.lineBreakMode = .byWordWrapping
    summaryLabel.textColor = Constants.summaryTextColor
    summaryLabel.translatesAutoresizingMaskIntoConstraints = false
  }

  private func setupButtons() {
    viewSessionsButton.translatesAutoresizingMaskIntoConstraints = false
    viewMapButton.translatesAutoresizingMaskIntoConstraints = false
    viewSessionsButton.setTitle(Constants.viewSessionsText, for: .normal)
    viewMapButton.setTitle(Constants.viewMapText, for: .normal)
    viewSessionsButton.setTitleColor(Constants.buttonTextColor, for: .normal)
    viewMapButton.setTitleColor(Constants.buttonTextColor, for: .normal)
    viewSessionsButton.isUppercaseTitle = false
    viewMapButton.isUppercaseTitle = false

    viewSessionsButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
    viewMapButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
  }

  // swiftlint:disable function_body_length
  private func setupConstraints() {
    var constraints: [NSLayoutConstraint] = []

    // header background view top
    constraints.append(NSLayoutConstraint(item: headerBackgroundView,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: contentView,
                                          attribute: .top,
                                          multiplier: 1,
                                          constant: 0))
    // header background view left
    constraints.append(NSLayoutConstraint(item: headerBackgroundView,
                                          attribute: .left,
                                          relatedBy: .equal,
                                          toItem: contentView,
                                          attribute: .left,
                                          multiplier: 1,
                                          constant: 0))
    // header background view right
    constraints.append(NSLayoutConstraint(item: headerBackgroundView,
                                          attribute: .right,
                                          relatedBy: .equal,
                                          toItem: contentView,
                                          attribute: .right,
                                          multiplier: 1,
                                          constant: 0))
    // header background view height
    constraints.append(NSLayoutConstraint(item: headerBackgroundView,
                                          attribute: .height,
                                          relatedBy: .equal,
                                          toItem: nil,
                                          attribute: .notAnAttribute,
                                          multiplier: 1,
                                          constant: Constants.headerHeight))
    // image view height
    constraints.append(NSLayoutConstraint(item: titleImageView,
                                          attribute: .height,
                                          relatedBy: .equal,
                                          toItem: nil,
                                          attribute: .notAnAttribute,
                                          multiplier: 1,
                                          constant: 100))
    // image view width
    constraints.append(NSLayoutConstraint(item: titleImageView,
                                          attribute: .width,
                                          relatedBy: .equal,
                                          toItem: nil,
                                          attribute: .notAnAttribute,
                                          multiplier: 1,
                                          constant: 100))
    // image view top
    constraints.append(NSLayoutConstraint(item: titleImageView,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: contentView,
                                          attribute: .top,
                                          multiplier: 1,
                                          constant: 30))
    // image view right
    constraints.append(NSLayoutConstraint(item: titleImageView,
                                          attribute: .right,
                                          relatedBy: .equal,
                                          toItem: contentView,
                                          attribute: .right,
                                          multiplier: 1,
                                          constant: -45))
    // title label bottom
    constraints.append(NSLayoutConstraint(item: titleLabel,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: headerBackgroundView,
                                          attribute: .bottom,
                                          multiplier: 1,
                                          constant: Constants.titleTopPadding))
    // title label left
    constraints.append(NSLayoutConstraint(item: titleLabel,
                                          attribute: .left,
                                          relatedBy: .equal,
                                          toItem: contentView,
                                          attribute: .left,
                                          multiplier: 1,
                                          constant: Constants.headerInsets.left))
    // title label right
    constraints.append(NSLayoutConstraint(item: titleLabel,
                                          attribute: .right,
                                          relatedBy: .equal,
                                          toItem: contentView,
                                          attribute: .right,
                                          multiplier: 1,
                                          constant: -Constants.headerInsets.right))
    // summary label top
    constraints.append(NSLayoutConstraint(item: summaryLabel,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: titleLabel,
                                          attribute: .bottom,
                                          multiplier: 1,
                                          constant: Constants.summaryLabelTopSpacing))
    // summary label left
    constraints.append(NSLayoutConstraint(item: summaryLabel,
                                          attribute: .left,
                                          relatedBy: .equal,
                                          toItem: contentView,
                                          attribute: .left,
                                          multiplier: 1,
                                          constant: Constants.headerInsets.left))
    // summary label right
    constraints.append(NSLayoutConstraint(item: summaryLabel,
                                          attribute: .right,
                                          relatedBy: .equal,
                                          toItem: contentView,
                                          attribute: .right,
                                          multiplier: 1,
                                          constant: -Constants.headerInsets.right))
    // view map button right
    constraints.append(NSLayoutConstraint(item: viewMapButton,
                                          attribute: .right,
                                          relatedBy: .equal,
                                          toItem: contentView,
                                          attribute: .right,
                                          multiplier: 1,
                                          constant: -16))
    // view map button bottom
    constraints.append(NSLayoutConstraint(item: viewMapButton,
                                          attribute: .bottom,
                                          relatedBy: .equal,
                                          toItem: contentView,
                                          attribute: .bottom,
                                          multiplier: 1,
                                          constant: -16))
    // view sessions button right
    constraints.append(NSLayoutConstraint(item: viewSessionsButton,
                                          attribute: .right,
                                          relatedBy: .equal,
                                          toItem: viewMapButton,
                                          attribute: .left,
                                          multiplier: 1,
                                          constant: 0))
    // view sessions button bottom
    constraints.append(NSLayoutConstraint(item: viewSessionsButton,
                                          attribute: .bottom,
                                          relatedBy: .equal,
                                          toItem: contentView,
                                          attribute: .bottom,
                                          multiplier: 1,
                                          constant: -16))

    contentView.addConstraints(constraints)
  }
  // swiftlint:enable function_body_length

  override func layoutSubviews() {
    super.layoutSubviews()

    // Support dynamic type
    let font = Constants.summaryLabelFont()
    if font.pointSize != summaryLabel.font.pointSize {
      summaryLabel.font = font
    }
  }

  // Don't show ink view on this cell.
  override var inkView: MDCInkView? {
    get { return nil }
    set {}
  }

  @available(*, unavailable)
  required init(coder: NSCoder) {
    fatalError("NSCoding not supported for cell of type \(EventInfoCollectionViewCell.self)")
  }

}

// MARK: - Buttons

extension EventInfoCollectionViewCell {

  @objc fileprivate func buttonPressed(_ sender: Any) {
    guard let button = sender as? UIButton else { return }

    let action: String

    switch button {

    case viewSessionsButton:
      Application.sharedInstance.rootNavigator.navigateToSchedule()
      action = "view sessions"

    case viewMapButton:
      Application.sharedInstance.rootNavigator.navigateToMap(roomId: nil)
      action = "view maps"

    case _:
      return
    }

    guard let title = title else { return }
    Application.sharedInstance.analytics.logEvent(AnalyticsEventSelectContent, parameters: [
      AnalyticsParameterItemID: title,
      AnalyticsParameterContentType: AnalyticsParameters.uiEvent,
      AnalyticsParameters.uiAction: action
    ])
  }

}
