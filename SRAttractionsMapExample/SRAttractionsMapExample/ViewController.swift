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

import UIKit
import MapKit
import SRAttractionsMap

class ViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let path = Bundle.main.path(forResource: "CoffeeshopsList", ofType: "plist") {
            if let array = NSArray.init(contentsOfFile: path) {
                let attractions = array.enumerated().flatMap { (index, element) -> SRAttraction? in
                    guard let dictionary = element as? NSDictionary else { return nil }
                    guard let title = dictionary["title"] as? String else { return nil }
                    guard let subtitle = dictionary["subtitle"] as? String else { return nil }
                    guard let latitudeString = dictionary["latitude"] as? String else { return nil }
                    guard let longitudeString = dictionary["longitude"] as? String else { return nil }
                    guard let image = UIImage(named: "\(index + 1)") else { return nil }
                    guard let latitude = Double(latitudeString) else { return nil }
                    guard let longitude = Double(longitudeString) else { return nil }

                    let attraction = SRAttraction(latitude: latitude, longitude: longitude)
                    attraction.name = title
                    attraction.subname = subtitle
                    attraction.image = image
                    attraction.detailButtonTitle = "View directions"
                    attraction.detailAction = { _ in
                        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: attraction.coordinate, addressDictionary:nil))
                        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
                    }

                    return attraction
                }


                let mapVC = SRAttractionsMapViewController(attractions: attractions, displayMode: .allAttractions)
                mapVC.title = "Amsterdam Coffeshops"

                let nVC = UINavigationController(rootViewController: mapVC)
                nVC.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17.0, weight: .light),
                                                         NSAttributedStringKey.foregroundColor: UIColor.white]
                nVC.navigationBar.barTintColor = UIColor(red: 52.0/255.0, green: 52.0/255.0, blue: 52.0/255.0, alpha: 1.0)
                nVC.navigationBar.tintColor = UIColor.white
                nVC.navigationBar.isTranslucent = false
                self.present(nVC, animated: false, completion: nil)
            }
        }
    }
}

