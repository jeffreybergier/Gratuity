![Xcode: 10.1](https://img.shields.io/badge/Xcode-10.1-lightgrey.svg) ![Swift: 4.0](https://img.shields.io/badge/Swift-4.0-lightgrey.svg) ![iOS: 9.3](https://img.shields.io/badge/iOS-9.3-lightgrey.svg) ![devices: iPhone & iPad](https://img.shields.io/badge/devices-iPad%20%26%20iPhone-lightgrey.svg)

![Gratuity App Icon](/GratuitousSwift/Images.xcassets/AppIcon.appiconset/New%20iOS%20App%20Icon-83-2x.png)
# Gratuity - Quick Tips

Gratuity for Apple Watch and iOS makes getting a tip at a restaurant quick and easy. Gratuity for iOS is the most beautiful and the most interactive tip calculator you have used. Gratuity for Apple Watch means you can calculate restaurant tips without even taking your phone out of your pocket.

Gratuity was my first Swift app. Its 100% written by me, 100% written in Swift, and is no longer under development.

[📲 App Store Link](https://itunes.apple.com/app/id933679671)

## App Store Screenshots

1  |2  |3  |4
:-:|:-:|:-:|:-:
![1](/iTunesScreenshots1.2/iOS/4.7in-Main.png)|![2](/iTunesScreenshots1.2/iOS/4.7in-Settings.png)|![3](/iTunesScreenshots1.2/iOS/4.7in-Purchase.png)|![4](/iTunesScreenshots1.2/iOS/4.7in-Split.png)

## App Store Description

Gratuity for Apple Watch and iOS makes getting a tip at a restaurant quick and easy. Gratuity for iOS is the most beautiful and the most interactive tip calculator you have used. Gratuity for Apple Watch means you can calculate restaurant tips without even taking your phone out of your pocket.

- Custom designed Apple Watch app.
- Split Bill feature available as In-App Purchase.
- 3D Touch support for "peeking" the Split Bill feature.
- The color scheme is perfect for the lighting in a romantic restaurant.
- Gratuity remembers your entries after being closed.
- Gratuity automatically adjusts the currency symbol to your region.
- Settings screen allows suggested tip and currency symbol to be adjusted.
- Fully supports Dynamic Type.

## Why GPL License?

I want Gratuity to be open source but I don't want people to republish the app with a different name on the App Store. Please do not fork this project and submit to the App Store under your own account. The GPL requires that you give the original developer credit and it also requires that the modified app also be open source. So please don't do this.

Gratuity is a full application, not a library. The code is not generic enough to be a separate library. Also, this code is old and represents a point in time when I was much more junior. Please do not look at this code for reference or for judgement on my abilities as an iOS Developer.

## Code of Conduct

WaterMe has a [Code of Conduct](/CODE_OF_CONDUCT.md) for its community on Github. I want all people that participate in issues, comments, pull requests, or any other part of the project to feel safe from harassment. Every person must treat every other person with respect and dignity or else face banning from the community. If you feel someone has not treated you with respect, [please let me know in private](mailto:watermeconduct@jeffburg.com).
    
## Guidelines for Contributing

Gratuity is no longer under active development. I would advise not to attempt to contribute.

## How to Clone and Run

### Requirements

- Xcode 10.1 or higher
- Cocoapods

### Instructions

1. Clone the Repo: 
    ```
    git clone 'https://github.com/jeffreybergier/Gratuity.git'
    ```
1. Install Cocoapods
    ```
    cd Gratuity
    pod install
    ```
1. Change Team to your AppleID (needed to run on your physical device)
    1. Open `GratuitousSwift.xcworkspace` in Xcode.
    1. Browse to the General tab of the WaterMe Target.
    1. Under Signing, change the team from its current setting to your AppleID.
1. Build and Run
    - Gratuity works in the simulator and on physical devices
