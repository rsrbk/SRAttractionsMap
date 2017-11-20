SRAttractionsMap ![Pod status](https://cocoapod-badges.herokuapp.com/v/SRCountdownTimer/badge.png)
---
This is the map which contains attractions added on it with the abillity to click and see the full description.
<p align="center">
  <img src="https://github.com/rsrbk/SRAttractionsMap/blob/master/gif.gif?raw=true" alt="Demo gif"/>
</p>

Installation
---
The most preferable way to use this library is cocoapods. Add the following line to your `Podfile`:
```sh
pod 'SRAttractionsMap'
```
and run `pod install` in your terminal.

Alternatively, you can manually add the files in the `SRAttractionsMap` directory to your project.

Usage
--
First of all, you need to have an array of attractions(SRAttraction objects) to show:
```swift
let attraction = SRAttraction(latitude: 52.362315, longitude: 4.857548)
```
You can specify different parameters for your attraction:
```swift
attraction.name = title
attraction.subname = subtitle
attraction.image = image
```
If you want to add CTA on your attraction's view, please configure these two parameters:
```swift
attraction.detailButtonTitle = "View directions"
attraction.detailAction = { _ in
    let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: attraction.coordinate, addressDictionary:nil))
    mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
}
```

After you attractions are ready you should create a custom instance of SRAttractionsMapViewController(subclass of UIViewController):
```swift
let mapVC = SRAttractionsMapViewController(attractions: attractions, displayMode: .allAttractions)
```
or:
```swift
let mapVC = SRAttractionsMapViewController(customPinImage: pinIcon, attractions: attractions, displayMode: .allAttractions)
```
The second convenience initializer allows you to use your custom icon for pins on the map

Display mode decides how the map gonna be zoomed in initially after appearing of the view controller. You have few options:
```swift
/// All attractions will be shown on the map
case allAttractions

/// The first location as the initial point and the radius is the distance to the second attraction times zoomRadiusMultiplier
case firstTwoAttractions

/// The user's location as the initial point and the radius is the distance to the first attraction times zoomRadiusMultiplier
case userAndFirstAttraction

/// The user's location as the initial point and the radius is the distance to the closest attraction times zoomRadiusMultiplier
case userAndTheClosestLocation
```

After that you View Controller is ready and you can present it:
```swift
self.present(mapVC, animated: true, completion: nil)
```
or:
```swift
let nVC = UINavigationController(rootViewController: mapVC)
self.present(nVC, animated: true, completion: nil)
```

You can also customize few more properties:
```swift
/// Moves a selected pin to the center if true
public var shouldScrollToPin: Bool

/// Animation duration. Set to nil if you don't want to have the animation
public var calloutFadeInAnimationDuration: TimeInterval?

/// The size of the callout view which shows when a pin is selected
public var calloutViewSize: CGSize

/// The multiplier radius of initial zooming for display modes
/// firstTwoAttractions/userAndFirstAttraction/userAndTheClosestLocation
public var zoomRadiusMultiplier: Double

/// If this theshold in the mode .userAndTheClosestLocation exceeds
/// - the map will be switched to the .allAttractions mode
public var closestDistanceThreshold: CLLocationDistance
```

License
--
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
