// SPDX-License-Identifier: MIT
// Copyright @ 2021 Ericom Software.  All Rights Reserved.

import UIKit

class SwitchCell: UITableViewCell {
    var message: String {
        get { return textLabel?.text ?? "" }
        set(value) { textLabel?.text = value }
    }
    var isOn: Bool {
        get { return switchView.isOn }
        set(value) { switchView.isOn = value }
    }
    var isEnabled: Bool {
        get { return switchView.isEnabled }
        set(value) {
            switchView.isEnabled = value
            if #available(iOS 13.0, *) {
                textLabel?.textColor = value ? .label : .secondaryLabel
            } else {
                textLabel?.textColor = value ? .black : .gray
            }
        }
    }

    var onSwitchToggled: ((Bool) -> Void)?

    var observationToken: AnyObject?

    let switchView = UISwitch()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        accessoryView = switchView
        switchView.addTarget(self, action: #selector(switchToggled), for: .valueChanged)

        updateStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func switchToggled() {
        onSwitchToggled?(switchView.isOn)
        updateStyle()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onSwitchToggled = nil
        isEnabled = true
        message = ""
        isOn = false
        observationToken = nil

        updateStyle()
    }

    func updateStyle() {
        if switchView.isOn {
            switchView.onTintColor = ToggleCustomStyle.onColor
        } else {
            /*For off state*/
            switchView.tintColor = ToggleCustomStyle.offColor
            switchView.layer.cornerRadius = switchView.frame.height / 2.0
            switchView.backgroundColor = ToggleCustomStyle.offColor
            switchView.clipsToBounds = true
        }
    }
}
