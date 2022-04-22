//
//  Copyright © 2022 Rosberry. All rights reserved.
//

import UIKit
import RCam

public protocol CroppingRCamDelegate: AnyObject {
    func croppingRCam(_ coordinator: CroppingRCam, imageCaptured image: UIImage)
    func croppingRCamClosedEventTriggered(_ coordinator: CroppingRCam)
}

public final class CroppingRCam {
    public weak var delegate: CroppingRCamDelegate?

    public let navigationController: UINavigationController
    public let rCamViewController: CameraViewController

    public init() {
        let rCamViewController = CameraViewController()
        self.rCamViewController = rCamViewController
        self.navigationController = UINavigationController(rootViewController: rCamViewController)
        rCamViewController.delegate = self
        rCamViewController.automaticallyApplyOrientationToImage = true
    }

    func openCropperViewController(_ image: UIImage) {
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        navigationController.pushViewController(cropViewController, animated: true)
    }
}

// MARK: - CameraViewControllerDelegate

extension CroppingRCam: CameraViewControllerDelegate {

    public func cameraViewController(_ viewController: CameraViewController, imageCaptured image: UIImage, orientationApplied: Bool) {
        openCropperViewController(image)
    }

    public func cameraViewControllerCloseEventTriggered(_ viewController: CameraViewController) {
        exit(0)
    }
}

// MARK: - CropViewControllerDelegate

extension CroppingRCam: CropViewControllerDelegate {

    func cropViewController(_ viewController: CropViewController, imageCropped image: UIImage) {
        delegate?.croppingRCam(self, imageCaptured: image)
    }

    func cropViewControllerClosedEventTriggered(_ viewController: CropViewController) {
        delegate?.croppingRCamClosedEventTriggered(self)
    }
}
