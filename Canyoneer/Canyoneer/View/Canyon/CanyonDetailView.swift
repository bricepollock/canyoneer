//
//  CanyonDetailView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import RxSwift
import WebKit

class CanyonDetailView: UIView {
    
    enum Strings {
        
        static let summary: String = "Summary"
        
        static let details = " Details"
        static let ropeWiki = "Ropewiki Page"
        
        static func summaryDetails(for canyon: Canyon) -> String {
            var summary = ""
            
            if let difficulty = canyon.technicalDifficulty, let water = canyon.waterDifficulty {
                summary.append("\(difficulty)\(water)")
            } else if let difficulty = canyon.technicalDifficulty {
                summary.append("\(difficulty)")
            } else if let water = canyon.waterDifficulty {
                summary.append("\(water)")
            }
            if let time = canyon.timeGrade {
                summary.append(" \(time)")
            }
            if let risk = canyon.risk {
                summary.append(" \(risk.rawValue)")
            }
            if let num = canyon.numRaps {
                summary.append(" \(num)r")
            }
            if let max = canyon.maxRapLength {
                summary.append(" ↧\(max)ft")
            }
            return summary
        }
        
        // data table strings
        static let numRaps = "Number Rappels"
        static let longestRap = "Longest Rappel"
        static let restricted = "Has Restrictions"
        static let permits = "Requires Permits"
        static let shuttle = "Shuttle Required"
        static let difficulty = "Technical Rating"
        static let risk = "Additional Risk"
        // these tabs are for alignment in the table, this is a hack-hack shortcut
        static let water = "Water Rating\t"
        static let time = "Time Grade\t"
        static let quality = "Stars"
        static let vehicle = "Vehicle"
        static let season = "Best Months"
        static let description = "Description"
        
        static func intValue(int: Int?) -> String {
            guard let int = int else { return "--" }
            return String(int)
        }
        static func boolValue(bool: Bool?) -> String {
            guard let bool = bool else { return "--" }
            return bool ? "Yes" : "No"
        }
        static func stringValue(string: String?) -> String {
            guard let string = string else { return "--" }
            return string
        }
    }
    
    static func stars(quality: Float) -> [UIImage] {
        var images = [UIImage?]()
        var remainingQuality = quality
        while remainingQuality > 0 {
            if remainingQuality >= 1 {
                images.append(UIImage(named: "emj_star_full"))
            } else if remainingQuality >= 0.5 {
                images.append(UIImage(named: "emj_star_half"))
            } // else no star because less than 0.5
            remainingQuality -= 1
        }
        return images.compactMap {
            return $0
        }
    }
    
    private let masterStackView = UIStackView()
    private let starsStackView = UIStackView()
    private let summaryStackView = UIStackView()
    private let summaryTitle = UILabel()
    private let detailStackView = UIStackView()
    private let summaryDetails = UILabel()
    private let ropeWikiURL = RxUIButton()
    private let descriptionTitle = UILabel()
    private let descriptionView = WKWebView()
    private let dataTitle = UILabel()
    private let dataTable = DataTableView()
    private let seasons = BestSeasonFilter()
    
