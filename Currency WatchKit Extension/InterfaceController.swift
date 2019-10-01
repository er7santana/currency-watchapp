//
//  InterfaceController.swift
//  Currency WatchKit Extension
//
//  Created by TMAN on 30/09/19.
//  Copyright © 2019 Daimler. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var amountLabel: WKInterfaceLabel!
    @IBOutlet weak var amountSlider: WKInterfaceSlider!
    @IBOutlet weak var currencyPicker: WKInterfacePicker!
    
    static let currencies = ["BRL", "CAD", "EUR", "GBP", "JPY", "USD"]
    static let defaultCurrencies = ["BRL", "USD"]
    var currentCurrency = "EUR"
    var currentAmout = 500
    static let selectedCurrenciesKey = "SelectedCurrencies"
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        amountLabel.setText(String(currentAmout))
        var items = [WKPickerItem]()
        
        for currency in InterfaceController.currencies {
            
            let item = WKPickerItem()
            item.title = currency
            items.append(item)
        }
        
        currencyPicker.setItems(items)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        currencyPicker.setSelectedItemIndex(InterfaceController.currencies.firstIndex(of: "EUR")!)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    //MARK: - IBActions
    
    @IBAction func convertTapped() {
        let context = ["amount" : String(currentAmout), "base" : currentCurrency]
        WKInterfaceController.reloadRootControllers(withNames: ["Results"], contexts: [context])
    }
    
    @IBAction func amountChanged(_ value: Float) {
        currentAmout = Int(value)
        amountLabel.setText(String(currentAmout))
    }
    
    @IBAction func baseCurrencyChanged(_ value: Int) {
        currentCurrency = InterfaceController.currencies[value]
    }
    
}
