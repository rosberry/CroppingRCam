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
    public var cropCustomizationHandler: ((CropperViewController) -> Void)?

    private let decorator: Decorator
    private var navigationController: UINavigationController?
    private var isAnimated: Bool = true

    public init(decorator: Decorator,
                navigationController: UINavigationController?,
                rCamCustomizationHandler: ((CameraViewController) -> Void)? = nil,
                cropCustomizationHandler: ((CropperViewController) -> Void)? = nil) {
        self.decorator = decorator
        self.rCamCustomizationHandler = rCamCustomizationHandler
        self.cropCustomizationHandler = cropCustomizationHandler
        self.navigationController = navigationController
        decorator.delegate = self
    }

    public func pushCameraViewController(isAnimated: Bool = true) {
        self.isAnimated = isAnimated
        let rCamViewController = CameraViewController()
        let decoratedRCamViewController = decorator.decorateCameraViewController(cameraViewController: rCamViewController)
        if navigationController == nil {
            self.navigationController = UINavigationController(rootViewController: decoratedRCamViewController)
        }
        rCamViewController.delegate = self
        decoratedRCamViewController.delegate = self
        rCamViewController.automaticallyApplyOrientationToImage = true
        rCamCustomizationHandler?(rCamViewController)
        navigationController?.pushViewController(rCamViewController, animated: isAnimated)
    }

    private func openCropperViewController(_ image: UIImage) {
        let cropViewController = CropperViewController(image: image)
        let decoratedCropViewController = decorator.decorateCropperViewController(cropperViewController: cropViewController, image: image)
        decoratedCropViewController.delegate = self
        cropCustomizationHandler?(cropViewController)
        navigationController?.pushViewController(decoratedCropViewController, animated: isAnimated)
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

    public func closeButtonPressed() {
        delegate?.croppingRCamBackEventTriggered(self)
    }

    public func applyButtonPressed(imageCaptured image: UIImage) {
        delegate?.croppingRCam(self, imageCaptured: image)
    }
}
