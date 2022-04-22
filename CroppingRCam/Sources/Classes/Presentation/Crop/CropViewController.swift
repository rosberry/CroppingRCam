//
//  Copyright © 2022 Rosberry. All rights reserved.
//

import UIKit
import Cripper
import Framezilla

protocol CropViewControllerDelegate: AnyObject {
    func cropViewController(_ viewController: CropViewController, imageCropped image: UIImage)
    func cropViewControllerClosedEventTriggered(_ viewController: CropViewController)
}

final class CropViewController: UIViewController {
    public weak var delegate: CropViewControllerDelegate?

    private let image: UIImage
    private let cropperViewController: CropperViewController

    private lazy var bundle: Bundle = .init(for: Self.self)

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "ic_close_xs", in: bundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black.withAlphaComponent(0.3)
        button.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "ic_close_xs", in: bundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black.withAlphaComponent(0.3)
        button.addTarget(self, action: #selector(acceptButtonPressed), for: .touchUpInside)
        return button
    }()

    public init(image: UIImage) {
        self.image = image
        self.cropperViewController = CropperViewController(image: image)
        self.cropperViewController.clipBorderInset = 10
        self.cropperViewController.mode = .path
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(cropperViewController.view)
        view.addSubview(closeButton)
        view.addSubview(acceptButton)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cropperViewController.view.frame = view.bounds
        closeButton.configureFrame { maker in
            maker.size(width: 70, height: 70).cornerRadius(byHalf: .height)
            maker.bottom(inset: 70).left(inset: 60)
        }

        acceptButton.configureFrame { maker in
            maker.size(width: 70, height: 70).cornerRadius(byHalf: .height)
            maker.bottom(inset: 70).right(inset: 60)
        }
    }

    @objc private func closeButtonPressed() {
        delegate?.cropViewControllerClosedEventTriggered(self)
    }

    @objc private func acceptButtonPressed() {
        guard case let .normal(image) = cropperViewController.makeCroppResult() else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        delegate?.cropViewController(self, imageCropped: image)
    }
}
