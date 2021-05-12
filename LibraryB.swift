import CoreGraphics
import UIKit
import Foundation

// Uncommenting the following line makes Xcode 12.5 toolchain export CoreGraphics as expected 
// public class FixMe: UIView {}

@objc public class Foo: NSObject {
	@objc public func bar() -> CGFloat { 0 }
}