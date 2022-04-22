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
        let coordinator = CroppingRCam()
        coordinator.delegate = self
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = coordinator.navigationController
        window?.makeKeyAndVisible()
        self.coordinator = coordinator
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
}
