//
//  NetworkLogStore.swift
//  BobPTCore
//
//  Created by Codex on 5/21/26.
//

import Foundation

public struct NetworkLogEntry: Identifiable, Codable {
    public let id = UUID()
    public let timestamp: Date
    public let category: String
    public let method: String
    public let url: String
    public let requestHeaders: [String: String]
    public let requestBody: String?
    public let statusCode: Int?
    public let responseHeaders: [String: String]
    public let responseBody: String?
    public let errorMessage: String?
}

public actor NetworkLogStore {
    public static let shared = NetworkLogStore()

    private var entries: [NetworkLogEntry] = []
    private var continuations: [UUID: AsyncStream<[NetworkLogEntry]>.Continuation] = [:]

    private let maxEntryCount = 200
    private let storageKey = "network_log_entries"

    private init() {
        loadStoredEntries()
    }

    public func append(_ entry: NetworkLogEntry) {
        entries.insert(entry, at: 0)

        if entries.count > maxEntryCount {
            entries.removeLast(entries.count - maxEntryCount)
        }

        persist()
        broadcast()
    }

    public func clear() {
        entries.removeAll()
        persist()
        broadcast()
    }

    public func stream() -> AsyncStream<[NetworkLogEntry]> {
        let id = UUID()

        return AsyncStream { continuation in
            continuations[id] = continuation
            continuation.yield(entries)

            continuation.onTermination = { [weak self] _ in
                Task {
                    await self?.removeContinuation(id: id)
                }
            }
        }
    }

    private func removeContinuation(id: UUID) {
        continuations.removeValue(forKey: id)
    }

    private func broadcast() {
        continuations.values.forEach { continuation in
            continuation.yield(entries)
        }
    }

    private func loadStoredEntries() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([NetworkLogEntry].self, from: data) else {
            return
        }

        entries = Array(decoded.prefix(maxEntryCount))
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(entries) else {
            return
        }

        UserDefaults.standard.set(data, forKey: storageKey)
    }
}

public enum NetworkLogger {
    public static func logEvent(
        category: String,
        title: String,
        metadata: [String: String] = [:],
        error: Error? = nil
    ) {
        let entry = NetworkLogEntry(
            timestamp: Date(),
            category: category,
            method: "EVENT",
            url: title,
            requestHeaders: [:],
            requestBody: metadata.isEmpty ? nil : formatted(metadata),
            statusCode: nil,
            responseHeaders: [:],
            responseBody: nil,
            errorMessage: error.map { String(describing: $0) }
        )

        Task {
            await NetworkLogStore.shared.append(entry)
        }
    }

    public static func log(
        category: String,
        request: URLRequest?,
        response: HTTPURLResponse?,
        responseData: Data?,
        error: Error?
    ) {
        let entry = NetworkLogEntry(
            timestamp: Date(),
            category: category,
            method: request?.httpMethod ?? "-",
            url: request?.url?.absoluteString ?? "-",
            requestHeaders: redactedHeaders(request?.allHTTPHeaderFields),
            requestBody: formattedBody(from: request?.httpBody),
            statusCode: response?.statusCode,
            responseHeaders: redactedHeaders(response?.allHeaderFields),
            responseBody: formattedBody(from: responseData),
            errorMessage: error.map { String(describing: $0) }
        )

        Task {
            await NetworkLogStore.shared.append(entry)
        }
    }

    private static func formattedBody(from data: Data?) -> String? {
        guard let data, !data.isEmpty else {
            return nil
        }

        if let object = try? JSONSerialization.jsonObject(with: data),
           JSONSerialization.isValidJSONObject(object),
           let sanitized = sanitizeJSON(object),
           let sanitizedData = try? JSONSerialization.data(withJSONObject: sanitized, options: [.prettyPrinted]),
           let string = String(data: sanitizedData, encoding: .utf8) {
            return truncated(string)
        }

        if let string = String(data: data, encoding: .utf8) {
            return truncated(string)
        }

        return truncated(data.base64EncodedString())
    }

    private static func sanitizeJSON(_ value: Any) -> Any? {
        switch value {
        case let dictionary as [String: Any]:
            return dictionary.reduce(into: [String: Any]()) { result, item in
                let key = item.key
                let lowercasedKey = key.lowercased()

                if isSensitive(key: lowercasedKey) {
                    result[key] = masked(String(describing: item.value))
                } else {
                    result[key] = sanitizeJSON(item.value)
                }
            }
        case let array as [Any]:
            return array.map { sanitizeJSON($0) as Any }
        default:
            return value
        }
    }

    private static func redactedHeaders(_ headers: [AnyHashable: Any]?) -> [String: String] {
        guard let headers else {
            return [:]
        }

        return headers.reduce(into: [String: String]()) { result, item in
            let key = String(describing: item.key)
            let value = String(describing: item.value)

            result[key] = isSensitive(key: key.lowercased()) ? masked(value) : truncated(value)
        }
    }

    private static func isSensitive(key: String) -> Bool {
        key.contains("authorization")
            || key.contains("token")
            || key.contains("secret")
            || key.contains("password")
            || key.contains("cookie")
    }

    private static func masked(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.count > 8 else {
            return "***"
        }

        let prefix = trimmed.prefix(4)
        let suffix = trimmed.suffix(2)
        return "\(prefix)...\(suffix)"
    }

    private static func truncated(_ value: String, limit: Int = 4000) -> String {
        guard value.count > limit else {
            return value
        }

        let endIndex = value.index(value.startIndex, offsetBy: limit)
        return "\(value[..<endIndex])\n...<truncated>"
    }

    private static func formatted(_ dictionary: [String: String]) -> String {
        dictionary
            .sorted { $0.key < $1.key }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
    }
}
