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
        TextField("Login fti/xxx", text: $orangeAccountModel.login).padding();
        TextField("Password", text: $orangeAccountModel.password).padding();
        TextField("Salt", text: $orangeAccountModel.salt).padding();
        TextField("Byte", text: $orangeAccountModel.byte).padding();
        Button("Generate", action: generate)
        TextField("Result", text: $orangeAccountModel.option90).disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
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
