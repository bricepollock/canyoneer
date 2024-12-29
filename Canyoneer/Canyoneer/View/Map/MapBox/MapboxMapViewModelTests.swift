//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
import XCTest
import CoreLocation

@testable import Canyoneer

class MapboxMapViewModelTests: XCTestCase {
    func testWaypointLabelOverlap() throws {
        // Test: Red Wall Canyon (West Fork) Topo lines show up
        let viewModel = MapboxMapViewModel()
        
        let waypointCoordinates = [
            CLLocationCoordinate2D(
                latitude: 36.87538202852011,
                longitude: -117.1882400102913
            ),
            CLLocationCoordinate2D(
                latitude: 36.875041,
                longitude: -117.182762
            ),
            CLLocationCoordinate2D(
                latitude: 36.87400563620031,
                longitude: -117.1952138375491
            ),
            CLLocationCoordinate2D(
                latitude: 36.87308530323207,
                longitude: -117.1817040536553
            ),
            CLLocationCoordinate2D(
                latitude: 36.86921328306198,
                longitude: -117.1957218647003
            ),
            CLLocationCoordinate2D(
                latitude: 36.8342449888587,
                longitude: -117.2225550189614
            ),
            CLLocationCoordinate2D(
                latitude: 36.87315110117197,
                longitude: -117.1926189679653
            ),
            CLLocationCoordinate2D(
                latitude: 36.86136245727539,
                longitude: -117.209529876709
            ),
            CLLocationCoordinate2D(
                latitude: 36.86393301934004,
                longitude: -117.2102549951524
            )
        ]
        
        let northwestForkCoordinates = [
            CLLocationCoordinate2D(
                latitude: 36.87586532905698,
                longitude: -117.1826720796526
            ),
            CLLocationCoordinate2D(
                latitude: 36.87572903931141,
                longitude: -117.1826179325581
            ),
            CLLocationCoordinate2D(
                latitude: 36.8755915760994,
                longitude: -117.1826670505106
            ),
            CLLocationCoordinate2D(
                latitude: 36.87545428052545,
                longitude: -117.1826989017427
            ),
            CLLocationCoordinate2D(
                latitude: 36.87531656585634,
                longitude: -117.1827652025968
            ),
            CLLocationCoordinate2D(
                latitude: 36.87521916814148,
                longitude: -117.1829009894282
            ),
            CLLocationCoordinate2D(
                latitude: 36.87508145347238,
                longitude: -117.1829672902823
            ),
            CLLocationCoordinate2D(
                latitude: 36.8749438226223,
                longitude: -117.1830335911363
            ),
            CLLocationCoordinate2D(
                latitude: 36.87480627559125,
                longitude: -117.1830826252699
            ),
            CLLocationCoordinate2D(
                latitude: 36.87465573661029,
                longitude: -117.1830798592418
            ),
            CLLocationCoordinate2D(
                latitude: 36.87451919540763,
                longitude: -117.1830429788679
            ),
            CLLocationCoordinate2D(
                latitude: 36.87443889677525,
                longitude: -117.1828865725547
            ),
            CLLocationCoordinate2D(
                latitude: 36.87435859814286,
                longitude: -117.1827302500606
            ),
            CLLocationCoordinate2D(
                latitude: 36.87422272749245,
                longitude: -117.1826417371631
            ),
            CLLocationCoordinate2D(
                latitude: 36.87408618628979,
                longitude: -117.1826047729701
            ),
            CLLocationCoordinate2D(
                latitude: 36.87396406196058,
                longitude: -117.1825165115297
            ),
            CLLocationCoordinate2D(
                latitude: 36.8738420214504,
                longitude: -117.1824110671878
            ),
            CLLocationCoordinate2D(
                latitude: 36.87370556406677,
                longitude: -117.1823741029948
            ),
            CLLocationCoordinate2D(
                latitude: 36.87356944195926,
                longitude: -117.1823027729988
            ),
            CLLocationCoordinate2D(
                latitude: 36.87344748526812,
                longitude: -117.1821973286569
            ),
            CLLocationCoordinate2D(
                latitude: 36.87331161461771,
                longitude: -117.1821087319404
            ),
            CLLocationCoordinate2D(
                latitude: 36.87324497848749,
                longitude: -117.1819526609033
            ),
            CLLocationCoordinate2D(
                latitude: 36.87317834235728,
                longitude: -117.1817965898663
            ),
            CLLocationCoordinate2D(
                latitude: 36.87304222024977,
                longitude: -117.1817252598703
            ),
            CLLocationCoordinate2D(
                latitude: 36.87289184890688,
                longitude: -117.1817053109407
            )
        ]
        
        let point = try XCTUnwrap(viewModel.unobstructedPoint(on: northwestForkCoordinates, given: waypointCoordinates))
        XCTAssertEqual(point.latitude, 36.87435859814286)
        XCTAssertEqual(point.longitude, -117.1827302500606)
    }
}