    private var webViewHeightConstraint: NSLayoutConstraint!
    private var urlLinkDisposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero)
        
        self.addSubview(self.masterStackView)
        self.masterStackView.constrain.fillSuperview()
        
        self.masterStackView.axis = .vertical
        self.masterStackView.spacing = Grid.medium
        
        // -- render summary
        self.summaryStackView.addArrangedSubview(self.summaryTitle)
        self.summaryStackView.addArrangedSubview(self.starsStackView)
        self.summaryStackView.addArrangedSubview(UIView())  //spacer
        self.summaryStackView.backgroundColor = ColorPalette.Color.canyonRed
        self.summaryStackView.alignment = .center
        self.summaryStackView.spacing = .small
        
        // this expands the height of the summaryTitle because the size of the stars will remain constant
        self.starsStackView.constrain.height(to: self.summaryTitle, ratio: 0.8)
        // --
        
        self.detailStackView.axis = .horizontal
        self.detailStackView.addArrangedSubview(self.summaryDetails)
        self.detailStackView.addArrangedSubview(self.ropeWikiURL)
        
        self.masterStackView.addArrangedSubview(self.summaryStackView)
        self.masterStackView.addArrangedSubview(self.detailStackView)
        self.masterStackView.addArrangedSubview(self.dataTitle)
        self.masterStackView.addArrangedSubview(self.dataTable)
        self.masterStackView.addArrangedSubview(self.seasons)
        self.masterStackView.addArrangedSubview(self.descriptionTitle)
        self.masterStackView.addArrangedSubview(self.descriptionView)
        
        // initial space is for padding with background coloration
        self.summaryTitle.text = " " + Strings.summary
        self.summaryTitle.font = FontBook.Body.emphasis
        self.summaryDetails.font = FontBook.Body.regular
        self.ropeWikiURL.configure(text: Strings.ropeWiki)
        
        self.descriptionTitle.font = FontBook.Body.emphasis
        self.descriptionTitle.text = " " + Strings.description
        self.descriptionTitle.backgroundColor = ColorPalette.Color.canyonRed
        
        webViewHeightConstraint = self.descriptionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200)
        webViewHeightConstraint.isActive = true
        self.descriptionView.navigationDelegate = self
        
        self.dataTitle.font = FontBook.Body.emphasis
        self.dataTitle.backgroundColor = ColorPalette.Color.canyonRed
        self.dataTitle.text = Strings.details
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with canyon: Canyon) {
        
        self.summaryDetails.text = Strings.summaryDetails(for: canyon)
        
        // special rendering needed for array of images becuase there is no half-star emoji we could put in text
        self.starsStackView.removeAll()
        CanyonDetailView.stars(quality: canyon.quality).forEach { image in
            let imageView = UIImageView(image: image)
            imageView.constrain.width(20)
            imageView.constrain.aspect(1)
            imageView.contentMode = .scaleAspectFit
            self.starsStackView.addArrangedSubview(imageView)
        }
        
        let dataDetails = [
            (title: Strings.numRaps, value: Strings.intValue(int: canyon.numRaps)),
            (title: Strings.longestRap, value: Strings.intValue(int: canyon.maxRapLength)),
            (title: Strings.difficulty, value: Strings.intValue(int: canyon.technicalDifficulty)),
            (title: Strings.risk, value: Strings.stringValue(string: canyon.risk?.rawValue)),
            (title: Strings.water, value: Strings.stringValue(string: canyon.waterDifficulty)),
            (title: Strings.time, value: Strings.stringValue(string: canyon.timeGrade)),
            (title: Strings.restricted, value: Strings.boolValue(bool: canyon.isRestricted)),
            (title: Strings.permits, value: Strings.boolValue(bool: canyon.requiresPermit)),
            (title: Strings.shuttle, value: Strings.boolValue(bool: canyon.requiresShuttle)),
            (title: Strings.vehicle, value: Strings.stringValue(string: canyon.vehicleAccessibility?.rawValue)),
        ]
        let data = DataTableViewData(data: dataDetails)
        self.dataTable.configure(with: data)
        
        let seasonData = BestSeasonFilterData(
            name: Strings.season,
            options: Month.allCases.map {
                return SeasonSelection(name: $0.short, isSelected: canyon.bestSeasons.contains($0))
            },
            isUserInteractionEnabled: false
        )
        self.seasons.configure(with: seasonData)
        
        let header = "<head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></head>"
        var htmlString = "<html>" + header + "<body>" + canyon.description + "</body></html>"
        htmlString = htmlString.replacingOccurrences(of: "<span class=\"mw-headline\"", with: "<h1")
        htmlString = htmlString.replacingOccurrences(of: "</span>", with: "</h1>")
        self.descriptionView.loadHTMLString(htmlString, baseURL: nil)
        
        self.urlLinkDisposeBag = DisposeBag()
        self.ropeWikiURL.didSelect.subscribeOnNext { () in
            guard let url = canyon.ropeWikiURL else { return }
            UIApplication.shared.open(url)
        }.disposed(by: self.urlLinkDisposeBag)
    }
}

extension CanyonDetailView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                    self.webViewHeightConstraint.constant = height as! CGFloat
                })
            }

            })
    }
}
