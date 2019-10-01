//
//  ResultsInterfaceController.swift
//  Currency WatchKit Extension
//
//  Created by TMAN on 30/09/19.
//  Copyright © 2019 Daimler. All rights reserved.
//

import WatchKit
import Foundation


class ResultsInterfaceController: WKInterfaceController {

    
    @IBOutlet weak var table: WKInterfaceTable!
    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    @IBOutlet weak var doneButton: WKInterfaceButton!
    
    var amountToConvert = 0.0
    var fetchedCurrencies = [(symbol: String, rate: Double)]()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        guard let settings = context as? [String: String] else { return }
        guard let amount = settings["amount"] else { return }
        guard let baseCurrency = settings["base"] else { return }
        
        amountToConvert = Double(amount) ?? 50
        setTitle("\(amount) \(baseCurrency)")
        
        let defaults = UserDefaults.standard
        let selectedCurrencies = defaults.array(forKey: InterfaceController.selectedCurrenciesKey) as? [String] ?? InterfaceController.defaultCurrencies
        
        
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.fetchData(for: baseCurrency, symbols: selectedCurrencies)
        }
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    //MARK: - Helper Functions
    
    func fetchData(for baseCurrency: String, symbols: [String]) {
        
        if let url = URL(string: "http://data.fixer.io/latest?access_key=f87560545021bba1f61fbe1f55cb010b&base=\(baseCurrency)&symbols=\(symbols.joined(separator: ","))") {
            
            let urlRequest = URLRequest(url: url)
            print(urlRequest)
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                
                if let data = data {
                    self.parse(data)
                }
                else {
                    DispatchQueue.main.async {
                        self.statusLabel.setText("Fetch failed")
                        self.doneButton.setHidden(false)
                    }
                }
            }.resume()
        }
    }
    
    func parse(_ contents: Data) {
        let json = try! JSON(data: contents)
        let rates = json["rates"].dictionaryValue
        
        for symbol in rates {
            let rateName = symbol.key
            let rateValue = symbol.value.doubleValue
            fetchedCurrencies.append((symbol: rateName, rate: rateValue))
        }
        
        fetchedCurrencies.sort {
            $0.symbol < $1.symbol
        }
        
        updateTable()
        statusLabel.setHidden(true)
        table.setHidden(false)
        doneButton.setHidden(false)
    }
    
    func updateTable() {
        //load as many rows as we have currencies
        table.setNumberOfRows(fetchedCurrencies.count, withRowType: "Row")
        
        //loop over each currency, getting its position and symbol
        for (index, currency) in fetchedCurrencies.enumerated() {
            
            //find the row at that position
            guard let row = table.rowController(at: index) as? CurrencyRow else { return }
            
            //multiply the rate by the user's input amount
            let value = currency.rate * amountToConvert
            
            //convert it to a rounded string
            let formattedValue = String(format: "%.2f", value)
            
            //show it in the label
            row.textLabel.setText("\(formattedValue) \(currency.symbol)")
        }
         
    }
    
    //MARK: - IBActions
    
    @IBAction func doneButtonTapped() {
        
        WKInterfaceController.reloadRootControllers(withNames: ["home", "currencies"], contexts: nil)
    }
}
