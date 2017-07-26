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
    
    // MARK: Load from storyboard

    class func webViewController(withUrl: String) -> WebViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WebVC") as? WebViewController
        vc?.urlString = withUrl
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
        if let urlString = self.urlString {
            if let url = NSURL(string: urlString) as URL? {
                let request = NSURLRequest(url: url)
                AppManager.sharedManager.shouldBreakLoading = true
                self.webView?.loadRequest(request as URLRequest)
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
    


}
