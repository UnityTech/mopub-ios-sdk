//
//  ContainerViewController.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

class ContainerViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var menuContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuDismissButton: UIButton!
    
    // MARK: - Properties
    
    /**
     Main TabBar Controller of the app.
     */
    private(set) var mainTabBarController: MainTabBarController? = nil
    
    /**
     Menu TableView Controller of the app.
     */
    private(set) var menuViewController: MenuViewController? = nil
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // When the children view controllers are loaded, each will perform
        // a segue which we must capture to initialize the view controller
        // properties.
        switch segue.identifier {
        case "onEmbedTabBarController":
            mainTabBarController = segue.destination as? MainTabBarController
            break
        case "onEmbedMenuController":
            menuViewController = segue.destination as? MenuViewController
            break
        default:
            break
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        if #available(iOS 11.0, *) {
            // Do not adjust the content insets of the scroll view to accommodate
            // the safe area since we want the container scroll view to go edge
            // to edge.
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        // Initially close menu programmatically. This needs to be done on the main thread initially in order to work.
        DispatchQueue.main.async() {
            self.closeMenu(animated: false)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) -> Void in
            self.closeMenu(animated: true)
        }, completion: nil)
    }

    // MARK: - Menu
    
    func closeMenu(animated: Bool = true) {
        // Use scrollview content offset-x to slide the menu.
        scrollView.setContentOffset(CGPoint(x: menuContainerWidthConstraint.constant, y: 0), animated: animated)
        mainTabBarController?.view.isUserInteractionEnabled = true
        menuDismissButton.isUserInteractionEnabled = false
    }
    
    var isMenuOpen: Bool {
        return scrollView.contentOffset.x < menuContainerWidthConstraint.constant
    }
    
    // Open is the natural state of the menu because of how the storyboard is setup.
    func openMenu() {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        mainTabBarController?.view.isUserInteractionEnabled = false
        menuDismissButton.isUserInteractionEnabled = true
    }
    
    @IBAction func onDismissMenu(_ sender: Any) {
        if isMenuOpen {
            closeMenu(animated: true)
        }
    }
}

extension ContainerViewController : UIScrollViewDelegate {
    // http://www.4byte.cn/question/49110/uiscrollview-change-contentoffset-when-change-frame.html
    // When paging is enabled on a Scroll View,
    // a private method _adjustContentOffsetIfNecessary gets called,
    // presumably when present whatever controller is called.
    // The idea is to disable paging.
    // But we rely on paging to snap the slideout menu in place
    // (if you're relying on the built-in pan gesture).
    // So the approach is to keep paging disabled.
    // But enable it at the last minute during scrollViewWillBeginDragging.
    // And then turn it off once the scroll view stops moving.
    //
    // Approaches that don't work:
    // 1. automaticallyAdjustsScrollViewInsets -- don't bother
    // 2. overriding _adjustContentOffsetIfNecessary -- messing with private methods is a bad idea
    // 3. disable paging altogether.  works, but at the loss of a feature
    // 4. nest the scrollview inside UIView, so UIKit doesn't mess with it.  may have worked before,
    //    but not anymore.
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.isPagingEnabled = true
        mainTabBarController?.view.isUserInteractionEnabled = false
        menuDismissButton.isUserInteractionEnabled = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.isPagingEnabled = false
        mainTabBarController?.view.isUserInteractionEnabled = !isMenuOpen
        menuDismissButton.isUserInteractionEnabled = isMenuOpen
    }
}
