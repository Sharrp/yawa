//
//  TransactionCell.swift
//  monnaie
//
//  Created by Anton Vronskii on 2018/05/09.
//  Copyright © 2018 Anton Vronskii. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {
  @IBOutlet weak var emojiLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var authorLabel: UILabel!
  @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var bottomBorder: UIView!
  
  var isFirst = false
  var isLast = false {
    didSet {
      bottomBorder.isHidden = isLast
    }
  }
  
  private let sideInset: CGFloat = 8
  private let cornerRadius: CGFloat = 8
  private let shapeLayer = CALayer()
  
  static var shadowInset: CGFloat {
    return 2 * Layout.shadowRadius
  }
  
  private func setupCell() {
    layer.masksToBounds = false
    layer.shadowOffset = Layout.shadowOffset
    layer.shadowColor = Color.shadowColor.cgColor
    layer.shadowRadius = Layout.shadowRadius
    layer.shadowOpacity = 1
    
    layer.insertSublayer(shapeLayer, at: 0)
    
    backgroundColor = nil
    layer.backgroundColor = UIColor.clear.cgColor
    shapeLayer.backgroundColor = UIColor.white.cgColor
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupCell()
  }
  
  override var frame: CGRect {
    get {
      return super.frame
    }
    set (newFrame) {
      let yAddition = isFirst ? TransactionCell.shadowInset : 0
      
      // UITableViewDelegate will add shadowInset for each shadow (top and bottom)
      // so frame of the cell itself should be smaller
      var heightChange: CGFloat = 0
      if isFirst {
        heightChange -= TransactionCell.shadowInset
      }
      if isLast {
        heightChange -= TransactionCell.shadowInset
      }
      super.frame = CGRect(x: newFrame.origin.x + sideInset, y: newFrame.origin.y + yAddition,
                           width: newFrame.width - 2 * sideInset, height: newFrame.height + heightChange)
    }
  }
  
  private func roundedCorners(isFirst: Bool, isLast: Bool) -> UIRectCorner {
    var corners: UIRectCorner = []
    if isFirst {
      corners.insert(.topLeft)
      corners.insert(.topRight)
    }
    if isLast {
      corners.insert(.bottomLeft)
      corners.insert(.bottomRight)
    }
    return corners
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    let corners = roundedCorners(isFirst: isFirst, isLast: isLast)
    
    // For the non-first row we extend shadow to the top so we won't see shadow's top rounded corners (they will be masked)
    let topShadowInset = !isFirst ? -cornerRadius : 0
    let bottomShadowInset = !isLast ? -cornerRadius : 0
    let shadowRect = bounds.inset(by: UIEdgeInsets(top: topShadowInset, left: 0, bottom: bottomShadowInset, right: 0))
    let shadowPath = UIBezierPath(roundedRect: shadowRect, byRoundingCorners: corners,
                                  cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
    layer.shadowPath = shadowPath
    
    // Shadow mask
    let topShadowMaskInset = isFirst ? TransactionCell.shadowInset : 0
    let bottomShadowMaskInset = isLast ? TransactionCell.shadowInset : 0
    let shadowMaskRect = CGRect(x: -TransactionCell.shadowInset, y: -topShadowMaskInset,
                                width: bounds.width + 2*TransactionCell.shadowInset, height: bounds.height + topShadowMaskInset + bottomShadowMaskInset)
    let shadowMaskLayer = CAShapeLayer()
    shadowMaskLayer.path = UIBezierPath(rect: shadowMaskRect).cgPath
    layer.mask = shadowMaskLayer
    
    // Visible shape
    shapeLayer.frame = layer.bounds
    let shapeMaskLayer = CAShapeLayer()
    shapeMaskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners,
                                       cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
    shapeLayer.mask = shapeMaskLayer
  }
}

class SummaryCell: UITableViewCell {
  @IBOutlet weak var emojiLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var chartBarWidth: NSLayoutConstraint!
  @IBOutlet weak var valueLabel: UILabel! // amount or percentage
  
  var level: Double = 0 {
    didSet {
      setNeedsUpdateConstraints()
    }
  }
  private let minChartBarWidth: CGFloat = 8
  
  override func updateConstraints() {
    super.updateConstraints()
    let maxChartBarWidth = valueLabel.frame.maxX - categoryLabel.frame.origin.x
    let barWidth = maxChartBarWidth * CGFloat(level)
    chartBarWidth.constant = max(minChartBarWidth, barWidth)
  }
}

class MonthSwitchCell: UICollectionViewCell {
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var monthLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  func setState(textActiveLevel: CGFloat, backgroundAlpha alpha: CGFloat) {
    let color = Color.accentText.withAlphaComponent(0.2 + 0.6 * textActiveLevel)
    amountLabel.textColor = color
    monthLabel.textColor = color
    backgroundColor = Color.cellBackground.withAlphaComponent(alpha)
  }
}
