//
//  ConnectView.swift
//  EdgeOsConfigurer
//
//  Created by Pierrick Rouxel on 09/07/2021.
//

import SwiftUI
import Combine

struct ConnectView: View {
    @State var host = ""
    @State var port = ""
    @State var username = ""
    @State var password = ""
    
    var body: some View {
        Form {
            TextField("Host", text: $host)
            TextField("Port", text: $port).onReceive(Just(port)) { newValue in
                let filtered = newValue.filter { "0123456789".contains($0)
                }
                if filtered != newValue {
                    port = filtered
                }
            }
            TextField("Username", text: $username)
            TextField("Password", text: $password)
            Button("Valider") {}
        }
    }
}

struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectView()
    }
}
