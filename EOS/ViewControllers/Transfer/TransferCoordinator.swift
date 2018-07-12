//
//  TransferCoordinator.swift
//  EOS
//
//  Created DKM on 2018/7/11.
//  Copyright © 2018年 com.nbltrust. All rights reserved.
//

import UIKit
import ReSwift
import PromiseKit
import AwaitKit
import Presentr

protocol TransferCoordinatorProtocol {
    func pushToTransferConfirmVC()
    
}

protocol TransferStateManagerProtocol {
    var state: TransferState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<TransferState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
    
    func fetchUserAccount()
    
    func transferAccounts(_ password:String, account:String, amount:String, code:String)
    
    func checkAccountName(_ name:String) ->(Bool,error_info:String)
}

class TransferCoordinator: TransferRootCoordinator {
    
    lazy var creator = TransferPropertyActionCreate()
    
    var store = Store<TransferState>(
        reducer: TransferReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension TransferCoordinator: TransferCoordinatorProtocol {
    func pushToTransferConfirmVC() {
        let presenter = Presentr(presentationType: .bottomHalf)
        let controller = R.storyboard.transfer.transferConfirmViewController()
        
//        let coor = TransferRootCoordinator(rootVC: <#T##BaseNavigationController#>)
        let newVC = BaseNavigationController.init(rootViewController: controller!)
        
        self.rootVC.topViewController?.customPresentViewController(presenter, viewController: newVC, animated: true, completion: nil)
    }
}

extension TransferCoordinator: TransferStateManagerProtocol {
    var state: TransferState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<TransferState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
    func fetchUserAccount() {
        EOSIONetwork.request(target: .get_account(account: WallketManager.shared.getAccount()), success: { (data) in
            
        }, error: { (error_code) in
            
        }) { (error) in
            
        }
    }
    
    func checkAccountName(_ name:String) ->(Bool,error_info:String){
        return (WallketManager.shared.isValidWalletName(name),R.string.localizable.name_ph.key.localized())
    }
    
    func getInfo(callback:@escaping (String)->()){
        EOSIONetwork.request(target: .get_info, success: { (data) in
            print("get_info : \(data)")
            callback(data.stringValue)
        }, error: { (error_code) in
            
        }) { (error) in
            
        }
    }
    
    func getPushTransaction(_ password : String,account:String, amount:String, code:String ,callback:@escaping (String?)->()){
        
        getInfo { (get_info) in
            let privakey = WallketManager.shared.getCachedPriKey(password)
            let json = EOSIO.getAbiJsonString(NetworkConfiguration.EOSIO_DEFAULT_CODE, action: EOSAction.transfer.rawValue, from: WallketManager.shared.getAccount(), to: account, quantity: amount + " " + NetworkConfiguration.EOSIO_DEFAULT_SYMBOL, memo: code)

            EOSIONetwork.request(target: .abi_json_to_bin(json:json!), success: { (data) in
                let abiStr = data.stringValue
                
               let transation = EOSIO.getTransaction(privakey,
                                     code: NetworkConfiguration.EOSIO_DEFAULT_CODE,
                                     from: account,
                    to: WallketManager.shared.getAccount(),
                    quantity: amount,
                    memo: code,
                    getinfo: get_info,
                    abistr: abiStr)
                callback(transation)
            }, error: { (error_code) in
                
            }) { (error) in
                
            }
        }
        
    }
    
    func ValidingPassword(_ password : String) -> Bool{
        return WallketManager.shared.isValidPassword(password)
    }

    
    func transferAccounts(_ password:String, account:String, amount:String, code:String) {
        
        getPushTransaction(password, account: account, amount: amount, code: code,callback: { transaction in
            if let transaction = transaction {
                EOSIONetwork.request(target: .push_transaction(json: transaction), success: { (data) in
                    
                }, error: { (error_code) in
                    
                }) { (error) in
                    
                }
            }
        })
    }
}
