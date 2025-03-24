//
//  CurrencyModel.swift
//  Cosmos
//
//  Created by James Williams on 3/24/25.
//

import Foundation
import Combine

class CurrencyModel: ObservableObject {
    @Published var balance: Int = 0 {
        didSet { saveData() }
    }
    
    private let currencyKey = "CurrencyBalance"
    
    init() {
        loadData()
    }
    
    func earn(amount: Int) {
        balance += amount
    }
    
    private func saveData() {
        UserDefaults.standard.set(balance, forKey: currencyKey)
    }
    
    private func loadData() {
        balance = UserDefaults.standard.integer(forKey: currencyKey)
    }
}
