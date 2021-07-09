//
//  ConfigureView.swift
//  EdgeOsConfigurer
//
//  Created by Pierrick Rouxel on 08/07/2021.
//

import SwiftUI

struct ConfigureView: View {
    let interfaces: [EdgeOsInterface]
    
    @State var selectedInterface: EdgeOsInterface?
    
    var body: some View {
        Form {
            Section {
                Text("""
                La configuration va remplacer le client DHCP (/usr/bin/dhclient) pour tagger les paquets en priorité 6.
                Tous les paquets DHCP émis, y compris sur d'autres interfaces, sont concernés.
                Une sauvegarde de la version actuelle du client DHCP est faite avant son remplacement (/usr/bin/dhclient_).
                """)
                
                Text("Quelle interface souhaitez-vous utiliser pour le WAN ? (Connecteur branché sur l'ONT fibre)")
                Picker("Interfaces", selection: $selectedInterface) {
                    ForEach(interfaces, id: \.self) {
                        Text($0.interface ?? "")
                    }
                }
            }
            Button("Valider") {}
        }
    }
}

struct ConfigureView_Previews: PreviewProvider {
    static let interfaces = [
        EdgeOsInterface(interface: "eth0", ipAddress: "192.168.1.1/24"),
        EdgeOsInterface(interface: "lo", ipAddress: "127.0.0.1/8")
    ]
    static var previews: some View {
        ConfigureView(interfaces: interfaces)
    }
}
