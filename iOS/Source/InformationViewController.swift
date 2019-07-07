//
//  InformationViewController.swift
//  Dome
//
//  Created by Ивлев Александр on 06/07/2019.
//  Copyright © 2019 SIA. All rights reserved.
//

import UIKit
import SnapKit

class InformationViewController: UIViewController
{

    internal var storage: Storage?
    internal var network: Network?
    private var lockUnlockState: LockUnlockState = LockUnlockState()

    private let stateView: UIView = UIView(frame: .zero)
    private let stateLabel: UILabel = UILabel(frame: .zero)
    private let stateImageView: UIImageView = UIImageView(image: nil)
    private let infoView: UIView = UIView(frame: .zero)
    private let infoTitleLabel: UILabel = UILabel(frame: .zero)
    private let infoStatusLabel: UILabel = UILabel(frame: .zero)

    private let infoIdView: UIView = UIView(frame: .zero)
    private let infoIdLabel: UILabel = UILabel(frame: .zero)
    private let infoIdNumberLabel: UILabel = UILabel(frame: .zero)
    private let infoButtonLabel: UILabel = UILabel(frame: .zero)

    private let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)

    private var infoIdHeightConstraint: Constraint?
    private var buttonHeightConstraint: Constraint?

    private var needConnect: Bool = true
    private var needLocked: Bool = false
    private var realLocked: Bool = false

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.view.backgroundColor = .white

        self.configureViews()

        self.startAuthentication()
    }

    private func configureViews() {
        self.view.addSubview(self.stateView)
        self.stateView.addSubview(self.stateLabel)
        self.stateView.addSubview(self.activityIndicatorView)
        self.stateView.addSubview(self.stateImageView)

        self.view.addSubview(self.infoView)
        self.infoView.addSubview(self.infoTitleLabel)
        self.infoView.addSubview(self.infoStatusLabel)

        self.infoView.addSubview(self.infoButtonLabel)

        self.infoView.addSubview(self.infoIdView)
        self.infoIdView.addSubview(self.infoIdLabel)
        self.infoIdView.addSubview(self.infoIdNumberLabel)

        self.stateView.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.top.equalToSuperview()
            maker.right.equalToSuperview()
        }
        self.infoView.snp.makeConstraints { maker in
            maker.top.equalTo(self.stateView.snp.bottom)
            maker.left.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.right.equalToSuperview()
            //maker.height.equalTo(160)
        }
        self.activityIndicatorView.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }
        self.stateLabel.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(80)
            maker.left.equalToSuperview().offset(16)
            maker.right.equalToSuperview().offset(-16)
        }
        self.stateImageView.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview().offset(40)
        }
        self.infoIdView.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(24)
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalTo(self.infoTitleLabel.snp.top).offset(-8)
            infoIdHeightConstraint = maker.height.equalTo(80).constraint
        }
        self.infoTitleLabel.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(16)
            maker.right.equalToSuperview().offset(-16)
            maker.bottom.equalTo(self.infoStatusLabel.snp.top).offset(-8)
        }
        self.infoStatusLabel.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(16)
            maker.right.equalToSuperview().offset(-16)
            maker.bottom.equalTo(self.infoButtonLabel.snp.top).offset(-16)
        }

        self.infoButtonLabel.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.width.equalTo(120)
            buttonHeightConstraint = maker.height.equalTo(32).constraint
            maker.bottom.equalToSuperview().offset(-24)
        }

        self.infoIdLabel.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.left.equalToSuperview().offset(16)
            maker.right.equalToSuperview().offset(-16)
        }
        self.infoIdNumberLabel.snp.makeConstraints { maker in
            maker.top.equalTo(self.infoIdLabel.snp.bottom).offset(8)
            maker.centerX.equalToSuperview()
            maker.size.equalTo(CGSize(width: 180.0, height: 50.0))
            maker.bottom.equalToSuperview()
        }

        self.infoView.backgroundColor = UIColor(r: 240, g: 238, b: 239)

        self.infoTitleLabel.textAlignment = .center
        self.infoTitleLabel.textColor = .black
        self.infoTitleLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)

        self.infoStatusLabel.textAlignment = .center
        self.infoStatusLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)

        self.stateLabel.textAlignment = .center
        self.stateLabel.textColor = .white
        self.stateLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .regular)
        self.stateLabel.numberOfLines = 0

        self.infoButtonLabel.layer.cornerRadius = 10.0
        self.infoButtonLabel.layer.masksToBounds = true
        self.infoButtonLabel.textAlignment = .center
        self.infoButtonLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .regular)

        self.infoIdView.backgroundColor = UIColor.clear

        self.infoIdLabel.textAlignment = .center
        self.infoIdLabel.textColor = UIColor.black
        self.infoIdLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .regular)

        self.infoIdNumberLabel.layer.cornerRadius = 10.0
        self.infoIdNumberLabel.layer.masksToBounds = true
        self.infoIdNumberLabel.textAlignment = .center
        self.infoIdNumberLabel.textColor = UIColor.black
        self.infoIdNumberLabel.backgroundColor = UIColor.white
        self.infoIdNumberLabel.font = UIFont.systemFont(ofSize: 40.0, weight: .medium)

        activityIndicatorView.color = UIColor.white
        activityIndicatorView.center = CGPoint(x: view.frame.width * 0.5, y: view.frame.height * 0.5)
        activityIndicatorView.hidesWhenStopped = true
    }

    private func startAuthentication() {
        self.updateInterface()

        network?.authenticate()
        network?.stateChanged = { [weak self] state in
            switch state {
            case .registered:
                self?.needConnect = false
                self?.updateInterface()
            default:
                break
            }
        }

        network?.infoChanged = { [weak self] info in
            self?.parseInfo(info)
        }

        self.realLocked = network?.locked ?? false
        network?.lockState = { [weak self] locked in
            self?.realLocked = locked
            self?.updateLockState()
            self?.updateInterface()
        }

        self.needLocked = lockUnlockState.locked
        lockUnlockState.subscribe { [weak self] locked in
            self?.needLocked = locked
            self?.updateLockState()
            self?.updateInterface()
        }
    }

    private func parseInfo(_ info: [String: Any]) {
        
    }

    private func updateLockState() {
        if needLocked && !realLocked {
            network?.lock()
        }

        if !needLocked && realLocked {
            network?.unlock()
        }
    }

    private func updateInterface() {
        print("UPDATE INTERFACE")

        if needConnect {
            self.showWaitingState()
        } else if realLocked && needLocked {
            self.showLockState()
        } else if needLocked && !realLocked {
            self.showAlertState()
        } else if !needLocked && realLocked {
            self.showLockStateButCanUnlock()
        } else {
            self.showUnlockState()
        }
    }

    private func showAlertState() {
        activityIndicatorView.stopAnimating()

        stateView.backgroundColor = UIColor(r: 255, g: 100, b: 20)
        stateLabel.text = "Предупреждение!\nПроизошли неполадки. Оставайтесь на месте."

        stateImageView.image = UIImage(named: "RedLock")

        infoTitleLabel.text = "Ограничение доступа"
        infoStatusLabel.text = "АААААААА"
        infoStatusLabel.textColor = UIColor(r: 255, g: 80, b: 30)

        infoButtonLabel.isHidden = true
        buttonHeightConstraint?.update(offset: 0)

        infoIdView.isHidden = false
        infoIdHeightConstraint?.update(offset: 80)
        infoIdLabel.text = "ВАШ ID"
        infoIdNumberLabel.text = String(format: "%06d", network?.sessionId ?? 0)
    }

    private func showUnlockState() {
        activityIndicatorView.stopAnimating()

        stateView.backgroundColor = UIColor(r: 0, g: 57, b: 0)
        stateLabel.text = "Функции вашего телефона доступны."

        stateImageView.image = UIImage(named: "GreenUnlock")

        infoTitleLabel.text = "Ограничение доступа"
        infoStatusLabel.text = "ОТКЛЮЧЕНО"
        infoStatusLabel.textColor = UIColor(r: 68, g: 189, b: 59)

        infoButtonLabel.isHidden = false
        buttonHeightConstraint?.update(offset: 36)
        infoButtonLabel.text = "Хорошо"
        infoButtonLabel.backgroundColor = UIColor(r: 0, g: 146, b: 5)
        infoButtonLabel.textColor  = UIColor.white

        infoIdView.isHidden = true
        infoIdHeightConstraint?.update(offset: 0)
    }

    private func showLockStateButCanUnlock() {
        activityIndicatorView.stopAnimating()

        stateView.backgroundColor = UIColor(r: 88, g: 3, b: 1)
        stateLabel.text = "Функции вашего телефона ограничены.\nНо в скором времени у вас появится доступ."

        stateImageView.image = UIImage(named: "RedLock")

        infoTitleLabel.text = "Ограничение доступа"
        infoStatusLabel.text = "ВКЛЮЧЕНО"
        infoStatusLabel.textColor = UIColor(r: 211, g: 52, b: 44)

        infoButtonLabel.isHidden = true
        buttonHeightConstraint?.update(offset: 0)

        infoIdView.isHidden = false
        infoIdHeightConstraint?.update(offset: 80)
        infoIdLabel.text = "ВАШ ID"
        infoIdNumberLabel.text = String(format: "%06d", network?.sessionId ?? 0)
    }

    private func showLockState() {
        activityIndicatorView.stopAnimating()

        stateView.backgroundColor = UIColor(r: 88, g: 3, b: 1)
        stateLabel.text = "Внимание!\nФункции вашего телефона ограничены."

        stateImageView.image = UIImage(named: "RedLock")

        infoTitleLabel.text = "Ограничение доступа"
        infoStatusLabel.text = "ВКЛЮЧЕНО"
        infoStatusLabel.textColor = UIColor(r: 211, g: 52, b: 44)

        infoButtonLabel.isHidden = true
        buttonHeightConstraint?.update(offset: 0)

        infoIdView.isHidden = false
        infoIdHeightConstraint?.update(offset: 80)
        infoIdLabel.text = "ВАШ ID"
        infoIdNumberLabel.text = String(format: "%06d", network?.sessionId ?? 0)
    }

    private func showWaitingState() {
        activityIndicatorView.startAnimating()

        stateView.backgroundColor = UIColor(r: 88, g: 57, b: 1)
        stateLabel.text = "Подождите пока мы соединимся с сервером."

        stateImageView.image = nil

        infoTitleLabel.text = "Ограничение доступа"
        infoStatusLabel.text = "ОЖИДАНИЕ"
        infoStatusLabel.textColor = UIColor(r: 211, g: 189, b: 59)

        infoButtonLabel.isHidden = true
        buttonHeightConstraint?.update(offset: 0)
        infoIdView.isHidden = true
        infoIdHeightConstraint?.update(offset: 0)
    }


}

