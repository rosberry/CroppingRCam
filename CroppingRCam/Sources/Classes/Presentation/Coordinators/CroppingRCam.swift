//
//  Copyright © 2022 Rosberry. All rights reserved.
//

import UIKit
import RCam
import Cripper

public protocol CroppingRCamDelegate: AnyObject {
    func croppingRCam(_ coordinator: CroppingRCam, imageCaptured image: UIImage)
    func croppingRCamClosedEventTriggered(_ coordinator: CroppingRCam)
    func croppingRCamBackEventTriggered(_ coordinator: CroppingRCam)
}

public final class CroppingRCam {
    public weak var delegate: CroppingRCamDelegate?

    public var rCamCustomizationHandler: ((CameraViewController) -> Void)?
    public var cropCustmizationHandler: ((CropperViewController) -> Void)?

    public let navigationController: UINavigationController
    public let rCamViewController: UIViewController
    private let decorator: Decorator

    public init(decorator: Decorator,
                navigationController: UINavigationController?,
                rCamCustomizationHandler: ((CameraViewController) -> Void)? = nil,
                cropCustmizationHandler: ((CropperViewController) -> Void)? = nil) {
        self.decorator = decorator
        self.rCamCustomizationHandler = rCamCustomizationHandler
        self.cropCustmizationHandler = cropCustmizationHandler
        let rCamViewController = CameraViewController()
        let decoratedRCamViewController = decorator.decorateCameraViewController(cameraViewController: rCamViewController)
        if let navigationController = navigationController {
            self.navigationController = navigationController
        }
        else {
            self.navigationController = UINavigationController(rootViewController: decoratedRCamViewController)
        }
        self.rCamViewController = decoratedRCamViewController
        rCamViewController.delegate = self
        decoratedRCamViewController.delegate = self
        decorator.delegate = self
        rCamViewController.automaticallyApplyOrientationToImage = true
        rCamCustomizationHandler?(rCamViewController)
    }

    func openCropperViewController(_ image: UIImage) {
        let cropViewController = CropperViewController(image: image)
        let decoratedCropViewController = decorator.decorateCropperViewController(cropperViewController: cropViewController, image: image)
        decoratedCropViewController.delegate = self
        cropCustmizationHandler?(cropViewController)
        navigationController.pushViewController(decoratedCropViewController, animated: true)
    }
}

// MARK: - CameraViewControllerDelegate

extension CroppingRCam: CameraViewControllerDelegate {

    public func cameraViewController(_ viewController: CameraViewController, imageCaptured image: UIImage, orientationApplied: Bool) {
        openCropperViewController(image)
    }

    public func cameraViewControllerCloseEventTriggered(_ viewController: CameraViewController) {
        delegate?.croppingRCamClosedEventTriggered(self)
    }
}

// MARK: - DecoratorDelegate

extension CroppingRCam: DecoratorDelegate {

    public func closeButtonPresed() {
        delegate?.croppingRCamBackEventTriggered(self)
    }

    public func applyButtonPresed(imageCaptured image: UIImage) {
        delegate?.croppingRCam(self, imageCaptured: image)
    }
}
