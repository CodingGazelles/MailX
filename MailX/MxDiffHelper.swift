//
//  MxDiffHelper.swift
//  MailX
//
//  Created by Tancrède on 6/13/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

//
//  simplediff.swift
//  simplediff
//
//  Created by Matthias Hochgatterer on 31/03/15.
//  Copyright (c) 2015 Matthias Hochgatterer. All rights reserved.
//

import Foundation

enum OperationType {
    case Insert, Delete, Noop
    
    var description: String {
        get {
            switch self {
            case .Insert: return "+"
            case .Delete: return "-"
            case .Noop: return "="
            }
        }
    }
}

/// Operation describes an operation (insertion, deletion, or noop) of elements.
struct ObjectSyncOperation {
    let type: OperationType
    let objects: [MxImplementBusinessObject]
    
    var elementsString: String {
        return objects
            .map { e in "\(e)" }
            .joinWithSeparator("")
    }
    
    var description: String {
        get {
            switch type {
            case .Insert:
                return "[+\(elementsString)]"
            case .Delete:
                return "[-\(elementsString)]"
            default:
                return "\(elementsString)"
            }
        }
    }
}

func diffMROArrays(managedObjects managedObjects: [MxBaseManagedObject], remoteObjects:[MxBaseRemoteOject]) -> [ObjectSyncOperation] {
    
    // Create map of indices for every element
    var beforeIndices = [MxRemoteId: [Int]]()
    
    for (index, elem) in managedObjects.enumerate() {
        var indices = beforeIndices.indexForKey(elem.remoteId!) != nil ? beforeIndices[elem.remoteId!]! : [Int]()
        indices.append(index)
        beforeIndices[elem.remoteId!] = indices
    }
    
    var beforeStart = 0
    var afterStart = 0
    var maxOverlayLength = 0
    var overlay = [Int: Int]() // remembers *overlayLength* of previous element
    
    for (index, elem) in remoteObjects.enumerate() {
        
        var _overlay = [Int: Int]()
        
        // Element must be in *before* list
        if let elemIndices = beforeIndices[elem.remoteId!] {
            
            // Iterate over element indices in *before*
            for elemIndex in elemIndices {
                
                var overlayLength = 1
                
                if let previousSub = overlay[elemIndex - 1] {
                    overlayLength += previousSub
                }
                
                _overlay[elemIndex] = overlayLength
                
                if overlayLength > maxOverlayLength { // longest overlay?
                    maxOverlayLength = overlayLength
                    beforeStart = elemIndex - overlayLength + 1
                    afterStart = index - overlayLength + 1
                }
            }
        }
        
        overlay = _overlay
    }
    
    var operations = [ObjectSyncOperation]()
    
    if maxOverlayLength == 0 {
        
        // No overlay; remove before and add after elements
        if managedObjects.count > 0 {
            operations.append(ObjectSyncOperation(type: .Delete, objects: managedObjects))
        }
        if managedObjects.count > 0 {
            operations.append(ObjectSyncOperation(type: .Insert, objects: remoteObjects))
        }
        
    } else {
        
        // Recursive call with elements before overlay
        operations += diffMROArrays( managedObjects: Array( managedObjects[0..<beforeStart ]),
                                    remoteObjects: Array( remoteObjects[0..<afterStart]))
        
        // Noop for longest overlay
        operations.append(
            ObjectSyncOperation(
                type: .Noop,
                objects: Array( remoteObjects[afterStart..<afterStart+maxOverlayLength].map{ $0 } )))
        
        // Recursive call with elements after overlay
        operations += diffMROArrays( managedObjects: Array(managedObjects[beforeStart+maxOverlayLength..<managedObjects.count]),
                                    remoteObjects: Array(remoteObjects[afterStart+maxOverlayLength..<remoteObjects.count]))
        
    }
    
    return operations
    
}

/// diff finds the difference between two lists.
/// This algorithm a shameless copy of simplediff https://github.com/paulgb/simplediff
///
/// :param: before Old list of elements.
/// :param: after New list of elements
/// :returns: A list of operation (insert, delete, noop) to transform the list *before* to the list *after*.
//func diff<T where T: Equatable, T: Hashable>( before before: [T], after: [T]) -> [Operation<T>] {
//    
//    // Create map of indices for every element
//    var beforeIndices = [T: [Int]]()
//    
//    for (index, elem) in before.enumerate() {
//        var indices = beforeIndices.indexForKey(elem) != nil ? beforeIndices[elem]! : [Int]()
//        indices.append(index)
//        beforeIndices[elem] = indices
//    }
//    
//    var beforeStart = 0
//    var afterStart = 0
//    var maxOverlayLength = 0
//    var overlay = [Int: Int]() // remembers *overlayLength* of previous element
//    
//    for (index, elem) in after.enumerate() {
//        
//        var _overlay = [Int: Int]()
//        // Element must be in *before* list
//        if let elemIndices = beforeIndices[elem] {
//            // Iterate over element indices in *before*
//            for elemIndex in elemIndices {
//                var overlayLength = 1
//                if let previousSub = overlay[elemIndex - 1] {
//                    overlayLength += previousSub
//                }
//                _overlay[elemIndex] = overlayLength
//                if overlayLength > maxOverlayLength { // longest overlay?
//                    maxOverlayLength = overlayLength
//                    beforeStart = elemIndex - overlayLength + 1
//                    afterStart = index - overlayLength + 1
//                }
//            }
//        }
//        overlay = _overlay
//    }
//    
//    var operations = [Operation<T>]()
//    
//    if maxOverlayLength == 0 {
//        
//        // No overlay; remove before and add after elements
//        if before.count > 0 {
//            operations.append(Operation(type: .Delete, elements: before))
//        }
//        if after.count > 0 {
//            operations.append(Operation(type: .Insert, elements: after))
//        }
//        
//    } else {
//        // Recursive call with elements before overlay
//        operations += diff( before: Array(before[0..<beforeStart]),
//                            after: Array(after[0..<afterStart]))
//        
//        // Noop for longest overlay
//        operations.append(Operation(type: .Noop, elements: Array(after[afterStart..<afterStart+maxOverlayLength])))
//        
//        // Recursive call with elements after overlay
//        operations += diff( before: Array(before[beforeStart+maxOverlayLength..<before.count]),
//                            after: Array(after[afterStart+maxOverlayLength..<after.count]))
//    }
//    
//    return operations
//}

