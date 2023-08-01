//
//  VFL.swift
//  Created by Sidharth Juyal on 31/12/2022.
//
#if os(macOS)
import AppKit
public typealias VFLView = NSView
#else
import UIKit
public typealias VFLView = UIView
#endif

public class VFL {
  public private(set) var views: [String: VFLView] = [:]
  public private(set) var parentView: VFLView?
  public private(set) var options: NSLayoutConstraint.FormatOptions = []
  public private(set) var metrics: [String: CGFloat] = [:]
  public private(set) var constraints: [NSLayoutConstraint] = []
  public private(set) var formats:[String: [String]] = [:]
  
  public init(_ view: VFLView? = nil) {
    parentView = view
  }

  @discardableResult
  public func setParent(_ view: VFLView) -> VFL {
    parentView = view
    return self
  }

  @discardableResult
  public func add(subview: VFLView, name: String) -> VFL {
    addSubview(subview)
    subview.translatesAutoresizingMaskIntoConstraints = false
    views[name] = subview
    return self
  }
  
  @discardableResult
  public func addSubview(_ subview: VFLView) -> VFL {
    assert(parentView != nil)
    parentView?.addSubview(subview)
    return self
  }
  
  @discardableResult
  public func addOptions(_ options: NSLayoutConstraint.FormatOptions) -> VFL {
    self.options.formUnion(options)
    return self
  }
  
  @discardableResult
  public func removeAllOptions() -> VFL {
    self.options = []
    return self
  }

  
  @discardableResult
  public func addMetrics(_ metrics: [String: CGFloat]) -> VFL {
    self.metrics.merge(metrics) { $1 }
    return self
  }

  @discardableResult
  public func removeAllMetrics() -> VFL {
    self.metrics = [:]
    return self
  }
  
  @discardableResult
  public func storeConstraints(formats: [String], name: String) -> VFL {
    self.formats[name] = formats
    return self
  }
  
  @discardableResult
  public func applyConstraints(name: String) -> VFL {
    guard let formats = self.formats[name] else {
      assertionFailure("No cached format found with name \(name)")
      return self
    }
    applyConstraints(formats: formats)
    return self
  }

  @discardableResult
  public func applyConstraints(formats: [String]) -> VFL {
    applyConstraints(constraints: formats.flatMap {
      NSLayoutConstraint.constraints(
        withVisualFormat: $0,
        options: options,
        metrics: metrics,
        views: views
      )
    })
    return self
  }
  
  @discardableResult
  public func applyConstraints(constraints: [NSLayoutConstraint]) -> VFL {
    NSLayoutConstraint.activate(constraints)
    self.constraints.append(contentsOf: constraints)
    return self
  }

  @discardableResult
  public func removeAllConstraints() -> VFL {
    NSLayoutConstraint.deactivate(self.constraints)
    self.constraints = []
    return self
  }

  @discardableResult
  public func removeAll() -> VFL {
    removeAllConstraints()
    removeAllMetrics()
    removeAllOptions()
    return self
  }
}

// Convenience Utils
extension VFL {
  @discardableResult
  public func appendConstraints(
    options: NSLayoutConstraint.FormatOptions = [],
    metrics: [String: CGFloat] = [:],
    formats: [String]
  ) -> VFL {
    addOptions(options)
    addMetrics(metrics)
    applyConstraints(formats: formats)
    return self
  }
  
  @discardableResult
  public func appendConstraints(_ constraints: [NSLayoutConstraint]) -> VFL {
    applyConstraints(constraints: constraints)
    return self
  }
}
