# CroppingRCam
<p align="center">
    <a href="https://github.com/rosberry/CroppingRCam/actions">
      <img src="https://github.com/rosberry/CroppingRCam/workflows/Build/badge.svg" />
    </a>
    <a href="https://swift.org/">
        <img src="https://img.shields.io/badge/swift-5.0-orange.svg" alt="Swift Version" />
    </a>
    <a href="https://github.com/Carthage/Carthage">
        <img src="https://img.shields.io/badge/Carthage-compatible-green.svg" alt="Carthage Compatible" />
    </a>
    <a href="https://github.com/apple/swift-package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
</p>

## Using 
# Initialization CroppingRCamCoordinator
```Swift
    private var croppingRCamCoordinator: CroppingRCam?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 1
        let decorator = ModalStyleDecorator()
        guard let navigationController = navigationController else {
            return
        }
        // 2
        self.croppingRCamCoordinator = CroppingRCam(decorator: decorator, navigationController: navigationController)
        // 3
        croppingRCamCoordinator?.delegate = self
    }
```
1. `ModalStyleDecorator` - It is view controller wrapper that allows to provide action buttons for modal presentation.
2. Initialization CroppingRCamCoordinator: 
```Swift
        init(decorator: Decorator,
             navigationController: UINavigationController?,
             rCamCustomizationHandler: ((CameraViewController) -> Void)? = nil,
             cropCustomizationHandler: ((CropperViewController) -> Void)? = nil)
```
   - `decorator: ModalStyleDecorator` - It is view controller wrapper that allows to provide action buttons for modal presentation.
   - `navigationController: UINavigationViewController` - navigation controller.
   - `rCamCustomizationHandler and cropCustomizationHandler` - needed for customization controller. Default value `nil`.
3. `delegate: CroppingRCamDelegate` - needed for handle event on `CroppingRCamCoordinator`.
```Swift
// MARK: - CroppingRCamDelegate

extension ViewController: CroppingRCamDelegate {

    func croppingRCam(_ coordinator: CroppingRCam, imageCaptured image: UIImage) {
        // Triggered afler cropped on image
    }

    func croppingRCamClosedEventTriggered(_ coordinator: CroppingRCam) {
        // Triggered after make photo 
    }

    func croppingRCamBackEventTriggered(_ coordinator: CroppingRCam) {
        // Triggered after tap close on RCamViewController
    }
}
```

# Show CroppingRCam

```Swift
    @objc private func openCroppingRCamController() {
        // 1
        croppingRCamCoordinator?.rCamCustomizationHandler = { rCamViewController in
            rCamViewController.view.backgroundColor = .brown
        }
        // 2
        croppingRCamCoordinator?.pushCameraViewController(isAnimated: true)
    }
```
1. Use handler if need customization rCamViewController. 
2. About `CroppingRCamCoordinator` use `func pushCameraViewController` and push on Camera VC.

## Requirements

- iOS 11.0+
- Xcode 11.0+

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate CroppingRCam into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "rosberry/CroppingRCam"
```

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate CroppingRCam into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'CroppingRCam'
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. Once you have your Swift package set up, adding CroppingRCam as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/rosberry/CroppingRCam.git", .upToNextMajor(from: "1.0.0"))
]
```

## Documentation

Read the [docs](https://rosberry.github.io/CroppingRCam). Generated with [jazzy](https://github.com/realm/jazzy). Hosted by [GitHub Pages](https://pages.github.com).

## About

<img src="https://github.com/rosberry/Foundation/blob/master/Assets/full_logo.png?raw=true" height="100" />

This project is owned and maintained by [Rosberry](http://rosberry.com). We build mobile apps for users worldwide 🌏.

Check out our [open source projects](https://github.com/rosberry), read [our blog](https://medium.com/@Rosberry) or give us a high-five on 🐦 [@rosberryapps](http://twitter.com/RosberryApps).

## License

This project is available under the MIT license. See the LICENSE file for more info.
