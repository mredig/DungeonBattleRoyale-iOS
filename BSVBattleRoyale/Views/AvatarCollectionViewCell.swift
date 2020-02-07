//
//  AvatarCollectionViewCell.swift
//  BSVBattleRoyale
//
//  Created by Michael Redig on 2/6/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import UIKit

class AvatarCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var containerView: UIView!

	var avatar: AvatarSelectionContainer? {
		didSet {
			updateViews()
			updateAvatar()
		}
	}

	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		containerView.layer.cornerRadius = 20
		containerView.layer.cornerCurve = .continuous
		_ = NotificationCenter.default.addObserver(forName: .characterSelectionChanged, object: nil, queue: nil, using: { [weak self] _ in
			self?.avatar?.isSelected = false
			self?.updateViews()
		})
	}

	private func updateViews() {
		containerView.backgroundColor = avatar?.isSelected == true ? .systemBlue : .clear
	}

	private func updateAvatar() {
		guard let avatar = avatar else { return }
		let name: String
		switch avatar.avatar {
		case .blueMonster:
			name = "Blue"
		case .greenMonster:
			name = "Green"
		case .pinkMonster:
			name = "Pink"
		case .purpleMonster:
			name = "Purple"
		case .yellowMonster:
			name = "Yellow"
		}
		let fullname = "select\(name)"

		imageView.image = UIImage(named: fullname)
	}

	@IBAction func selectedButtonPressed(_ sender: UIButton) {
		NotificationCenter.default.post(name: .characterSelectionChanged, object: nil)
		avatar?.isSelected = true
		updateViews()
	}
}

extension NSNotification.Name {
	static let characterSelectionChanged = NSNotification.Name("characterSelectionChanged")
}
