#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Any event
public protocol ViewEvent {}

/// Any event handler
public protocol ViewEventHandler: AnyObject {
  func handle(event: ViewEvent, sender: WLView?)
}

/// Any view that can emit event
open class EventView: WLView {
  public weak var eventHandler: ViewEventHandler? {
    didSet {
      subviews.forEach { forwardEventHandlerToSubview($0) }
    }
  }
  
  public init(eventHandler: ViewEventHandler? = nil, frame: CGRect) {
    self.eventHandler = eventHandler
    super.init(frame: frame)
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open override func didAddSubview(_ subview: WLView) {
    super.didAddSubview(subview)
    forwardEventHandlerToSubview(subview)
  }
  
  private func forwardEventHandlerToSubview(_ subview: WLView) {
    guard let eventVw = subview as? EventView else { return }
    guard eventVw.eventHandler == nil else { return }
    eventVw.eventHandler = eventHandler
  }
}

/// Any view with a view model
open class View<ViewModel>: EventView {
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

#if !os(macOS)
private let contentViewBindableTag = Int.max

/// Any view type that if provides a contentView get a view that fills the content
public protocol ContentViewBindable: AnyObject {
  var contentView: UIView { get }
}

extension ContentViewBindable {
  /// When set replaces the content
  public var view: UIView? {
    get { contentView.viewWithTag(contentViewBindableTag) }
    
    set {
      if let oldView = contentView.viewWithTag(contentViewBindableTag) {
        oldView.removeFromSuperview()
      }
      
      if let newView = newValue {
        VFL(contentView)
          .add(subview: newView, name: "view")
          .applyConstraints(formats: ["H:|[view]|", "V:|[view]|"])
        newView.tag = contentViewBindableTag
      }
    }
  }
}

open class ContainerView: UIView, ContentViewBindable {
  public var contentView: UIView { self }
}
open class TableViewCell: UITableViewCell, ContentViewBindable {}
open class TableViewHeaderFooterView: UITableViewHeaderFooterView, ContentViewBindable {}
open class CollectionCell: UICollectionViewCell, ContentViewBindable {}
open class CollectionReusableView: UICollectionReusableView, ContentViewBindable {
  public var contentView: UIView { self }
}
#endif
