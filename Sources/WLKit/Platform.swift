#if os(macOS)
import AppKit
public typealias WLView = NSView
public typealias WLViewController = NSViewController
#else
import UIKit
public typealias WLView = UIView
public typealias WLViewController = UIViewController
#endif
