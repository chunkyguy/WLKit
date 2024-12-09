import Foundation
import CoreGraphics

/// Any event
public protocol ViewEvent {}

/// Any event handler
public protocol ViewEventHandler: AnyObject {
  func handle(event: ViewEvent, sender: WLView?)
}

public extension WLResponder {
  var eventHandler: ViewEventHandler? {
#if os(macOS)
    (self as? ViewEventHandler) ?? nextResponder?.eventHandler
#else
    (self as? ViewEventHandler) ?? next?.eventHandler
#endif
  }
}

/// Any view with a view model
open class View<ViewModel>: WLView {
  public var viewModel: ViewModel {
    didSet {
      if isSetUp {
        viewModelDidUpdate()
      }
    }
  }
  
  public private(set) var isSetUp: Bool
  
  public init(viewModel: ViewModel, frame: CGRect) {
    self.viewModel = viewModel
    self.isSetUp = false
    super.init(frame: frame)
    if !frame.isEmpty {
      setUpIfNeeded()
    }
  }
  
  public convenience init(_ viewModel: ViewModel) {
    self.init(viewModel: viewModel, frame: CGRect.zero)
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
#if os(macOS)
  open override func layout() {
    super.layout()
    setUpIfNeeded()
  }
#else
  open override func layoutSubviews() {
    super.layoutSubviews()
    setUpIfNeeded()
  }
#endif
  
  private func setUpIfNeeded() {
    if !isSetUp {
      isSetUp = true
      setUp()
      viewModelDidUpdate()
    }
  }
  
  open func setUp() {}
  
  open func viewModelDidUpdate() {}
}

/// Any view controller with a view model
open class ViewController<ViewModel>: WLViewController {
  
  public init(_ viewModel: ViewModel) {
    self.viewModel = viewModel
    isSetUp = false
    super.init(nibName: nil, bundle: nil)
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public var viewModel: ViewModel {
    didSet {
      if isSetUp {
        viewModelDidUpdate()
      }
    }
  }
  
  public private(set) var isSetUp: Bool
  
#if os(macOS)
  open override func viewDidLayout() {
    super.viewDidLayout()
    setUpIfNeeded()
  }
#else
  open override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    setUpIfNeeded()
  }
#endif
  
  private func setUpIfNeeded() {
    if !isSetUp {
      isSetUp = true
      setUp()
      viewModelDidUpdate()
    }
  }
  
  open func setUp() {}
  
  open func viewModelDidUpdate() {}
}

