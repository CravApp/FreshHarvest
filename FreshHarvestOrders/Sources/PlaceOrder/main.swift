//
//  main.swift
//  place-order
//
//  Manual check of the order flow against JSONPlaceholder:
//  POST /posts, then GET /posts/:id.
//
//      swift run --package-path FreshHarvestOrders place-order
//      swift run --package-path FreshHarvestOrders place-order --base-url https://jsonplaceholder.typicode.com
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import FreshHarvestOrders

@main
enum PlaceOrder {
    static func main() async {
        let code = await run()
        exit(code)
    }

    static func run() async -> Int32 {
        do {
            let baseURL = try parseBaseURL()
            let client = OrderClient(baseURL: baseURL)
            let draft = OrderDraft.greenBowlSample

            print("API de pedidos: \(client.baseURL.absoluteString)")
            print("Recurso: /posts (JSONPlaceholder no tiene /orders)")
            print("Pedido: \(draft.summary) · \(draft.formattedTotal)")
            print("")

            let created = try await client.createOrder(draft)
            print("POST /posts")
            describe(created)
            print("")

            print("GET /posts/\(created.order.id)")
            do {
                let fetched = try await client.fetchOrder(id: created.order.id)
                describe(fetched)
                guard fetched.order.lines == draft.lines else {
                    fputs("El pedido consultado no coincide con el que se creó.\n", stderr)
                    return 1
                }
            } catch OrderClientError.notFound(let id) {
                print("  HTTP 404 — JSONPlaceholder no persiste el POST (pedido \(id)).")
                print("  El alta solo vive en la respuesta 201. Se consulta un post guardado para comprobar el GET.")
                print("")
                print("GET /posts/1")
                let stored = try await client.fetchOrder(id: 1)
                describe(stored)
            }

            return 0
        } catch {
            fputs("Error: \(error)\n", stderr)
            return 1
        }
    }

    static func parseBaseURL() throws -> URL {
        var arguments = Array(CommandLine.arguments.dropFirst())
        var raw: String?
        while let argument = arguments.first {
            arguments.removeFirst()
            switch argument {
            case "--help", "-h":
                print("""
                Uso: place-order [--base-url URL]

                Crea un pedido de ejemplo (Green Bowl Deli) con POST /posts y lo consulta con GET.
                Por defecto la URL base es https://jsonplaceholder.typicode.com
                También se puede fijar con la variable de entorno ORDER_API_BASE_URL.
                """)
                exit(0)
            case "--base-url":
                guard let value = arguments.first else {
                    throw OrderClientError.invalidBaseURL
                }
                arguments.removeFirst()
                raw = value
            default:
                fputs("Opción desconocida: \(argument)\n", stderr)
                throw OrderClientError.invalidBaseURL
            }
        }
        if let raw {
            guard let url = URL(string: raw) else { throw OrderClientError.invalidBaseURL }
            return url
        }
        if let env = ProcessInfo.processInfo.environment["ORDER_API_BASE_URL"], !env.isEmpty {
            guard let url = URL(string: env) else { throw OrderClientError.invalidBaseURL }
            return url
        }
        return OrderClient.jsonPlaceholderBaseURL
    }

    static func describe(_ exchange: OrderExchange) {
        let order = exchange.order
        print("  HTTP \(exchange.statusCode)")
        print("  id: \(order.id)")
        print("  cliente (userId): \(order.customerId)")
        print("  resumen (title): \(order.summary)")
        print("  total: \(order.formattedTotal)")
        print("  modo: \(order.mode.isEmpty ? "—" : order.mode)")
        print("  dirección: \(order.address.isEmpty ? "—" : order.address)")
        if order.lines.isEmpty {
            print("  líneas: ninguna (el body de este post no es un pedido)")
            let preview = order.note.replacingOccurrences(of: "\n", with: " ")
            if !preview.isEmpty {
                print("  nota: \(preview.prefix(90))")
            }
        } else {
            for line in order.lines {
                let price = EuroCents.string(cents: line.subtotalCents)
                print("  - \(line.quantity)× \(line.name) · \(price)")
            }
        }
    }
}

/// Local price line so the executable does not need the formatter to be public.
private enum EuroCents {
    static func string(cents: Int) -> String {
        String(format: "%d,%02d €", cents / 100, abs(cents % 100))
    }
}
