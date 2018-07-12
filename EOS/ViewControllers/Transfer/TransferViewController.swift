//
//  TransferViewController.swift
//  EOS
//
//  Created DKM on 2018/7/11.
//  Copyright © 2018年 com.nbltrust. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import Presentr

class TransferViewController: BaseViewController {

    @IBOutlet weak var reciverLabel: UILabel!
    @IBOutlet weak var transferContentView: TransferContentView!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var nextButton: Button!
    var coordinator: (TransferCoordinatorProtocol & TransferStateManagerProtocol)?

	override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setupEvent()
        self.coordinator?.fetchUserAccount()
    }
    
    func setUpUI() {
        self.accountTextField.delegate = self
        self.accountTextField.placeholder = R.string.localizable.account_name()
        self.reciverLabel.text = R.string.localizable.receiver()
        
        
    }
    
    func commonObserveState() {
        coordinator?.subscribe(errorSubscriber) { sub in
            return sub.select { state in state.errorMessage }.skipRepeats({ (old, new) -> Bool in
                return false
            })
        }
        
        coordinator?.subscribe(loadingSubscriber) { sub in
            return sub.select { state in state.isLoading }.skipRepeats({ (old, new) -> Bool in
                return false
            })
        }
    }
    
    func setupEvent() {
        nextButton.button.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] tap in
            guard let `self` = self else { return }
            
            let presenter = Presentr(presentationType: .bottomHalf)
            let controller = TransferConfirmViewController()
            
            self.customPresentViewController(presenter, viewController: controller, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    override func configureObserveState() {
        commonObserveState()
        
    }
    
    
    
}


extension TransferViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == accountTextField {
            
            let isValid = WallketManager.shared.isValidWalletName(textField.text!)
            if isValid == false {
                self.reciverLabel.text = R.string.localizable.name_warning()
                self.reciverLabel.textColor = UIColor.scarlet
            } else {
                self.reciverLabel.text = R.string.localizable.receiver()
            }
            
            if textField.text == nil || textField.text == "" {
                self.reciverLabel.text = R.string.localizable.receiver()
            }
        }
    }
}
