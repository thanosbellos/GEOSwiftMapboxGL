//  Copyright (c) 2017 GEOSwiftMapboxGL. All rights reserved.

import Foundation
import CoreLocation
import GEOSwift
import Mapbox

// MARK: - MGLShape creation convenience function

public protocol GEOSwiftMapboxGL {
    /**
     A convenience method to create a `MGLShape` ready to be added to a `MGLMapView`.
     Mapbox has limited support to GEOS geometry types: be aware that when dealing with polygons, interior rings are not handled by MapBoxGL, we must drop this information while building a polygon shape.
     
     :returns: A MGLShape representing this geometry.
     */
    func mapboxShape() -> MGLShape
}

public extension CLLocationCoordinate2D {
    init(_ point: Point) {
        self.init(latitude: point.y, longitude: point.x)
    }
}

public extension GEOSwift.Polygon {
    static var world: GEOSwift.Polygon {
        // swiftlint:disable:next force_try
        return try! Polygon(exterior: Polygon.LinearRing(points: [
            Point(x: -180, y: 90),
            Point(x: -180, y: -90),
            Point(x: 180, y: -90),
            Point(x: 180, y: 90),
            Point(x: -180, y: 90)]))
    }
}

public extension Point {
    init(longitude: Double, latitude: Double) {
        self.init(x: longitude, y: latitude)
    }
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.init(x: coordinate.longitude, y: coordinate.latitude)
    }
}

extension Geometry: GEOSwiftMapboxGL {
    public func mapboxShape() -> MGLShape {
        switch self {
        case .point(let point):
            let pointAnno = MGLPointAnnotation()
            pointAnno.coordinate = CLLocationCoordinate2D(point)
            return pointAnno
        case .lineString(let line):
            var coordinates = line.points.map({ (point: Point) ->
                CLLocationCoordinate2D in
                return CLLocationCoordinate2D(point)
            })
            let polyline = MGLPolyline(coordinates: &coordinates,
                                       count: UInt(coordinates.count))
            return polyline
            
        case .polygon(let polygon):
            var exteriorRingCoordinates = polygon.exterior.points.map({ (point: Point) ->
                CLLocationCoordinate2D in
                return CLLocationCoordinate2D(point)
            })
            
            // interior rings are not handled by MapBoxGL, we must drop this info!
            //            let interiorRings = (self as! Polygon).interiorRings.map({ (linearRing: LinearRing) ->
            //                MKPolygon in
            //                return MKPolygonWithCoordinatesSequence(linearRing.points)
            //            })
            
            let polygon = MGLPolygon(coordinates: &exteriorRingCoordinates, count: UInt(exteriorRingCoordinates.count) /*, interiorPolygons: interiorRings*/)
            return polygon
            
        case .multiPolygon(let multiPolygon):
            let mglPolygons = multiPolygon.polygons.map({ (polygon: GEOSwift.Polygon) -> MGLPolygon in
                Geometry.polygon(polygon).mapboxShape() as! MGLPolygon
            })
            return MGLMultiPolygon(polygons: mglPolygons)
            
        case .multiPoint(let multiPoint):
            let collection: [Geometry] =  multiPoint.points.map({ (point: Point) -> Geometry in
                Geometry.point(point)
            })
            // self is Geometry.multipoint
            return MGLShapesCollection(geometryCollection: GeometryCollection(geometries: collection))
        case .multiLineString(let multiString):
            let collection: [Geometry] =  multiString.lineStrings.map({ (line: LineString) -> Geometry in
                Geometry.lineString(line)
            })
            // self is Geometry.multipoint
            return MGLShapesCollection(geometryCollection: GeometryCollection(geometries: collection))
        case .geometryCollection(let geometryCollection):
            return MGLShapesCollection(geometryCollection: geometryCollection)
        }
        
    }
}

//private func MGLPolygonWithCoordinatesSequence(coordinates: CoordinatesCollection) -> MGLPolygon {
//    var coordinates = coordinates.map({ (point: Coordinate) ->
//        CLLocationCoordinate2D in
//        return CLLocationCoordinate2D(point)
//    })
//    return MGLPolygon(coordinates: &coordinates,
//                      count: UInt(coordinates.count))
//
//}

/**
 MGLShape subclass for GeometryCollections.
 The property `shapes` contains MGLShape subclasses instances. When drawing shapes on a map be careful to the fact that that these shapes could be overlays OR annotations.
 */
public class MGLShapesCollection : MGLShape, MGLOverlay {
    let shapes: Array<MGLShape>
    public let centroid: CLLocationCoordinate2D
    public let overlayBounds: MGLCoordinateBounds
    
    // inserting the where clause in the following generic create some confusion in the precompiler that raise the following error:
    // Cannot invoke initializer for type ... with an argument list of type (geometryCollection: GeometryCollection<T>)
    // 1. Expected an argument list of type (geometryCollection: GeometryCollection<T>)
    required public init(geometryCollection: GeometryCollection){
        let shapes = geometryCollection.geometries.map({ (geometry: GEOSwiftMapboxGL) ->
            MGLShape in
            return geometry.mapboxShape()
        })
        
        
        do {
            let coordinate = try geometryCollection.centroid()
            self.centroid = CLLocationCoordinate2D(coordinate)
        } catch {
            self.centroid = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        
        self.shapes = shapes
        
        do {
            let envelopeGeometry = try geometryCollection.envelope().geometry
            if case Geometry.polygon(let polygon) = envelopeGeometry{
                let exteriorRing = polygon.exterior
                let sw = CLLocationCoordinate2D(exteriorRing.points[0])
                let ne = CLLocationCoordinate2D(exteriorRing.points[2])
                self.overlayBounds = MGLCoordinateBounds(sw:sw, ne:ne)
            } else {
                let zeroCoord = CLLocationCoordinate2DMake(0, 0)
                self.overlayBounds = MGLCoordinateBounds(sw:zeroCoord, ne:zeroCoord)
            }
        } catch {
            let zeroCoord = CLLocationCoordinate2DMake(0, 0)
            self.overlayBounds = MGLCoordinateBounds(sw:zeroCoord, ne:zeroCoord)
        }
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var coordinate: CLLocationCoordinate2D { get {
        return centroid
    }}
    
    // TODO: implement using "intersect" method (actually it seems that mapboxgl never calls it...)
    public func intersects(_ overlayBounds: MGLCoordinateBounds) -> Bool {
        return true
    }
}
