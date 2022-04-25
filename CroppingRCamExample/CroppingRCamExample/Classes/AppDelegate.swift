//
//  Copyright © 2022 Rosberry. All rights reserved.
//

import UIKit
import CroppingRCam

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: CroppingRCam?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        let decorator = ModalStyleDecorator()
//        let coordinator = CroppingRCam(decorator: decorator)
//        coordinator.delegate = self
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController(rootViewController: ViewController())
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
//        self.coordinator = coordinator
        return true
    }
}

// MARK: - CroppingRCamCoordinatorDelegate

extension AppDelegate: CroppingRCamDelegate {

    func croppingRCam(_ coordinator: CroppingRCam, imageCaptured image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        coordinator.navigationController.popViewController(animated: true)
    }

    func croppingRCamClosedEventTriggered(_ coordinator: CroppingRCam) {
        coordinator.navigationController.popViewController(animated: true)
    }

    func croppingRCamBackEventTriggered(_ coordinator: CroppingRCam) {
        coordinator.navigationController.popViewController(animated: true)
    }
}
