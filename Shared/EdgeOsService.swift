//
//  EdgeOsService.swift
//  EdgeOsConfigurer
//
//  Created by Pierrick Rouxel on 18/06/2021.
//

import Foundation
import Shout

class EdgeOsService {
    
    static func connect() {
        let ssh = try SSH(host: "example.com")
        try ssh.authenticate(username: "user", privateKey: "~/.ssh/id_rsa")
        try ssh.execute("ls -a")
        try ssh.execute("pwd")
    }
}
