//
//  ContentView.swift
//  Shared
//
//  Created by Pierrick Rouxel on 18/06/2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var orangeAccountModel = OrangeAccountModel()
    
    var body: some View {
        Form {
            ScrollView {
                TextField("Login (starts with fti/)", text: $orangeAccountModel.login);
                TextField("Password", text: $orangeAccountModel.password)
                TextField("Salt", text: $orangeAccountModel.salt)
                TextField("Byte", text: $orangeAccountModel.byte)
                Button("Generate", action: generate)
                Section(header: Text("DHCP Option 90")) {
                    Button("Copy", action: {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(orangeAccountModel.option90, forType: .string)
                    })
                    Text(orangeAccountModel.option90)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                }
            }
        }
    }
    
    func generate() {
        orangeAccountModel.option90 = OrangeService.generateOption90(orangeAccount: orangeAccountModel);
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
