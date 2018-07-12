//
//  TransferContentView.swift
//  EOS
//
//  Created by 朱宋宇 on 2018/7/11.
//  Copyright © 2018年 com.nbltrust. All rights reserved.
//

import Foundation

@IBDesignable

class TransferContentView: UIView {
    
    @IBOutlet weak var accountTitleTextView: TitleTextfieldView!
    
    @IBOutlet weak var moneyTitleTextView: TitleTextfieldView!
    
    @IBOutlet weak var remarkTitleTextView: TitleTextView!
    
    enum InputType: Int {
        case account = 1
        case money
        case remark
    }
    
    enum TextChangeEvent: String {
        case transferAccount
        case transferMoney
        case walletRemark
    }
    
    
    func handleSetupSubView(_ titleTextfieldView : TitleTextfieldView, tag: Int) {
        titleTextfieldView.textField.tag = tag
        titleTextfieldView.textField.delegate = self
        titleTextfieldView.delegate = self
        titleTextfieldView.datasource = self
        titleTextfieldView.updateContentSize()
    }
    
    
    func setUp() {
        handleSetupSubView(accountTitleTextView, tag: InputType.account.rawValue)
        handleSetupSubView(moneyTitleTextView, tag: InputType.money.rawValue)
        updateHeight()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIViewNoIntrinsicMetric,height: dynamicHeight())
    }
    
    fileprivate func updateHeight() {
        layoutIfNeeded()
        self.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }
    
    fileprivate func dynamicHeight() -> CGFloat {
        let lastView = self.subviews.last?.subviews.last
        return (lastView?.frame.origin.y)! + (lastView?.frame.size.height)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
        setUp()

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        setUp()
    }
    
    fileprivate func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))
        let nib = UINib.init(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
}

extension TransferContentView: TitleTextFieldViewDelegate,TitleTextFieldViewDataSource {
    func textIntroduction(titleTextFieldView: TitleTextfieldView) {
        
    }
    
    func textActionSettings(titleTextFieldView: TitleTextfieldView) -> [TextButtonSetting] {
        return [TextButtonSetting(imageName: R.image.ic_close.name,
                                  selectedImageName: R.image.ic_close.name,
                                  isShowWhenEditing: true)]
    }
    
    
    func textActionTrigger(titleTextFieldView: TitleTextfieldView, selected: Bool, index: NSInteger) {
        titleTextFieldView.clearText()

    }
    
    func textUISetting(titleTextFieldView: TitleTextfieldView) -> TitleTextSetting {
        if titleTextFieldView == accountTitleTextView {
            return TitleTextSetting(title: R.string.localizable.payment_account(),
                                    placeholder: R.string.localizable.name_ph(),
                                    warningText: R.string.localizable.name_warning(),
                                    introduce: "",
                                    isShowPromptWhenEditing: true,
                                    showLine: true,
                                    isSecureTextEntry: false)
        } else if titleTextFieldView == moneyTitleTextView {
            return TitleTextSetting(title: R.string.localizable.money(),
                                    placeholder: R.string.localizable.input_transfer_money(),
                                    warningText: "",//文案未提供
                                    introduce: "",
                                    isShowPromptWhenEditing: false,
                                    showLine: true,
                                    isSecureTextEntry: true)
        } else {
            return TitleTextSetting(title: R.string.localizable.remark(),
                                    placeholder: R.string.localizable.input_transfer_remark(),
                                    warningText: "",//文案未提供
                                    introduce: "",
                                    isShowPromptWhenEditing: false,
                                    showLine: true,
                                    isSecureTextEntry: true)
        }
    }
    
    func textUnitStr(titleTextFieldView: TitleTextfieldView) -> String {
        return ""
    }
}

extension TransferContentView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField.tag {
        case InputType.account.rawValue:
            accountTitleTextView.reloadActionViews(isEditing: true)
            accountTitleTextView.checkStatus = TextUIStyle.highlight
        case InputType.money.rawValue:
            moneyTitleTextView.reloadActionViews(isEditing: true)
            moneyTitleTextView.checkStatus = TextUIStyle.highlight
        default:
            return
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case InputType.account.rawValue:
            accountTitleTextView.reloadActionViews(isEditing: false)
            accountTitleTextView.checkStatus = WallketManager.shared.isValidWalletName(textField.text!) ? TextUIStyle.common : TextUIStyle.warning
        case InputType.money.rawValue:
            moneyTitleTextView.reloadActionViews(isEditing: false)
            moneyTitleTextView.checkStatus = WallketManager.shared.isValidPassword(textField.text!) ? TextUIStyle.common : TextUIStyle.warning
       
        default:
            return
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        switch textField.tag {
        case InputType.account.rawValue:
            self.sendEventWith(TextChangeEvent.transferAccount.rawValue, userinfo: ["content" : newText])
        case InputType.money.rawValue:
            self.sendEventWith(TextChangeEvent.transferMoney.rawValue, userinfo: ["content" : newText])

        default:
            return true
        }
        return true
    }
    
    //    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
    //        UIView.animate(withDuration: 0.2) {
    //            if let titleTextView = textView.superview?.superview as? TitleTextView {
    //                titleTextView.updateHeight()
    //            }
    //            self.updateHeight()
    //        }
    //    }
}


