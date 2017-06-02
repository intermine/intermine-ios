//
//  WebViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/25/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class WebViewController: BaseViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView?
    
    private var urlString: String?
    private var spinner: NVActivityIndicatorView?
    
    private var searchResult: SearchResult?
    
    // MARK: Load from storyboard
    
    class func webViewController(withSearchResult: SearchResult) -> WebViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WebVC") as? WebViewController
        vc?.searchResult = withSearchResult
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView?.delegate = self
        self.spinner = NVActivityIndicatorView(frame: self.indicatorFrame(), type: .ballSpinFadeLoader, color: Colors.apple, padding: self.indicatorPadding())
        if let spinner = self.spinner {
            self.view.addSubview(spinner)
            self.view.bringSubview(toFront: spinner)
        }
        self.spinner?.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let searchResult = self.searchResult,
            let mineName = searchResult.getMineName(),
            let id = searchResult.getId() {
            if let mine = CacheDataStore.sharedCacheDataStore.findMineByName(name: mineName) {
                if let mineUrl = mine.url {
                    let urlString = mineUrl + Endpoints.report + "?id=\(id)"
                    if let url = NSURL(string: urlString) as URL? {
                        let request = NSURLRequest(url: url)
                        AppManager.sharedManager.shouldBreakLoading = true
                        self.webView?.loadRequest(request as URLRequest)
                    }
                }
            }
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("error: \(error)")
        self.spinner?.stopAnimating()
        self.alert(message: String.localize("Webview.Loading.Error"))
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.spinner?.stopAnimating()
    }
    
    // MARK: Private methods
    
    private func indicatorFrame() -> CGRect {
        if let navbarHeight = self.navigationController?.navigationBar.frame.size.height, let tabbarHeight = self.tabBarController?.tabBar.frame.size.height {
            let viewHeight = BaseView.viewHeight(view: self.view)
            let indicatorHeight = viewHeight - (tabbarHeight + navbarHeight)
            let indicatorWidth = BaseView.viewWidth(view: self.view)
            return CGRect(x: 0, y: 0, width: indicatorWidth, height: indicatorHeight)
        } else {
            return self.view.frame
        }
    }

    private func indicatorPadding() -> CGFloat {
        return BaseView.viewWidth(view: self.view) / 2.5
    }

}
