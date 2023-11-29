//
//  WebView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 11/28/23.
//

import Foundation
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let htmlString: String
    let delegate: WKNavigationDelegate?

    func makeUIView(context: Context) -> WKWebView {
        let webview = WKWebView()
        webview.navigationDelegate = delegate
        return webview
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
}
