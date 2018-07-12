//
//  HomeReducers.swift
//  EOS
//
//  Created koofrank on 2018/7/4.
//  Copyright © 2018年 com.nbltrust. All rights reserved.
//

import UIKit
import ReSwift
import CryptoSwift

func HomeReducer(action:Action, state:HomeState?) -> HomeState {
    return HomeState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: HomePropertyReducer(state?.property, action: action))
}

func HomePropertyReducer(_ state: HomePropertyState?, action: Action) -> HomePropertyState {
    var state = state ?? HomePropertyState()
    
    switch action {
    case let action as BalanceFetchedAction:
        var viewmodel = state.info.value
        if let balance = action.balance.arrayValue.first?.string {
            viewmodel.balance = balance
          
        }
        else {
            viewmodel.balance = "- \(NetworkConfiguration.EOSIO_DEFAULT_SYMBOL)"
        }
        
        viewmodel.allAssets = calculateTotalAsset(viewmodel)
        viewmodel.CNY = calculateRMBPrice(viewmodel, price:state.CNY_price)
        
        state.info.accept(viewmodel)
        
    case let action as AccountFetchedAction:
        var viewmodel = convertAccountViewModelWithAccount(action.info, viewmodel:state.info.value)
        viewmodel.CNY = calculateRMBPrice(viewmodel, price:state.CNY_price)

        state.info.accept(viewmodel)
        
    case let action as RMBPriceFetchedAction:
        var viewmodel = state.info.value
        state.CNY_price = action.price["value"].stringValue
        
        viewmodel.CNY = calculateRMBPrice(viewmodel, price:state.CNY_price)
        state.info.accept(viewmodel)

    default:
        break
    }
    
    return state
}

func convertAccountViewModelWithAccount(_ account:Account, viewmodel:AccountViewModel) -> AccountViewModel {
    var newViewModel = viewmodel
    newViewModel.account = account.account_name
    newViewModel.portrait = account.account_name.sha256()
    newViewModel.cpuValue = account.total_resources?.cpu_weight ?? "- \(NetworkConfiguration.EOSIO_DEFAULT_SYMBOL)"
    newViewModel.netValue = account.total_resources?.net_weight ?? "- \(NetworkConfiguration.EOSIO_DEFAULT_SYMBOL)"
    
    if let ram = account.total_resources?.ram_bytes {
        newViewModel.ramValue = ram.ramCount
    }
    else {
        newViewModel.ramValue = "- \(NetworkConfiguration.EOSIO_DEFAULT_SYMBOL)"
    }
    
    if let refund_net = account.refund_request?.net_amount.eosAmount.toDouble(), let refund_cpu = account.refund_request?.cpu_amount.eosAmount.toDouble() {
        let asset = refund_cpu + refund_net
        newViewModel.recentRefundAsset = "\(asset.string(digits: AppConfiguration.EOS_PRECISION)) \(NetworkConfiguration.EOSIO_DEFAULT_SYMBOL)"
    }
    else {
        newViewModel.recentRefundAsset = "- \(NetworkConfiguration.EOSIO_DEFAULT_SYMBOL)"
    }
    
    if let date = account.refund_request?.request_time {
        newViewModel.refundTime = date.refundStatus
    }
    else {
        newViewModel.refundTime = ""
    }
    
    newViewModel.allAssets = calculateTotalAsset(newViewModel)
    
    return newViewModel
}

func calculateTotalAsset(_ viewmodel:AccountViewModel) -> String {
    if let balance = viewmodel.balance.eosAmount.toDouble(), let cpu = viewmodel.cpuValue.eosAmount.toDouble(),
        let net = viewmodel.netValue.eosAmount.toDouble() {
        let total = balance + cpu + net
        
        return total.string(digits: AppConfiguration.EOS_PRECISION) + " \(NetworkConfiguration.EOSIO_DEFAULT_SYMBOL)"
    }
    else {
        return "- \(NetworkConfiguration.EOSIO_DEFAULT_SYMBOL)"
    }
}

func calculateRMBPrice(_ viewmodel:AccountViewModel, price:String) -> String {
    if let unit = price.toDouble(), unit != 0, let all = viewmodel.allAssets.eosAmount.toDouble(), all != 0 {
        let cny = unit * all
        return "≈" + cny.string(digits: 2) + " CNY"
    }
    else {
        return "≈- CNY"
    }
}

