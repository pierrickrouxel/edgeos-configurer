//
//  EdgeOsClient.swift
//  EdgeOsConfigurer
//
//  Created by Pierrick Rouxel on 18/06/2021.
//

import Foundation
import Shout

class EdgeOsClient {
    var host: String
    var username: String
    var password: String
    var port: Int32 = 22
    
    var ssh: SSH?;
    
    init(host: String, port: Int32, username: String, password: String) {
        self.host = host
        self.port = port
        self.username = username
        self.password = password
    }
    
    func connect() throws {
        ssh = try SSH(host: host, port: port);
        try ssh?.authenticate(username: username, password: password)
    }
    
    func showInterfaces() throws -> [String] {
        let interfacesOutput = try execute("vbash -ic \"show interfaces\"")
        
        return parseLines(interfacesOutput)
    }
    
    private func execute(_ command: String) throws -> String {
        guard ssh != nil else {
            throw EdgeOsClientError.notConnected
        }
        
        let (status, output) = try ssh!.capture("vbash -ic \"show interfaces\"")
        
        guard status == 0 else {
            throw EdgeOsClientError.executionFailed(status: status, output: output)
        }
        
        return output
    }
    
    private func parseLines(_ output: String) -> [String] {
        let lines = output.components(separatedBy: "\n").dropFirst()
        return Array(lines)
    }
    
    private func parsePositions(_ separatorLine: String) -> [(start: String.Index, end: String.Index)] {
        
        return parsePositions(separatorLine, offset: separatorLine.startIndex)
    }
    
    private func parsePositions(_ separatorLine: String, offset: String.Index, positions: [(start: String.Index, end: String.Index)] = Array()) -> [(start: String.Index, end: String.Index)] {
        var newArray = Array(positions)
        
        guard let start = separatorLine[offset...].firstIndex(of: "-") else {
            return newArray;
        }
        
        guard let end = separatorLine.firstIndex(of: " "),
              let nextHyphen = separatorLine[end...].firstIndex(of: "-")
        else {
            newArray = newArray.append((start, separatorLine.endIndex))
            return newArray
        }
        
        newArray.append((start, separatorLine.index(before: nextHyphen)))
        return newArray
    }
    
    private func parseHeader(_ line: String) -> [String] {
        return Array();
    }
}
