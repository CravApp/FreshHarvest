//
//  OrderFlowTests.swift
//  FreshHarvestOrdersTests
//
//  Maps a cart onto JSONPlaceholder `/posts`, creates it (POST) and reads it
//  back (GET). JSONPlaceholder does not store writes, so GET of the new id is
//  404; the test still checks that response and the GET of a stored post.
//

import XCTest
@testable import FreshHarvestOrders

final class OrderFlowTests: XCTestCase {

    private var client: OrderClient!

    override func setUp() {
        super.setUp()
        client = OrderClient(baseURL: OrderClient.jsonPlaceholderBaseURL)
    }

    func testBaseURLIsConfigurable() {
        let url = URL(string: "https://jsonplaceholder.typicode.com")!
        let configured = OrderClient(baseURL: url)
        XCTAssertEqual(configured.baseURL, url)
        XCTAssertEqual(OrderClient().baseURL, OrderClient.jsonPlaceholderBaseURL)
    }

    func testOrderMapsOntoPostFields() throws {
        let draft = OrderDraft.greenBowlSample
        XCTAssertEqual(draft.itemCount, 3)
        XCTAssertEqual(draft.totalCents, 3630)
        XCTAssertEqual(draft.formattedTotal, "36,30 €")
        XCTAssertEqual(draft.summary, "Green Bowl Deli · 3 artículos")

        let post = try OrderPostMapping.encodePost(from: draft)
        XCTAssertEqual(post.userId, draft.customerId)
        XCTAssertEqual(post.title, draft.summary)

        let payload = try JSONDecoder().decode(OrderPayload.self, from: Data(post.body.utf8))
        XCTAssertEqual(payload.lines, draft.lines)
        XCTAssertEqual(payload.totalCents, 3630)
        XCTAssertEqual(payload.mode, "delivery")
        XCTAssertEqual(payload.address, "Calle Gran Vía, 42")

        let echoed = PostRead(userId: post.userId, id: 101, title: post.title, body: post.body)
        let order = OrderPostMapping.order(from: echoed)
        XCTAssertEqual(order.id, 101)
        XCTAssertEqual(order.customerId, draft.customerId)
        XCTAssertEqual(order.summary, draft.summary)
        XCTAssertEqual(order.lines, draft.lines)
        XCTAssertEqual(order.totalCents, draft.totalCents)
        XCTAssertEqual(order.mode, draft.mode)
        XCTAssertEqual(order.address, draft.address)
        XCTAssertEqual(order.note, "")
    }

    func testSingleItemSummaryIsSingular() {
        let draft = OrderDraft(
            customerId: 2,
            restaurantName: "Nipon Sushi Bar",
            lines: [
                OrderLine(
                    dishId: "combo-tokyo",
                    name: "Combo Tokyo (16 piezas)",
                    quantity: 1,
                    unitPriceCents: 1890,
                    restaurantName: "Nipon Sushi Bar"
                ),
            ],
            mode: "pickup",
            address: "Calle Gran Vía, 42"
        )
        XCTAssertEqual(draft.summary, "Nipon Sushi Bar · 1 artículo")
        XCTAssertEqual(draft.formattedTotal, "18,90 €")
    }

    func testSeedPostWithoutOrderJSONBecomesNote() {
        let post = PostRead(
            userId: 1,
            id: 1,
            title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
            body: "quia et suscipit\nsuscipit recusandae"
        )
        let order = OrderPostMapping.order(from: post)
        XCTAssertEqual(order.id, 1)
        XCTAssertEqual(order.customerId, 1)
        XCTAssertTrue(order.lines.isEmpty)
        XCTAssertEqual(order.totalCents, 0)
        XCTAssertEqual(order.note, post.body)
    }

    func testRejectsAnEmptyOrderWithoutCallingTheNetwork() async {
        let draft = OrderDraft(
            customerId: 1,
            restaurantName: "Green Bowl Deli",
            lines: [],
            mode: "delivery",
            address: "Calle Gran Vía, 42"
        )
        do {
            _ = try await client.createOrder(draft)
            XCTFail("Se esperaba un pedido vacío")
        } catch OrderClientError.emptyOrder {
            // El cliente rechaza el borrador antes de abrir la conexión.
        } catch {
            XCTFail("Error inesperado: \(error)")
        }
    }

    /// POST /posts crea el pedido y GET lo consulta.
    /// JSONPlaceholder responde 201 con el recurso falsificado y 404 al leer
    /// ese id; el GET de un post real (`/posts/1`) cubre la lectura persistida.
    func testCreateOrderAndConsultItOnJSONPlaceholder() async throws {
        let draft = OrderDraft.greenBowlSample
        let created = try await client.createOrder(draft)

        XCTAssertEqual(created.statusCode, 201)
        XCTAssertGreaterThan(created.order.id, 0)
        XCTAssertEqual(created.order.customerId, draft.customerId)
        XCTAssertEqual(created.order.summary, draft.summary)
        XCTAssertEqual(created.order.lines, draft.lines)
        XCTAssertEqual(created.order.totalCents, draft.totalCents)
        XCTAssertEqual(created.order.mode, draft.mode)
        XCTAssertEqual(created.order.address, draft.address)

        do {
            let fetched = try await client.fetchOrder(id: created.order.id)
            XCTAssertEqual(fetched.statusCode, 200)
            XCTAssertEqual(fetched.order.id, created.order.id)
            XCTAssertEqual(fetched.order.customerId, draft.customerId)
            XCTAssertEqual(fetched.order.lines, draft.lines)
            XCTAssertEqual(fetched.order.totalCents, draft.totalCents)
            XCTAssertEqual(fetched.order.address, draft.address)
        } catch OrderClientError.notFound(let id) {
            XCTAssertEqual(id, created.order.id)
            let stored = try await client.fetchOrder(id: 1)
            XCTAssertEqual(stored.statusCode, 200)
            XCTAssertEqual(stored.order.id, 1)
            XCTAssertEqual(stored.order.customerId, 1)
            XCTAssertEqual(
                stored.order.summary,
                "sunt aut facere repellat provident occaecati excepturi optio reprehenderit"
            )
            XCTAssertTrue(stored.order.note.contains("quia et suscipit"))
            XCTAssertTrue(stored.order.lines.isEmpty)
        }
    }
}
