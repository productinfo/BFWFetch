//
//  KeyPathsFetchable.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 29/11/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

public protocol KeyPathsFetchable: Observable {
    
    func request<T>(for keyPath: KeyPath<Self, T>) throws -> URLRequest
    
}

public extension KeyPathsFetchable {
    
    public func fetch<T: Decodable>(keyPath: ReferenceWritableKeyPath<Self, T>) throws {
        post(keyPath: keyPath, event: .inProgress)
        let request = try self.request(for: keyPath)
        T.fetch(with: request) { result in
            switch result {
            case .success(let value):
                self[keyPath : keyPath] = value
            case .failure(let error):
                debugPrint("fetch error = \(error)")
                // The post below takes care of notifying observers of the failure.
            }
            self.post(keyPath: keyPath, event: result.event)
        }
    }
    
}