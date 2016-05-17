//
//  MxLabelsViewModel.swift
//  HexaMail
//
//  Created by Tancrède on 2/14/16.
//  Copyright © 2016 Hexa. All rights reserved.
//

import Foundation

import RxSwift


class MxLabelsViewModel{
    
    enum ShowLabels {
        case All
        case Defaults
    }

    // inputs
    // need to be Subject because they are Observables and Observers at the same time 
    // Variable, BehaviourSubject or PublishSubject
    var showLabels = Variable<ShowLabels>(ShowLabels.Defaults)
    var selectedLabel = PublishSubject<MxLabel>()
    
    
    // outputs
    // need to be Observable
    var labels: Observable<MxLabels>
    
    
    // private
    private let disposeBag = DisposeBag()
    private let appModel = MxAppModel.sharedModel()
    private let appProperties = HXAppProperties.defaultProperties()
    
    
    init() {
        
        labels = Observable.combineLatest(
            appModel.labels,
            showLabels.asObservable(),
            resultSelector: {(array, show) throws -> MxLabels in
                switch show {
                case .All:
                    return array
                case .Defaults:
                    return array.filter( {
                        // show only default labels
                        let defaultLabels = HXAppProperties.defaultProperties().defaultLabels()
                        return defaultLabels.contains( $0.name)
                    })
                }
        })
//            .map({(labels) -> [String] in
//                return labels.map{ $0.name}
//            })
        

    }
    
    
}