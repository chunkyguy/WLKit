#if os(macOS)
import AppKit

public typealias WLView = NSView
public typealias WLViewController = NSViewController
public typealias WLResponder = NSResponder
#else
import UIKit

public typealias WLView = UIView
public typealias WLViewController = UIViewController
public typealias WLResponder = UIResponder
#endif
