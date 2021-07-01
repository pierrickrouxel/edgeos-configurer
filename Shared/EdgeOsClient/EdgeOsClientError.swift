//
//  EdgeOsClientError.swift
//  EdgeOsConfigurer
//
//  Created by Pierrick Rouxel on 01/07/2021.
//

import Foundation

enum EdgeOsClientError: Error {
    case notConnected
    case executionFailed(status: Int32, output: String)
}
