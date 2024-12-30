//  Created by Brice Pollock for Canyoneer on 11/30/23

import SwiftUI
import WebKit
import MapKit

@MainActor
class CanyonDetailViewModel: NSObject, ObservableObject {
    
    @Published var webViewHeight: CGFloat = 200
    
    let canyonName: String
    let canyonCoordinate: String
    let canyonSummary: String
    let ropeWikiURL: URL?
    let starViewModel: StarQualityViewModel
    let tableData: DataTableViewModel
    let bestMonths: BestSeasonsViewModel
    let htmlString: String
    
    /// If we have a `mapDelegate`, then we show the button to go this canyon on the main map
    let showOnMapVisible: Bool
    
    let weatherViewModel: WeatherForecastViewModel
    
    private let canyon: Canyon
    private weak var mapDelegate: MainMapDelegate?
    
    init(canyon: Canyon, weatherViewModel: WeatherViewModel, mapDelegate: MainMapDelegate?) {
        self.canyon = canyon
        self.mapDelegate = mapDelegate
        self.showOnMapVisible = mapDelegate != nil
        
        self.canyonName = canyon.name
        self.canyonCoordinate = canyon.coordinate.asString
        self.canyonSummary = canyon.technicalSummary
        self.ropeWikiURL = canyon.ropeWikiURL
        self.starViewModel = StarQualityViewModel(quality: canyon.quality)
        
        self.tableData = DataTableViewModel(canyon: canyon)
        self.bestMonths = BestSeasonsViewModel(
            selections: Set(canyon.bestSeasons),
            isUserInteractionEnabled: false
        )
        self.weatherViewModel = WeatherForecastViewModel(for: canyon.coordinate, weatherViewModel: weatherViewModel)
                
        // html render of the description
        let header = "<head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></head>"
        var htmlString = "<html>" + header + "<body>" + canyon.description + "</body></html>"
        htmlString = htmlString.replacingOccurrences(of: "<span class=\"mw-headline\"", with: "<h1")
        self.htmlString = htmlString.replacingOccurrences(of: "</span>", with: "</h1>")
    }
    
    public func launchRopeWikiURL() {
        guard let url = ropeWikiURL else { return }
        UIApplication.shared.open(url)
    }
    
    @MainActor
    public func showOnMap() {
        // Zoom level was chosen by hand for something like Behunin which has a lot of conflicting pins, to be close enough for the name to show up.
        mapDelegate?.updateCenter(to: canyon.coordinate.asCLObject, zoomLevel: 13, animated: false)
    }
    
    public func launchDirections() {
        let coordinate = CLLocationCoordinate2DMake(canyon.coordinate.latitude, canyon.coordinate.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = canyon.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
}

extension CanyonDetailViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { [weak self] (height, error) in
                    self?.webViewHeight = height as! CGFloat
                })
            }

            })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if var url = navigationAction.request.url, url.absoluteString != "about:blank"{
            if url.absoluteString.hasPrefix("/") {
                url = URL(string: "http://www.ropewiki.com" + url.absoluteString)!
            }
            decisionHandler(.cancel)
            UIApplication.shared.open(url)
        } else {
            decisionHandler(.allow)
        }
    }
}
