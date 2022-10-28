//
//  ModalStyleDecorator.swift
//  CroppingRCam
//
//  Created by Nikita Gavrikov on 25.04.2022.
//

import UIKit
import RCam
import Cripper

public final class ModalStyleDecorator<ModalViewController: ModalStyleDecorationViewController>: Decorator {
    public weak var delegate: DecoratorDelegate?

    public func decorateCameraViewController(cameraViewController: CameraViewController) -> ModalStyleDecorationViewController {
        let decoratedViewController = ModalViewController(viewController: cameraViewController)
        cameraViewController.closeButton.isHidden = true
        decoratedViewController.applyButton.isHidden = true
        return decoratedViewController
    }

    public func decorateCropperViewController(cropperViewController: CropperViewController,
                                              image: UIImage) -> ModalStyleDecorationViewController {
        let decoratedViewController = ModalViewController(viewController: cropperViewController, image: image)
        return decoratedViewController
    }

    public init() {}
}
