//
//  ViewController.swift
//  CroppingRCamExample
//
//  Created by Nikita Gavrikov on 20.04.2022.
//

import UIKit
import Framezilla
import CroppingRCam

class ViewController: UIViewController {
    var coordinator: CroppingRCam?

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.sizeToFit()
        imageView.backgroundColor = .black
        return imageView
    }()

    private lazy var button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(openCroppingRCamController), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let decorator = ModalStyleDecorator()
        guard let navC = navigationController else { return }
        self.coordinator = CroppingRCam(decorator: decorator, navigationController: navC)
        coordinator?.delegate = self
        view.backgroundColor = .white
        view.addSubview(imageView)
        view.addSubview(button)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.configureFrame { maker in
            maker.size(width: 300, height: 300).cornerRadius(10)
            maker.centerX().centerY()
        }

        button.configureFrame { maker in
            maker.size(width: 200, height: 50).cornerRadius(10)
            maker.top(to: imageView.nui_bottom, inset: 30).centerX()
        }
    }

    @objc private func openCroppingRCamController() {
        guard let vc = coordinator?.rCamViewController else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: CroppingRCamDelegate {

    func croppingRCam(_ coordinator: CroppingRCam, imageCaptured image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        imageView.image = image
        navigationController?.popViewController(animated: true)
    }

    func croppingRCamClosedEventTriggered(_ coordinator: CroppingRCam) {
        navigationController?.popViewController(animated: true)
    }

    func croppingRCamBackEventTriggered(_ coordinator: CroppingRCam) {
        navigationController?.popViewController(animated: true)
    }
}

