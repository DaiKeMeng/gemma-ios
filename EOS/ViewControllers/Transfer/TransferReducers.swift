//
//  TransferReducers.swift
//  EOS
//
//  Created DKM on 2018/7/11.
//  Copyright © 2018年 com.nbltrust. All rights reserved.
//

import UIKit
import ReSwift

func TransferReducer(action:Action, state:TransferState?) -> TransferState {
    return TransferState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: TransferPropertyReducer(state?.property, action: action))
}

func TransferPropertyReducer(_ state: TransferPropertyState?, action: Action) -> TransferPropertyState {
    var state = state ?? TransferPropertyState()
    
    switch action {
    case let action as BalanceFetchedAction:
        if let balance = action.balance.arrayValue.first?.string {
            state.balance.accept(balance)
        }
    default:
        break
    }
    
    return state
}



