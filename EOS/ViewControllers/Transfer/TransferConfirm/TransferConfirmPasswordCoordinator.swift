//
//  TransferConfirmPasswordCoordinator.swift
//  EOS
//
//  Created 朱宋宇 on 2018/7/12.
//  Copyright © 2018年 com.nbltrust. All rights reserved.
//

import UIKit
import ReSwift

protocol TransferConfirmPasswordCoordinatorProtocol {
    func finishTransfer()
}

protocol TransferConfirmPasswordStateManagerProtocol {
    var state: TransferConfirmPasswordState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<TransferConfirmPasswordState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
    
    func transferAccounts(_ password:String, account:String, amount:String, code:String ,callback:@escaping (Bool)->())
}

class TransferConfirmPasswordCoordinator: TransferConfirmRootCoordinator {
    
    lazy var creator = TransferConfirmPasswordPropertyActionCreate()
    
    var store = Store<TransferConfirmPasswordState>(
        reducer: TransferConfirmPasswordReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension TransferConfirmPasswordCoordinator: TransferConfirmPasswordCoordinatorProtocol {
    func finishTransfer() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let transferCoor = appDelegate.appcoordinator?.transferCoordinator, let transferVC = transferCoor.rootVC.topViewController as? TransferViewController {
            self.rootVC.dismiss(animated: true) {
                
            }
        }
    }
}

extension TransferConfirmPasswordCoordinator: TransferConfirmPasswordStateManagerProtocol {
    var state: TransferConfirmPasswordState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<TransferConfirmPasswordState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
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
    
    
    func transferAccounts(_ password:String, account:String, amount:String, code:String ,callback:@escaping (Bool)->()) {
        
        getPushTransaction(password, account: account, amount: amount, code: code,callback: { transaction in
            if let transaction = transaction {
                EOSIONetwork.request(target: .push_transaction(json: transaction), success: { (data) in
                    if let info = data.dictionaryObject,info["code"] == nil{
                        callback(true)
                    }else{
                        callback(false)
                    }
                }, error: { (error_code) in
                    callback(false)
                }) { (error) in
                    callback(false)
                }
            }
        })
    }
    
}
