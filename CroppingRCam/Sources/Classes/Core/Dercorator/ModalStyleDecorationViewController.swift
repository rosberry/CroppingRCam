//
//  ModalStyleDecorationViewController.swift
//  CroppingRCam
//
//  Created by Nikita Gavrikov on 25.04.2022.
//

import UIKit
import Cripper
import RCam
import Framezilla

public class ModalStyleDecorationViewController: UIViewController {
    public weak var delegate: DecoratorDelegate?

    public let viewController: UIViewController
    public let image: UIImage?

    private lazy var bundle: Bundle = .init(for: Self.self)

    public private(set) lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "ic_close", in: bundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        return button
    }()

    public private(set) lazy var applyButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "ic_apply", in: bundle, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.tintColor = .white
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

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewController.view.frame = view.bounds
        closeButton.configureFrame { maker in
            let topInset = 25 + view.safeAreaInsets.top
            maker.size(width: 35, height: 35)
            maker.top(inset: topInset).left(inset: 30)
        }

        applyButton.configureFrame { maker in
            let topInset = 25 + view.safeAreaInsets.top
            maker.size(width: 35, height: 35)
            maker.top(inset: topInset).right(inset: 30)
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
