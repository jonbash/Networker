//
//  FetchOperationManager.swift
//  Networker
//
//  Created by Jon Bash on 2020-01-26.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

class FetchOperationManager<Index: Hashable, FetchedModel> {
    private let cache = Cache<Index, FetchedModel>()
}
