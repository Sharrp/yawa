//
//  Utilities.swift
//  monnaie
//
//  Created by Anton Vronskii on 2018/05/03.
//  Copyright © 2018 Anton Vronskii. All rights reserved.
//

import UIKit

func deviceUniqueIdentifier() -> String {
  if let uuid = UIDevice.current.identifierForVendor?.uuidString {
    return uuid
  }
  return "\(UIDevice.current.name.hash)"
}

extension FileManager {
  func removeFiles(fromDirectory dirPath: String) {
    do {
      let files = try contentsOfDirectory(atPath: dirPath)
      for fileName in files {
        let filePath = dirPath + "/" + fileName
        try removeItem(atPath: filePath)
      }
    } catch {
      print("Error while cleaning directory \(dirPath): \(error)")
    }
  }
}

func formatMoney(amount: Double, currency: Currency, symbolEnabled: Bool = true) -> String {
  let sign = symbolEnabled ? currency.sign : ""
  return NSString(format: "%@%.0f", sign, amount) as String
}

extension UIButton {
  func setBackgroundColor(color: UIColor, forState: UIControl.State) {
    UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
    UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
    UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
    let colorImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    self.setBackgroundImage(colorImage, for: forState)
  }
}

extension UIColor {
  convenience init(red: Int, green: Int, blue: Int) {
    let red = max(0, min(255, red))
    let green = max(0, min(255, green))
    let blue = max(0, min(255, blue))
    self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
  }
  
  convenience init(hex: Int) {
    self.init(
      red: (hex >> 16) & 0xFF,
      green: (hex >> 8) & 0xFF,
      blue: hex & 0xFF
    )
  }
}

extension UIImage {
  class func imageWithColor(color: UIColor) -> UIImage? {
    let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 0.5)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    color.setFill()
    UIRectFill(rect)
    guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
    UIGraphicsEndImageContext()
    return image
  }
}

extension UIView {
  func set(radius: CGFloat, forCormers corners: UIRectCorner) {
    let path = UIBezierPath(roundedRect: bounds,
                            byRoundingCorners: corners,
                            cornerRadii: CGSize(width: radius, height: radius))
    let maskLayer = CAShapeLayer()
    maskLayer.path = path.cgPath
    layer.mask = maskLayer
  }
}

extension DateFormatter {
  convenience init(dateFormat: String) {
    self.init()
    self.dateFormat = dateFormat
  }
}

typealias TimestampRange = (start: TimeInterval, end: TimeInterval)

extension Date {
  static var secondsPerDay: TimeInterval {
    return 86400
  }
  
  static var now: Date {
    return Date()
  }
  
  init?(calendar: Calendar, year: Int, month: Int, day: Int = 1, nanoseconds: Int = 0) {
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = month
    dateComponents.day = day
    dateComponents.nanosecond = nanoseconds
    guard let date = calendar.date(from: dateComponents) else { return nil }
    self = date
  }
  
  func isSame(_ granularity: Calendar.Component, asDate dateToCompare: Date) -> Bool {
    return Calendar.current.compare(self, to: dateToCompare, toGranularity: granularity) == .orderedSame
  }
  
  func date(bySettingDayTo value: Int) -> Date? {
    var components = Calendar.current.dateComponents([.day, .month, .year], from: self)
    components.day = value
    return Calendar.current.date(from: components)
  }
  
  func timestampRangeForMonth() -> TimestampRange {
    var components = DateComponents()
    components.day = 1
    components.month = Calendar.current.component(.month, from: self)
    components.year = Calendar.current.component(.year, from: self)
    let start = Calendar.current.date(from: components)!.timeIntervalSince1970
    
    let maxDayOfCurrentMonth = Calendar.current.range(of: .day, in: .month, for: self)!.count
    components.day = maxDayOfCurrentMonth
    let end = Calendar.current.date(from: components)!.timeIntervalSince1970 + Date.secondsPerDay // first second of the next month
    
    return (start: start, end: end)
  }
  
  func timestampRangeForDay() -> TimestampRange {
    let start = Calendar.current.startOfDay(for: self).timeIntervalSince1970
    return (start: start, end: start + Date.secondsPerDay)
  }
}

struct Animation {
  static let duration = 0.35
  static let durationFast = 0.3
  static let appearceWithShfit: CGFloat = 10
  static let dampingRatio: CGFloat = 0.7
  static let curve = UIView.AnimationCurve.easeInOut
  static let springTiming = UISpringTimingParameters(dampingRatio: Animation.dampingRatio)
}

struct Color {
  static let accentText = UIColor(hex: 0x333333)
  static let inactiveText = UIColor(hex: 0x737373)
  static let border = UIColor(hex: 0xD8D8D8)
  
  static let background = UIColor(hex: 0xF9F9F9)
  static let cellBackground = UIColor(hex: 0xE8E8E8)
  static let shadowColor = UIColor(white: 0.0, alpha: 0.1)
}

struct Font {
  static let main = UIFont.systemFont(ofSize: 17, weight: .medium)
  static let tabs = UIFont.systemFont(ofSize: 17, weight: .semibold)
}

struct Layout {
  static let shadowOffset = CGSize(width: 0, height: 2)
  static let shadowRadius: CGFloat = 6
}
