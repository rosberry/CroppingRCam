//
//  ModalStyleDecorationViewController.swift
//  CroppingRCam
//
//  Created by Nikita Gavrikov on 25.04.2022.
//

import UIKit
import Cripper
import RCam

public class ModalStyleDecorationViewController: UIViewController {
    public weak var delegate: DecoratorDelegate?

    public let viewController: UIViewController
    public let image: UIImage?

    private lazy var bundle: Bundle = .init(for: Self.self)

    public lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "ic_close_xs", in: bundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black.withAlphaComponent(0.3)
        button.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        return button
    }()

    public lazy var applyButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "ic_close_xs", in: bundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black.withAlphaComponent(0.3)
        button.addTarget(self, action: #selector(applyButtonPressed), for: .touchUpInside)
        return button
    }()

    public required init(viewController: UIViewController, image: UIImage? = nil) {
        self.viewController = viewController
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.addSubview(viewController.view)
        view.addSubview(closeButton)
        view.addSubview(applyButton)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewController.view.frame = view.bounds
        closeButton.configureFrame { maker in
            maker.size(width: 40, height: 40).cornerRadius(byHalf: .height)
            maker.top(inset: 60).left(inset: 30)
        }

        applyButton.configureFrame { maker in
            maker.size(width: 40, height: 40).cornerRadius(byHalf: .height)
            maker.top(inset: 60).right(inset: 30)
        }
    }

    @objc private func closeButtonPressed() {
        delegate?.closeButtonPresed()
    }

    @objc private func applyButtonPressed() {
        let cropperViewController = viewController as? CropperViewController
        guard case let .normal(image) = cropperViewController?.makeCroppResult() else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        delegate?.applyButtonPresed(imageCaptured: image)
    }
}
