//
//  HomeViewController.swift
//  EOS
//
//  Created koofrank on 2018/7/4.
//  Copyright © 2018年 com.nbltrust. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import HandyJSON
import SwiftyJSON

class HomeViewController: BaseViewController {
    @IBOutlet weak var mBgView: UIView!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeaderView: HomeHeaderView!
    
    var coordinator: (HomeCoordinatorProtocol & HomeStateManagerProtocol)?
    
    var data : Any?
	override func viewDidLoad() {
        super.viewDidLoad()
//        mWalletView.upDateImgView(mView: mBgView)
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        coordinator?.getAccountInfo(WallketManager.shared.getAccount())
    }
    
    func setupUI(){
        let nibString = R.nib.homeTableCell.identifier
        tableView.register(UINib.init(nibName: nibString, bundle: nil), forCellReuseIdentifier: nibString)
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
    
    override func configureObserveState() {
        commonObserveState()
        
        coordinator?.state.property.info.asObservable().subscribe(onNext: {[weak self] (model) in
            guard let `self` = self else { return }
            
            
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}
extension HomeViewController : UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nibString = String.init(describing:type(of: HomeTableCell()))

        let cell = tableView.dequeueReusableCell(withIdentifier: nibString, for: indexPath) as! HomeTableCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        coordinator?.pushPaymentDetail()
        coordinator?.pushPayment()
    }
}
