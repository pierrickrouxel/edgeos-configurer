//
//  FormView.swift
//  EdgeOsConfigurer
//
//  Created by Pierrick Rouxel on 08/07/2021.
//

import SwiftUI

struct FormView: View {
    let interfaces: [EdgeOsInterface]
    
    @State var selectedInterface: EdgeOsInterface?
    
    var body: some View {
        Form {
            Section {
                Picker("Interfaces", selection: $selectedInterface) {
                    ForEach(interfaces, id: \.self) {
                        Text($0.interface ?? "")
                    }
                }
            }
        }
    }
}

struct FormView_Previews: PreviewProvider {
    static let interfaces = [
        EdgeOsInterface(interface: "eth0", ipAddress: "192.168.1.1/24"),
        EdgeOsInterface(interface: "lo", ipAddress: "127.0.0.1/8")
    ]
    static var previews: some View {
        FormView(interfaces: interfaces)
    }
}
