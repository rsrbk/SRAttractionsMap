/*
 MIT License
 Copyright (c) 2017 Ruslan Serebriakov <rsrbk1@gmail.com>
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import MapKit

/// Defines the level of the initial zoom of the map
public enum SRAttractionMapDisplayMode {
    /// All attractions will be shown on the map
    case allAttractions
    /// The first location as the initial point and the radius is the distance to the second attraction times zoomRadiusMultiplier
    case firstTwoAttractions
    /// The user's location as the initial point and the radius is the distance to the first attraction times zoomRadiusMultiplier
    case userAndFirstAttraction
    /// The user's location as the initial point and the radius is the distance to the closest attraction times zoomRadiusMultiplier
    case userAndTheClosestLocation
}

public class SRAttractionsMapViewController: UIViewController {

    /// Moves a selected pin to the center if true
    public var shouldScrollToPin = true

    /// Animation duration. Set to nil if you don't want to have the animation
    public var calloutFadeInAnimationDuration: TimeInterval? = 0.25

    /// The size of the callout view which shows when a pin is selected
    public var calloutViewSize: CGSize!

    /// The multiplier radius of initial zooming for display modes
    /// firstTwoAttractions/userAndFirstAttraction/userAndTheClosestLocation
    public var zoomRadiusMultiplier: Double = 2

    /// If this theshold in the mode .userAndTheClosestLocation exceeds
    /// - the map will be switched to the .allAttractions mode
    public var closestDistanceThreshold: CLLocationDistance = 10000

    // Make sure that properties below are set before the viewDidLoad method is called
    // It's much better and safe to configure this class from the code rather than from the storyboard/xib

    /// Attractions to show
    public var attractions: [SRAttraction] = []

    /// Display mode decides how the map gonna be zoomed in initially after appearing of the view controller
    public var displayMode: SRAttractionMapDisplayMode = .firstTwoAttractions

    /// Custom marker for attractions on the map
    public var customPinImage: UIImage?

    public init(attractions: [SRAttraction], displayMode: SRAttractionMapDisplayMode) {
        super.init(nibName: nil, bundle: nil)

        self.attractions = attractions
        self.displayMode = displayMode
    }

    convenience public init(customPinImage: UIImage, attractions: [SRAttraction],  displayMode: SRAttractionMapDisplayMode) {
        self.init(attractions: attractions, displayMode: displayMode)

        self.customPinImage = customPinImage
    }

    public func addAttractions(attractions: [SRAttraction]) {
        mapView.addAnnotations(attractions)
    }

    public func removeAttractions(attractions: [SRAttraction]) {
        mapView.removeAnnotations(attractions)
    }

    // Internal stuff
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(mapView)
        mapView.frame = view.bounds
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.addAnnotations(attractions)

        switch displayMode {
        case .userAndFirstAttraction, .userAndTheClosestLocation:
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        case .firstTwoAttractions:
            if attractions.count < 2 {
                fatalError("We need to have at least 2 attractions for this mode")
            }

            let first = attractions[0]
            let second = attractions[1]
            let radius: CLLocationDistance = first.location.distance(from: second.location) * zoomRadiusMultiplier
            let region = MKCoordinateRegionMakeWithDistance(first.coordinate, radius, radius)
            mapView.setRegion(region, animated: true)
        case .allAttractions:
            mapView.showAnnotations(attractions, animated: true)
        }
    }

    internal var locationManager = CLLocationManager()
    internal var mapView = MKMapView()
    internal var calloutView: SRCalloutView?
    
    internal var zoomedInInitially = false
}

extension SRAttractionsMapViewController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            displayMode = .allAttractions
            mapView.showAnnotations(attractions, animated: true)
        default:
            break
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if zoomedInInitially || attractions.isEmpty {
            return
        }

        if let location = locations.last {
            switch displayMode {
            case .userAndFirstAttraction:
                if let attraction = attractions.first {
                    let radius: CLLocationDistance = location.distance(from: attraction.location) * zoomRadiusMultiplier
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, radius, radius)
                    mapView.setRegion(region, animated: true)
                }
            case .userAndTheClosestLocation:
                var closestDistance: CLLocationDistance = Double(Int.max)
                for attraction in attractions {
                    let currentDistance = location.distance(from: attraction.location)
                    if currentDistance < closestDistance {
                        closestDistance = currentDistance
                    }
                }

                if closestDistance < closestDistanceThreshold {
                    let radius = closestDistance * zoomRadiusMultiplier
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, radius, radius)
                    mapView.setRegion(region, animated: true)
                } else {
                    displayMode = .allAttractions
                    mapView.showAnnotations(attractions, animated: true)
                }
            case .firstTwoAttractions, .allAttractions:
                break
            }

            zoomedInInitially = true
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
}

extension SRAttractionsMapViewController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        let reuseIdentifier = "annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        if annotationView == nil {
            var pinImage = customPinImage

            if pinImage == nil {
                let frameworkBundle = Bundle.init(for: type(of: self))
                pinImage = UIImage(named: "annotation_icon", in: frameworkBundle, compatibleWith: nil)
            }

            annotationView = SRAnnotationView(annotationImage: pinImage!,
                                              annotation: annotation,
                                              reuseIdentifier: reuseIdentifier)
            annotationView?.centerOffset = CGPoint(x: 0, y: -pinImage!.size.height / 2)
        }

        return annotationView
    }

    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let attraction = view.annotation as? SRAttraction {
            if calloutView != nil {
                mapView.deselectAnnotation(attraction, animated: false)
            }

            if (calloutViewSize == nil) {
                setDefaultCalloutViewSize()
            }
            let newCalloutView = generateCalloutView(attraction: attraction)
            let verticalOffset: CGFloat = 4
            newCalloutView.frame = CGRect(x: view.frame.width/2 - calloutViewSize.width/2,
                                          y: -calloutViewSize.height - verticalOffset,
                                          width: calloutViewSize.width,
                                          height: calloutViewSize.height)
            view.addSubview(newCalloutView)

            if shouldScrollToPin {
                mapView.setCenter(attraction.coordinate, animated: true)
            }

            // Fade in animation
            if let duration = calloutFadeInAnimationDuration {
                newCalloutView.alpha = 0
                UIView.animate(withDuration: duration, animations: {
                    newCalloutView.alpha = 1
                })
            }

            calloutView = newCalloutView
        }
    }

    public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let calloutView = calloutView {
            self.calloutView = nil

            if let duration = calloutFadeInAnimationDuration {
                UIView.animate(withDuration: duration, animations: {
                    calloutView.alpha = 0
                }, completion: { _ in
                    calloutView.removeFromSuperview()
                })
            } else {
                calloutView.removeFromSuperview()
            }
        }
    }

    private func setDefaultCalloutViewSize() {
        if UIDevice.current.model.contains("iPad") {
            // iPad
            calloutViewSize = CGSize(width: 300, height: 275)
        } else if UIScreen.main.nativeBounds.height == 2436 {
            // iPhone X
            calloutViewSize = CGSize(width: UIScreen.main.bounds.width-20, height: UIScreen.main.bounds.height/2-120)
        } else if UIScreen.main.nativeBounds.height == 2208 {
            // iPhone 6+/6S+/7+/8+
            calloutViewSize = CGSize(width: UIScreen.main.bounds.width-20, height: UIScreen.main.bounds.height/2-80)
        } else {
            calloutViewSize = CGSize(width: UIScreen.main.bounds.width-20, height: UIScreen.main.bounds.height/2-40)
        }
    }

    private func generateCalloutView(attraction: SRAttraction) -> SRCalloutView {
        let calloutView = SRCalloutView(frame: .zero)
        calloutView.titleLabel.text = attraction.name
        calloutView.subtitleLabel.text = attraction.subname
        calloutView.imageView.image = attraction.image
        calloutView.detailButton.setTitle(attraction.detailButtonTitle, for: .normal)

        if let detailButtonTitle = attraction.detailButtonTitle {
            calloutView.detailButton.setTitle(detailButtonTitle, for: .normal)
            calloutView.onDetailTap = { [weak self] in
                attraction.detailAction?(self)
            }
        } else {
            calloutView.hideDetailButton()
        }

        calloutView.onDetailTap = { [weak self] in
            attraction.detailAction?(self)
        }
        calloutView.onCloseTap = { [weak self] in
            self?.mapView.deselectAnnotation(attraction, animated: true)
        }

        return calloutView
    }
}
