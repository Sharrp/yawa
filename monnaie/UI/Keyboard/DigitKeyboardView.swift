//
//  KeyboardView.swift
//  decimal-keyboard
//
//  Created by Anton Vronskii on 2018/06/26.
//  Copyright © 2018 Anton Vronskii. All rights reserved.
//

import UIKit

extension String {
  subscript(_ range: CountableRange<Int>) -> String {
    let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
    let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
    return String(self[idx1..<idx2])
  }
}

extension UIButton {
  private func imageWithColor(color: UIColor) -> UIImage? {
    let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    
    context?.setFillColor(color.cgColor)
    context?.fill(rect)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image
  }
  
  func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
    self.setBackgroundImage(imageWithColor(color: color), for: state)
  }
}

class DigitKeyboardView: UIView {
  @IBOutlet weak var contentView: UIView!
  @IBOutlet var buttons: [UIButton]!
  @IBOutlet weak var deleteButton: UIButton!
  @IBOutlet weak var dotButton: UIButton!
  
  var dotAvailable: Bool = true {
    didSet {
      dotButton.isHidden = !dotAvailable
    }
  }
  private var deleteTimer: Timer?
  
  weak var heightContraint: NSLayoutConstraint! {
    didSet {
      let margin: CGFloat = 6
      let height = (buttons[0].frame.height + margin) * 4 - margin
      heightContraint.constant = height
      setNeedsUpdateConstraints()
    }
  }
  
  weak var textField: UITextField? {
    didSet {
      textField?.inputView = UIView()
      textField?.becomeFirstResponder()
    }
  }
  
  var backspaceEnabled: Bool? {
    get {
      return deleteButton.isEnabled
    }
    set {
      deleteButton.isEnabled = newValue!
      deleteButton.isHidden = !(newValue!)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  private func commonInit() {
    Bundle.main.loadNibNamed("DigitKeyboardView", owner: self, options: nil)
    addSubview(contentView)
    contentView.frame = self.bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }
  
  override func awakeFromNib() {
    contentView.backgroundColor = .clear
    for button in buttons {
      button.layer.cornerRadius = 5
      button.clipsToBounds = true
      button.setBackgroundColor(Color.cellBackground, for: .highlighted)
    }
    
    let longTap = UILongPressGestureRecognizer(target: self, action: #selector(longTapHandler(longTap:)))
    longTap.minimumPressDuration = 0.3
    deleteButton.addGestureRecognizer(longTap)
  }
  
  private func removeLastCharacter() {
    textField?.deleteBackward()
  }
  
  /// Event handling
  
  @IBAction func digitTouchUp(sender: UIButton) {
    textField?.insertText("\(sender.tag)")
  }
  
  @IBAction func backspaceTouchUp(sender: UIButton) {
    guard let text = textField?.text else { return }
    guard text.count > 0 else { return }
    if text == "0." {
      // Remove twice to generate EditingChanged (instead of text = "")
      removeLastCharacter()
    }
    removeLastCharacter()
  }
  
  @IBAction func dotTouchUp(sender: UIButton) {
    guard let text = textField?.text else { return }
    if text.count <= 0 {
      textField?.insertText("0.")
      return
    }
    
    if !text.contains(".") {
      textField?.insertText(".")
    }
  }
  
  @objc func longTapHandler(longTap: UILongPressGestureRecognizer) {
    switch longTap.state {
    case .began:
      removeLastCharacter()
      deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
        self?.removeLastCharacter()
      }
    case .cancelled, .ended, .failed:
      deleteTimer?.invalidate()
      deleteTimer = nil
    default:
      break
    }
    
  }
}
