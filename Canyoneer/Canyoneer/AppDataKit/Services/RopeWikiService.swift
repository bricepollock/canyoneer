//
//  RopeWikiService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import RxSwift
import MapKit

struct RopeWikiService {
    func canyons() -> Single<[Canyon]> {
        return loadFromFile()
//        return self.canyons(with: self.regions())
    }
    
    func regions() -> [Region] {
        return [
            Self.california,
            Self.utah
        ]
    }
    
    func loadFromFile() -> Single<[Canyon]> {
        let decoder = JSONDecoder()
        let fileName = "ropewiki_database"
        let bundle = Bundle(for: RxUIButton.self)
        
        return Single.create { single in
            do {
                guard let path = bundle.path(forResource: fileName, ofType: "json") else {
                    throw RequestError.serialization
                }

                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let canyonDataList = try decoder.decode([CanyonDataPoint].self, from: jsonData)
                let canyons: [Canyon] = canyonDataList.compactMap { data in
                    guard let latitude = data.latitude, let longitude = data.longitude else {
                        return nil
                    }
                    return Canyon(
                        coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                        maxRapLength: data.rappelMaxLength,
                        name: data.name,
                        numRaps: data.numRappels
                    )
                }
                single(.success(canyons))
                return Disposables.create()
            } catch {
                Global.logger.error("Serialization Error: \(String(describing: error))")
                single(.failure(RequestError.serialization))
                return Disposables.create()
            }
        }
    }
    
    private func canyons(with regions: [Region]) -> [Canyon] {
        return regions.flatMap { region in
            return self.canyons(for: region)
        }
    }
    
    private func canyons(for region: Region) -> [Canyon] {
        guard region.canyons.isEmpty else {
            return region.canyons
        }
        return self.canyons(with: region.children)
    }
}
