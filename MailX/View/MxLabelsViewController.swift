//
//  MxLabelsViewController.swift
//  HexaMail
//
//  Created by Tancrède on 2/14/16.
//  Copyright © 2016 Hexa. All rights reserved.
//

import Cocoa




import RxSwift
import RxCocoa



class MxLabelsViewController : NSViewController {
    
    
    // IBOutlets
    @IBOutlet weak var tableView: NSTableView!
    // todo button to open and close the labels list
    
    
    // private
    private let labelsViewModel = MxLabelsViewModel()
    private let disposeBag = DisposeBag()
    
    
    private func bindWithModel() {
        
        // bind model labels list to NSTableView
        labelsViewModel
            .labels
            .bindTo(
//                var cellConfigurer
            tableView.rx_itemsWithCellIdentifier("itemListCell")) { (row, element, cell) in
                
                guard let myCell: NSTableCellView = cell else {
                    return
                }
                
                myCell.textField?.stringValue = element.name
            }
            .addDisposableTo(disposeBag)
        
        
        tableView.rx_modelSelected(MxLabel.self)
            .subscribeNext({ (label) in
                
            })
            .addDisposableTo(disposeBag)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindWithModel()
    }
    

    
}
