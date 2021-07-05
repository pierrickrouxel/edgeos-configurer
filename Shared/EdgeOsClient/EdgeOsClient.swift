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
    
    func showInterfaces() throws -> [Dictionary<String?, String?>] {
        let interfacesOutput = try execute("vbash -ic \"show interfaces\"")
        
        return parseLines(interfacesOutput)
    }
    
    private func execute(_ command: String) throws -> String {
        guard ssh != nil else {
            throw EdgeOsClientError.notConnected
        }
        
        let (status, output) = try ssh!.capture(command)
        
        guard status == 0 else {
            throw EdgeOsClientError.executionFailed(status: status, output: output)
        }
        
        return output
    }
    
    private func parseLines(_ output: String) -> [[String?: String?]] {
        let lines = output.components(separatedBy: "\n").filter { line in
            !line.trimmingCharacters(in: .whitespaces).isEmpty
        }
        
        guard let separatorLineIndex = getSeparatorLineIndex(lines) else {
            return []
        }
        
        let bodyLines = lines[lines.index(after: separatorLineIndex)...]
        
        let columnDescriptors = getColumnDescriptors(lines, separatorLineIndex: separatorLineIndex)
        
        return bodyLines.map { line in
            columnDescriptors.reduce([:]) { (columns, entry) in
                columns.merging([entry.value: getColumnValue(line, columnRange: entry.key)]) { $1 }
            }
        }
    }
    
    private func getColumnDescriptors(_ lines: [String], separatorLineIndex: Int) -> [Range<String.Index>: String?] {
        let columnRanges = getColumnRanges(lines[separatorLineIndex])
        let titleLine = lines[lines.index(before: separatorLineIndex)]
        
        return columnRanges.reduce([:]) { description, range in
            description.merging([range: getColumnValue(titleLine, columnRange: range)]) { $1 }
        }
    }
    
    private func getSeparatorLineIndex(_ lines: [String]) -> Int? {
        lines.firstIndex { line in
            line.range(of: "^[ -]+$", options: .regularExpression) != nil
        }
    }
    
    private func getColumnValue(_ line: String, columnRange: Range<String.Index>) -> String? {
        guard !line.isEmpty &&
                line.startIndex <= columnRange.lowerBound &&
                line.endIndex >= columnRange.upperBound
        else {
            return nil
        }
        
        let value = String(line[columnRange]).trimmingCharacters(in: .whitespaces)
        
        return value.isEmpty ? nil : value
    }
    
    private func getColumnRanges(_ separatorLine: String, offset: String.Index? = nil) -> [Range<String.Index>] {
        let startIndex = offset ?? separatorLine.startIndex
        
        if !(separatorLine.startIndex..<separatorLine.endIndex).contains(startIndex) {
            return []
        }
        
        guard
            let range = separatorLine.range(of: "^-+ *", options: .regularExpression, range: startIndex..<separatorLine.endIndex)
        else {
            return []
        }
        
        return [range] + getColumnRanges(separatorLine, offset: range.upperBound)
    }
}
