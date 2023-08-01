#if os(macOS)
import AppKit
public typealias OSView = NSView
#else
import UIKit
public typealias OSView = UIView
#endif

public protocol ViewEvent {}

public protocol ViewEventHandler: AnyObject {
  func handle(event: ViewEvent, sender: OSView?)
}

public class EventView: OSView {
  public weak var eventHandler: ViewEventHandler? {
    didSet {
      subviews.forEach { ($0 as? EventView)?.eventHandler = eventHandler }
    }
  }
  
  public init(eventHandler: ViewEventHandler? = nil, frame: CGRect) {
    self.eventHandler = eventHandler
    super.init(frame: frame)
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

public class View<ViewModel>: EventView {
  public var viewModel: ViewModel {
    didSet {
      if isSetUp {
        viewModelDidUpdate()
      }
    }
  }
  
  public private(set) var isSetUp: Bool
  
  public init(viewModel: ViewModel, eventHandler: ViewEventHandler?, frame: CGRect? = nil) {
    self.viewModel = viewModel
    self.isSetUp = frame != nil
    super.init(eventHandler: eventHandler, frame: frame ?? .zero)
    if isSetUp {
      setUp()
    }
  }

  public convenience init(_ viewModel: ViewModel) {
    self.init(viewModel: viewModel, eventHandler: nil)
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
    }
  }
  
  open func setUp() {}
  
  open func viewModelDidUpdate() {}
}
