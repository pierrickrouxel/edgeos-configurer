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
    
    /// Connects the SSH client.
    func connect() throws {
        ssh = try SSH(host: host, port: port);
        try ssh?.authenticate(username: username, password: password)
    }
    
    /// Run the command `show interfaces`.
    ///
    /// - Returns: The list of interfaces.
    func showInterfaces() throws -> [EdgeOsInterface] {
        let interfacesOutput = try execute("show interfaces")
        
        return parseOutput(interfacesOutput).compactMap { line in
            return EdgeOsInterface(interface: line["Interface"] ?? nil,
                                   ipAddress: line["IP Address"] ?? nil)
        }
    }
    
    /// Execute a command on the remote EdgeOS.
    ///
    /// - Returns: The output.
    public func execute(_ command: String) throws -> String {
        guard ssh != nil else {
            throw EdgeOsClientError.notConnected
        }
        
        let (status, output) = try ssh!.capture("vbash -ic \"\(command)\"")
        
        guard status == 0 else {
            throw EdgeOsClientError.executionFailed(status: status, output: output)
        }
        
        return output
    }
    
    /// Parse output to an array of dictionaries.
    ///
    /// - Returns: The output representation.
    private func parseOutput(_ output: String) -> [[String: String?]] {
        let lines = output.components(separatedBy: "\n").filter { line in
            !line.trimmingCharacters(in: .whitespaces).isEmpty
        }
        
        return parseLines(lines)
    }
    
    /// Parse lines to an array of dictionaries.
    ///
    /// - Returns: The lines representation.
    private func parseLines(_ lines: [String]) -> [[String: String?]] {
        guard let separatorLineIndex = getSeparatorLineIndex(lines) else {
            return []
        }
        
        let columnDescriptors = getColumnDescriptors(lines, separatorLineIndex: separatorLineIndex)
        
        let bodyLines = lines[lines.index(after: separatorLineIndex)...]
        
        return bodyLines.map { line in
            parseLine(line, columnDescriptors: columnDescriptors)
        }
    }
    
    /// Parse line to a dictionary.
    ///
    /// - Returns: The representation of line.
    private func parseLine(_ line: String, columnDescriptors: [Range<String.Index>: String]) -> [String: String?] {
        return columnDescriptors.reduce([:]) { (columns, entry) in
            columns.merging([entry.value: getColumnValue(line, columnRange: entry.key)]) { $1 }
        }
    }
    
    /// Get the title of columns by its ranges.
    ///
    /// - Returns: The column description in a dictionary.
    private func getColumnDescriptors(_ lines: [String], separatorLineIndex: Int) -> [Range<String.Index>: String] {
        let columnRanges = getColumnRanges(lines[separatorLineIndex])
        let titleLine = lines[lines.index(before: separatorLineIndex)]
        
        return columnRanges.reduce([:]) { description, range in
            guard let columnTitle = getColumnValue(titleLine, columnRange: range) else {
                return description
            }
            return description.merging([range: columnTitle]) { $1 }
        }
    }
    
    /// Get the index of line containing seperators.
    ///
    /// - Returns: The separator line's index.
    private func getSeparatorLineIndex(_ lines: [String]) -> Int? {
        lines.firstIndex { line in
            line.range(of: "^[ -]+$", options: .regularExpression) != nil
        }
    }
    
    /// Get a value of a column in line.
    ///
    /// - Returns: The column's value.
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
    
    /// Compute the ranges of columns from the separator line.
    ///
    /// - Returns: The column ranges in an array.
    private func getColumnRanges(_ separatorLine: String, offset: String.Index? = nil) -> [Range<String.Index>] {
        let startIndex = offset ?? separatorLine.startIndex
        
        guard (separatorLine.startIndex..<separatorLine.endIndex).contains(startIndex) else {
            return []
        }
        
        guard let range = separatorLine.range(of: "^-+ *",
                                              options: .regularExpression,
                                              range: startIndex..<separatorLine.endIndex) else {
            return []
        }
        
        return [range] + getColumnRanges(separatorLine, offset: range.upperBound)
    }
}
