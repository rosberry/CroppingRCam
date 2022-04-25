//
//  Decorator.swift
//  CroppingRCam
//
//  Created by Nikita Gavrikov on 25.04.2022.
//

import UIKit
import RCam
import Cripper

public protocol DecoratorDelegate: AnyObject {
    func closeButtonPresed()
    func applyButtonPresed(imageCaptured image: UIImage)
}

public protocol Decorator: AnyObject {
    var delegate: DecoratorDelegate? { get set }
    func decorateCameraViewController(cameraViewController: CameraViewController) -> ModalStyleDecorationViewController
    func decorateCropperViewController(cropperViewController: CropperViewController,
                                       image: UIImage) -> ModalStyleDecorationViewController
}
