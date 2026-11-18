# Prueba de pedidos con JSONPlaceholder

JSONPlaceholder no expone un recurso `/orders`. El flujo de pedido usa **`/posts`**, que es el recurso que aguanta un carrito:

| Pedido Fresh Harvest | Campo de `POST /posts` |
|---|---|
| `customerId` | `userId` |
| resumen (`Green Bowl Deli · 3 artículos`) | `title` |
| líneas, total en céntimos, modo (`delivery` / `pickup`) y dirección, en JSON | `body` |
| id que asigna el servidor | `id` |

`/todos` se descartó: solo tiene `title` y `completed`, y no cabe el importe ni las líneas.

El cliente está en `FreshHarvestOrders/` (`OrderClient`). La URL base por defecto es `https://jsonplaceholder.typicode.com`. Se puede cambiar en el inicializador o con la variable `ORDER_API_BASE_URL`.

JSONPlaceholder **no guarda** lo que se crea. `POST /posts` responde **201** y devuelve el pedido con `id` (hoy, 101). `GET /posts/101` responde **404** con `{}`. `GET /posts/1` sí devuelve un post guardado, con la misma forma (`userId`, `id`, `title`, `body`). La prueba comprueba las dos respuestas.

## Ejecutar la prueba

Hace falta Swift 5.9 o posterior (en Linux, el módulo de red entra por `FoundationNetworking`; el paquete ya lo importa).

```bash
swift test --package-path FreshHarvestOrders
```

## Probarlo a mano

```bash
swift run --package-path FreshHarvestOrders place-order
```

El script hace el POST del pedido de ejemplo (dos Salmon Avocado Poke y un Super Green Kale Bowl, de Green Bowl Deli) y después el GET. Opcional: `--base-url https://jsonplaceholder.typicode.com`.

El target de la app iOS no cambia: el paquete no entra en `FreshHarvest.xcodeproj`, así que el archivo IPA sigue compilando igual.
