//
//  Result.swift
//
//  Created by Tom Brodhurst-Hill on 15/9/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

public enum Result<Value> {
    case success(value: Value)
    case failure(error: Swift.Error)
}
