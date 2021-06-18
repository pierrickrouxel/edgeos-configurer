//
//  OrangeAccountModel.swift
//  EdgeOsConfigurer
//
//  Created by Pierrick Rouxel on 18/06/2021.
//

import Foundation

class OrangeAccountModel: ObservableObject {
    @Published var login = ""
    @Published var password = ""
    @Published var salt = "1234567890123456"
    @Published var byte = "A"
    @Published var option90 = ""
}
