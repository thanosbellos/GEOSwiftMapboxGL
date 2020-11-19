//  Copyright (c) 2017 GEOSwift. All rights reserved.

import Foundation
import XCTest

import GEOSwift
import Mapbox
@testable import GEOSwiftMapboxGL

final class MapboxGLTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCreateMKPointAnnotationFromPoint() {
        let WKT = "POINT(45 30)"

        let geometry = try? Geometry.init(wkt: WKT)
        XCTAssertNotNil(geometry, "Geometry from wkt failed" )
        XCTAssertNotNil(geometry?.mapboxShape() as? MGLPointAnnotation, "failed ot create point annotation from valid geometry point" )
    }

    func testCreateMKPolylineFromLineString() {
        let WKT = "LINESTRING(3 4,10 50,20 25)"
        let geometry = try? Geometry.init(wkt: WKT)
        
        XCTAssertNotNil(geometry, "Geometry from wkt failed" )
        XCTAssertNotNil(geometry?.mapboxShape() as? MGLPolyline, "failed ot create point annotation from valid geometry point" )
    }

    func testCreateMKPolygonFromPolygon() {
        let WKT = "POLYGON((35 10, 45 45, 15 40, 10 20, 35 10),(20 30, 35 35, 30 20, 20 30))"
        let geometry = try? Geometry.init(wkt: WKT)
        
        XCTAssertNotNil(geometry, "Geometry from wkt failed" )
        XCTAssertNotNil(geometry?.mapboxShape() as? MGLPolygon, "failed ot create MGPolygon from valid Geometry Polygon" )
    }

    func testCreateMKShapesCollectionFromGeometryCollection() {
        let WKT = "GEOMETRYCOLLECTION(POINT(4 6),LINESTRING(4 6,7 10))"
        let geometry = try? Geometry.init(wkt: WKT)
        XCTAssertNotNil(geometry, "Geometry from wkt failed" )
        XCTAssertNotNil(geometry?.mapboxShape() as? MGLShapesCollection, "failed ot create MGPolygon from valid Geometry Polygon" )
    }
}
