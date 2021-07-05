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
        
        let (status, output) = try ssh!.capture("vbash -ic \"show interfaces\"")
        
        guard status == 0 else {
            throw EdgeOsClientError.executionFailed(status: status, output: output)
        }
        
        return output
    }
    
    private func parseLines(_ output: String) -> [Dictionary<String?, String?>] {
        let lines = output.components(separatedBy: "\n").filter { line in
            !line.trimmingCharacters(in: .whitespaces).isEmpty
        }
        
        let separatorLineIndex = lines.firstIndex { line in
            return line.range(of: "^[ -]+$", options: .regularExpression) != nil
        }
        
        if (separatorLineIndex == nil) {
            return Array()
        }

        var result: [Dictionary<String?, String?>] = []
        
        let columnRanges = getColumnRanges(lines[separatorLineIndex!])
        let columnTitles = getColumnValues(lines[lines.index(before: separatorLineIndex!)], columnRanges: columnRanges);
        let bodyLines = lines[lines.index(after: separatorLineIndex!)...]
        bodyLines
            .forEach { line in
                let columnValues = getColumnValues(line, columnRanges: columnRanges);
                columnTitles.enumerated().forEach { index, columnTitle in
                    result.append([columnTitle: columnValues[index]])
                }
            }
        return result
    }
    
    private func getColumnValues(_ line: String, columnRanges: [ClosedRange<String.Index>]) -> [String?] {
        return columnRanges.map { columnRange in
            return getColumnValue(line, columnRange: columnRange)
        }
    }
    
    private func getColumnValue(_ line: String, columnRange: ClosedRange<String.Index>) -> String? {
        guard !line.isEmpty &&
                line.startIndex <= columnRange.lowerBound &&
                line.endIndex >= columnRange.upperBound
        else {
            return nil
        }
        
        let value = String(line[columnRange]).trimmingCharacters(in: .whitespaces)
        
        return value.isEmpty ? nil : value
    }
    
    private func getColumnRanges(_ separatorLine: String) -> [ClosedRange<String.Index>] {
        return getColumnRanges(separatorLine, offset: separatorLine.startIndex)
    }
    
    private func getColumnRanges(_ separatorLine: String,
                                 offset: String.Index,
                                 positions: [ClosedRange<String.Index>] = Array()) -> [ClosedRange<String.Index>] {
        guard let start = separatorLine[offset...].firstIndex(of: "-") else {
            return positions;
        }
        
        guard let end = separatorLine.firstIndex(of: " "),
              let nextHyphen = separatorLine[end...].firstIndex(of: "-")
        else {
            return positions + [start...separatorLine.endIndex]
        }
        
        return positions + [start...separatorLine.index(before: nextHyphen)]
    }
}
