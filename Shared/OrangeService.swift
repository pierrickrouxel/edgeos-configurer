//
//  OrangeService.swift
//  EdgeOsConfigurer
//
//  Created by Pierrick Rouxel on 18/06/2021.
//

import Foundation
import CryptoKit

class OrangeService {
    static var st11zero = "00:00:00:00:00:00:00:00:00:00:00"
    static var idorange = "01" // variable
    static var idsalt = "3c" // 16
    static var idhash = "03" //1+16
    static var fixed = "1a:09:00:00:05:58:01:03:41"
    
    static func generateOption90(orangeAccount: OrangeAccountModel) -> String {
        
        let digest = Insecure.MD5.hash(data: "\(orangeAccount.byte)\(orangeAccount.password)\(orangeAccount.salt)".data(using: .utf8) ?? Data())

        let md5 = digest.map {
            String(format: "%02hhx", $0)
        }.joined()
        
        var md5s = "";
        for i in stride(from: 0, through: md5.count - 1, by: 2) {
            let index = md5.index(md5.startIndex, offsetBy: i)
            let index2 = md5.index(md5.startIndex, offsetBy: i + 1)
            md5s += md5[index...index2]
            if (i < md5.count - 2) {
                md5s += ":"
            }
        }
        let value = st11zero + ":" + fixed + ":" +
            tlOfTls(id: idorange, l: 2 + orangeAccount.login.count) + ":" + sOfTls(s: orangeAccount.login) + ":" +
            tlOfTls(id: idsalt, l: 2 + 16) + ":" + sOfTls(s: orangeAccount.salt) + ":" +
            tlOfTls(id: idhash, l: 2 + 1 + 16) + ":" + sOfTls(s: orangeAccount.byte) + ":" + md5s
        return value
    }
    
    private static func tlOfTls(id: String, l: Int) -> String {
        var toAdd = String(l, radix: 16, uppercase: true)
        if (toAdd.count < 2) {
            toAdd = "0" + toAdd
        }
        return id + ":" + toAdd
    }
    
    private static func sOfTls (s: String) -> String {
        var toAdd: String
        var res = ""
        for (i, char) in s.utf16.enumerated() {
            toAdd = String(char, radix: 16, uppercase: true)
            if (toAdd.count < 2) {
                toAdd = "0" + toAdd
            }
            res += toAdd;
            if (i < s.count - 1) {
                res += ":"
            }
        }
        return res;
    }
}
