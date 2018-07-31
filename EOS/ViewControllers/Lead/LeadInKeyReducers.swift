//
//  LeadInKeyReducers.swift
//  EOS
//
//  Created DKM on 2018/7/31.
//  Copyright © 2018年 com.nbltrust. All rights reserved.
//

import UIKit
import ReSwift

func LeadInKeyReducer(action:Action, state:LeadInKeyState?) -> LeadInKeyState {
    return LeadInKeyState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: LeadInKeyPropertyReducer(state?.property, action: action))
}

func LeadInKeyPropertyReducer(_ state: LeadInKeyPropertyState?, action: Action) -> LeadInKeyPropertyState {
    var state = state ?? LeadInKeyPropertyState()
    
    switch action {
    default:
        break
    }
    
    return state
}


