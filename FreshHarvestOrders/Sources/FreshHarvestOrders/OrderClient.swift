//
//  OrderClient.swift
//  FreshHarvestOrders
//
//  Places and reads orders through a configurable HTTP base URL.
//
//  JSONPlaceholder (https://jsonplaceholder.typicode.com/) has no `/orders`
//  resource. `/posts` is the closest fit: `userId` is the customer, `title`
//  is the order summary, and `body` carries the lines, total, mode and address
//  as a JSON string. `/todos` only has a title and a boolean, so a cart would
//  not survive the round trip.
//
//  Writes on JSONPlaceholder are fake. `POST /posts` returns 201 and echoes
//  the payload with `id` 101, but `GET /posts/101` is 404. `GET /posts/1`
//  returns a real stored post in the same shape.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// HTTP status plus the order decoded from the response body.
public struct OrderExchange: Equatable, Sendable {
    public var statusCode: Int
    public var order: Order

    public init(statusCode: Int, order: Order) {
        self.statusCode = statusCode
        self.order = order
    }
}

public enum OrderClientError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyOrder
    case invalidBaseURL
    case invalidResponse
    case unexpectedStatus(Int)
    case notFound(id: Int)
    case decodingFailed

    public var description: String {
        switch self {
        case .emptyOrder:
            return "El pedido no tiene líneas."
        case .invalidBaseURL:
            return "La URL base del API de pedidos no es válida."
        case .invalidResponse:
            return "La respuesta no es HTTP."
        case .unexpectedStatus(let code):
            return "El API de pedidos respondió HTTP \(code)."
        case .notFound(let id):
            return "No existe el pedido \(id) (HTTP 404)."
        case .decodingFailed:
            return "No se pudo decodificar la respuesta como un post de pedido."
        }
    }
}

/// Client for `POST /posts` and `GET /posts/:id`. `baseURL` defaults to JSONPlaceholder
/// and can be overridden per call or with the `ORDER_API_BASE_URL` environment variable.
public final class OrderClient {
    public static let jsonPlaceholderBaseURL = URL(string: "https://jsonplaceholder.typicode.com")!

    public let baseURL: URL
    private let session: URLSession

    public init(baseURL: URL? = nil, session: URLSession? = nil) {
        if let baseURL {
            self.baseURL = baseURL
        } else if let raw = ProcessInfo.processInfo.environment["ORDER_API_BASE_URL"],
                  let url = URL(string: raw) {
            self.baseURL = url
        } else {
            self.baseURL = Self.jsonPlaceholderBaseURL
        }

        if let session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.timeoutIntervalForRequest = 30
            configuration.timeoutIntervalForResource = 30
            self.session = URLSession(configuration: configuration)
        }
    }

    /// Creates an order. On JSONPlaceholder the success response is HTTP 201
    /// and the body is the post we sent, plus a server-assigned `id`.
    public func createOrder(_ draft: OrderDraft) async throws -> OrderExchange {
        guard !draft.lines.isEmpty else { throw OrderClientError.emptyOrder }
        let payload = try OrderPostMapping.encodePost(from: draft)
        let body = try JSONEncoder().encode(payload)
        let (data, status) = try await send(
            method: "POST",
            path: "/posts",
            body: body,
            success: { (200 ... 201).contains($0) }
        )
        let order = try OrderPostMapping.decodeOrder(from: data)
        return OrderExchange(statusCode: status, order: order)
    }

    /// Reads one order. HTTP 404 throws `OrderClientError.notFound`, which is
    /// what JSONPlaceholder returns for an id that a previous POST only faked.
    public func fetchOrder(id: Int) async throws -> OrderExchange {
        let (data, status) = try await send(
            method: "GET",
            path: "/posts/\(id)",
            body: nil,
            success: { $0 == 200 },
            notFoundID: id
        )
        let order = try OrderPostMapping.decodeOrder(from: data)
        return OrderExchange(statusCode: status, order: order)
    }

    // MARK: - HTTP

    private func send(
        method: String,
        path: String,
        body: Data?,
        success: (Int) -> Bool,
        notFoundID: Int? = nil
    ) async throws -> (Data, Int) {
        let url = try endpoint(path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body {
            request.httpBody = body
            request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw OrderClientError.invalidResponse
        }
        if http.statusCode == 404, let notFoundID {
            throw OrderClientError.notFound(id: notFoundID)
        }
        guard success(http.statusCode) else {
            throw OrderClientError.unexpectedStatus(http.statusCode)
        }
        return (data, http.statusCode)
    }

    private func endpoint(_ path: String) throws -> URL {
        guard let scheme = baseURL.scheme, scheme == "http" || scheme == "https", baseURL.host != nil else {
            throw OrderClientError.invalidBaseURL
        }
        let root = baseURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: root + path) else {
            throw OrderClientError.invalidBaseURL
        }
        return url
    }
}

// MARK: - Post mapping

struct OrderPayload: Codable, Equatable {
    var lines: [OrderLine]
    var totalCents: Int
    var mode: String
    var address: String
}

struct PostWrite: Encodable, Equatable {
    var userId: Int
    var title: String
    var body: String
}

struct PostRead: Decodable, Equatable {
    var userId: Int
    var id: Int
    var title: String
    var body: String
}

/// Maps a Fresh Harvest order onto a JSONPlaceholder post and back.
enum OrderPostMapping {
    static func encodePost(from draft: OrderDraft) throws -> PostWrite {
        let payload = OrderPayload(
            lines: draft.lines,
            totalCents: draft.totalCents,
            mode: draft.mode,
            address: draft.address
        )
        let encoded = try JSONEncoder().encode(payload)
        guard let body = String(data: encoded, encoding: .utf8) else {
            throw OrderClientError.decodingFailed
        }
        return PostWrite(userId: draft.customerId, title: draft.summary, body: body)
    }

    static func decodeOrder(from data: Data) throws -> Order {
        let post: PostRead
        do {
            post = try JSONDecoder().decode(PostRead.self, from: data)
        } catch {
            throw OrderClientError.decodingFailed
        }
        return order(from: post)
    }

    static func order(from post: PostRead) -> Order {
        if let payloadData = post.body.data(using: .utf8),
           let payload = try? JSONDecoder().decode(OrderPayload.self, from: payloadData) {
            return Order(
                id: post.id,
                customerId: post.userId,
                summary: post.title,
                lines: payload.lines,
                totalCents: payload.totalCents,
                mode: payload.mode,
                address: payload.address
            )
        }
        return Order(
            id: post.id,
            customerId: post.userId,
            summary: post.title,
            lines: [],
            totalCents: 0,
            mode: "",
            address: "",
            note: post.body
        )
    }
}
