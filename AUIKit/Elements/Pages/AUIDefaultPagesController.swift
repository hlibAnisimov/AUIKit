//
//  PagesViewController.swift
//  Level
//
//  Created by Ihor Myroniuk on 8/30/18.
//  Copyright © 2018 Brander. All rights reserved.
//

import UIKit

open class AUIDefaultPagesController: AUIDefaultViewController, AUIPagesViewController {
  
  // MARK: Delegates
  
  open var didTransitToPageObservers = NSHashTable<AnyObject>.weakObjects()
  
  public func addDidTransitToPageObserver(_ observer: AUIPagesViewControllerDidTransitToPageObserver) {
    didTransitToPageObservers.add(observer)
  }
  
  public func removeDidTransitToPageObserver(_ observer: AUIPagesViewControllerDidTransitToPageObserver) {
    didTransitToPageObservers.remove(observer)
  }
  
  private let pageViewControllerDataSourceDelegate = AUIPageViewControllerDataSourceDelegateProxy()
  
  // MARK: Controllers
  
  private var pagesViewController: AUISelfLayoutPageViewController?
  open var pageControllers: [AUIPageViewController] = []
  
  // MARK: Initializer
  
  public init(transitionStyle: UIPageViewController.TransitionStyle = .scroll,
       navigationOrientation: UIPageViewController.NavigationOrientation = .vertical) {
    self.transitionStyle = transitionStyle
    self.navigationOrientation = navigationOrientation
    self.options = [:]
  }
  
  // MARK: State
  
  private var transitionStyle: UIPageViewController.TransitionStyle
  private var navigationOrientation: UIPageViewController.NavigationOrientation
  private var options: [UIPageViewController.OptionsKey : Any]
  
  open var pagesCount: Int { return pageControllers.count }
  open var currentPageNumbers: [Int] {
    guard let containerPageViewControllers = pagesViewController?.viewControllers as? [AUIContainerPageViewController] else { return [] }
    let pageControllerViewControllers = containerPageViewControllers.map { $0.viewController }
    var currentPageNumbers: [Int] = []
    pageControllers.enumerated().forEach { (index, pageController) in
      if pageControllerViewControllers.contains(where: { $0 === pageController.viewController }) { currentPageNumbers.append(index)  }
    }
    return currentPageNumbers
  }
  open var currentPageControllers: [AUIPageViewController] {
    let currentPageNumbers = self.currentPageNumbers
    return pageControllers.enumerated().filter({ currentPageNumbers.contains($0.offset) }).map({$1})
  }
  
  // MARK: Setup
  
  open override func setup() {
    super.setup()
    pageViewControllerDataSourceDelegate.delegate = self
    setupPageViewController()
  }
  
  open func setupPageViewController() {
    pagesViewController?.dataSource = pageViewControllerDataSourceDelegate
    pagesViewController?.delegate = pageViewControllerDataSourceDelegate
  }
  
  open override func setupView() {
    super.setupView()
    guard let view = view else { return }
    let pagesViewController = AUISelfLayoutPageViewController(containerView: view, transitionStyle: transitionStyle, navigationOrientation: navigationOrientation, options: options)
    self.pagesViewController = pagesViewController
    setupPageViewController()
    reload()
  }
  
  open override func unsetupView() {
    super.unsetupView()
    pagesViewController?.view.removeFromSuperview()
    pagesViewController = nil
  }
  
  // MARK: Reloal
  
  open func reload() {
    guard let pageViewController = pageControllers.first else { return }
    let pageViewController2 = pageControllers[1]
    let containerPageViewController = AUIContainerPageViewController(viewController: pageViewController.viewController,
                                                                     view: pageViewController.view())
    let containerPageViewController2 = AUIContainerPageViewController(viewController: pageViewController2.viewController,
                                                                     view: pageViewController2.view())
    pagesViewController?.setViewControllers([containerPageViewController, containerPageViewController2], direction: .forward, animated: false, completion: nil)
    for object in didTransitToPageObservers.allObjects {
      guard let observer = object as? AUIPagesViewControllerDidTransitToPageObserver else { continue }
      observer.pagesViewController(self, didTransitToPageViewControllers
        
        : currentPageControllers)
    }
  }
  
  // MARK: Events
  
  open func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    print("before")
    guard let beforeContainerPageViewController = viewController as? AUIContainerPageViewController else { return nil }
    let beforePageViewController = beforeContainerPageViewController.viewController
    guard let beforeIndex = pageControllers.index(where: { beforePageViewController === $0.viewController}) else { return nil }
    guard beforeIndex > 0 else { return nil }
    let pageViewController = pageControllers[beforeIndex - 1]
    
    
    let containerPageViewController = AUIContainerPageViewController(viewController: pageViewController.viewController, view: pageViewController.view())
    return containerPageViewController
  }
  
  open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    print("after")
    guard let afterContainerPageViewController = viewController as? AUIContainerPageViewController else { return nil }
    let afterPageViewController = afterContainerPageViewController.viewController
    guard let afterIndex = pageControllers.index(where: { afterPageViewController === $0.viewController}) else { return nil }
    guard afterIndex < pageControllers.count - 1 else { return nil }
    let pageViewController = pageControllers[afterIndex + 1]
    
    
    let containerPageViewController = AUIContainerPageViewController(viewController: pageViewController.viewController, view: pageViewController.view())
    return containerPageViewController
  }
  
  open func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    print("finish")
    for object in didTransitToPageObservers.allObjects {
      guard let observer = object as? AUIPagesViewControllerDidTransitToPageObserver else { continue }
      observer.pagesViewController(self, didTransitToPageViewControllers: currentPageControllers)
    }
  }
  
}

private class AUIPageViewControllerDataSourceDelegateProxy: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  
  weak var delegate: AUIDefaultPagesController?
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    return delegate?.pageViewController(pageViewController, viewControllerBefore: viewController)
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    return delegate?.pageViewController(pageViewController, viewControllerAfter: viewController)
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    delegate?.pageViewController(pageViewController, didFinishAnimating: finished, previousViewControllers: previousViewControllers, transitionCompleted: completed)
  }
  
}

private class AUISelfLayoutPageViewController: UIPageViewController {
  
  // MARK: Elements
  
  let containerView: UIView
  
  // MARK: Initializer
  
  init(containerView: UIView, transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
    self.containerView = containerView
    super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
    containerView.addSubview(view)
    isDoubleSided = true
  }
  
  required init?(coder: NSCoder) { return nil }
  
  // MARK: Layout
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    view.frame = view.superview?.bounds ?? .zero
  }
  
}

private class AUIContainerPageViewController: UIViewController {
  
  // MARK: Controllers
  
  var viewController: AUIViewController
  
  // MARK: Initializers
  
  init(viewController: AUIViewController, view: UIView) {
    self.viewController = viewController
    super.init(nibName: nil, bundle: nil)
    self.view = view
    setup()
  }
  
  @available(*, unavailable)
  convenience required init?(coder aDecoder: NSCoder) { return nil }
  
  // MARK: Setup
  
  func setup() {
    viewController.view = view
  }
  
  deinit {
    viewController.view = nil
  }
}

