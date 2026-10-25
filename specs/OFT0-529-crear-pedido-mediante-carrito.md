# OFT0-529 — HU-B-007 Crear pedido mediante carrito

> **Regla de esta ficha:** separa siempre lo que **verificaste** de lo que
> **supones**. Todo hecho lleva evidencia (`archivo:línea`, commit o salida de
> comando). Un supuesto sin confirmar nunca se escribe como hecho.

## Identificación

| | |
| --- | --- |
| Subtarea backend | `OFT0-529` |
| HU padre | `OFT0-295` — HU-B-007 Crear pedido mediante carrito |
| Épica | `OFT0-318` — Módulo de Compras del Cliente |
| Sprint | Sprint 2 |
| Rama | `feature/OFT0-529-crear-pedido-mediante-carrito` |
| Commit base de `develop` | `e3934c6` (merge #51, OFT0-505 login cliente) |
| Fecha de auditoría | 2026-10-18 |

## Texto de la HU (Jira, leído el 2026-10-18)

> Como cliente, quiero confirmar el carrito corroborando la dirección de entrega
> predeterminada, pudiendo cancelar esa confirmación si deseo cambiarla, y que el
> sistema calcule automáticamente el subtotal y el total de mi pedido aplicando
> automáticamente el precio mayorista cuando la cantidad de un producto supere el
> umbral configurado, para generar mi pedido con el monto correcto antes de
> proceder al pago.

Regla de negocio: **RN17**. Enlaces: bloqueada por OFT0-290, OFT0-293, OFT0-251;
bloquea a OFT0-296 (HU-B-008 Realizar pago en línea) y OFT0-299.

## Criterios de aceptación descompuestos

| # | Criterio | Origen | Estado en `develop` | Evidencia |
| --- | --- | --- | --- | --- |
| CA-1 | Solo un usuario con rol `cliente` puede confirmar su carrito; el cliente sale del JWT, nunca del body | RF-B20 | ausente | `POST /pedidos` es `@Roles('admin','ventas')` y recibe `cliente_id` en el body: `src/modules/sales/presentation/controllers/pedidos.controller.ts:38`, `create-pedido.use-case.ts:31-33` |
| CA-2 | La respuesta trae la dirección predeterminada del perfil (`Persona.direccion`) | RF-B20 | ausente | `prisma/schema.prisma:162` |
| CA-3 | Si el body trae `direccion_entrega`, se usa esa solo para este pedido; el perfil no cambia | RF-B21 | ausente | decisión 2026-10-18 |
| CA-4 | Delivery sin dirección (ni en body ni en perfil) → 400 | RF-B20/21 | ausente | — |
| CA-5 | Recojo en tienda → `direccion_entrega` null | RF-B20 | cubierto en manual | `create-pedido.use-case.ts:54-57` |
| CA-6 | Subtotal por línea y total calculados en el servidor (sin costo de delivery) | RF-B22 | cubierto para manual | `src/modules/sales/application/utils/pedido.utils.ts` `calcularLinea`, `calcularTotal` |
| CA-7 | Precio mayorista cuando cantidad > umbral de la presentación | RF-B23 / RN17 | cubierto para manual | `pedido.utils.ts` `precioAplicado` |
| CA-8 | Cada línea indica si se aplicó mayorista | RF-B23 | ausente | — |
| CA-9 | Presentación inexistente → 404; inactiva, producto inactivo o no `visible_portal_b` → 409 | DoD backend | parcial (sin `visible_portal_b`) | `prisma/schema.prisma:419`, `prisma-pedido.repository.ts:79-93` |
| CA-10 | Usuario cliente sin registro `Cliente` → 404; cliente inactivo → 409 | DoD backend | parcial | `create-pedido.use-case.ts:35-43` |
| CA-11 | No se guarda nada en BD ni se cobra (RN5 intacta) | decisión | — | `prisma/schema.prisma:104-106` |
| CA-12 | Body inválido (items vacíos, cantidad < 1, ids duplicados) → 400 | DoD backend | — | — |

## Hechos auditados

- **Hecho:** el carrito vive solo en el front Next (localStorage `francos-carrito`); el backend no tiene modelo Carrito. · *Evidencia:* auditoría previa, `grep -n "model Carrito" prisma/schema.prisma` sin resultados.
- **Hecho:** `Presentacion`/`ProductoPresentacion` ya tienen `precio_mayorista` y `umbral_mayorista`. · *Evidencia:* `prisma/schema.prisma:409-411`.
- **Hecho:** RN17 ya está implementada y probada en `pedido.utils.ts` (reutilizable). · *Evidencia:* `git show origin/develop:src/modules/sales/application/utils/pedido.utils.ts`.
- **Hecho:** el pedido nace `confirmado` y solo con pago confirmado (RN5). · *Evidencia:* `prisma/schema.prisma:104-106`.
- **Hecho:** el login de cliente ya está en develop (#51, OFT0-505) y el rol `cliente` existe en el seed. · *Evidencia:* `e3934c6`, `prisma/seeds/roles.seed.ts:6`.
- **Hecho:** User → Persona → Cliente (relaciones 1:1 por `persona_id`). · *Evidencia:* `prisma/schema.prisma:192, 208`.
- **Hecho:** la creación del pago en línea es otra HU (OFT0-296), bloqueada por esta. · *Evidencia:* enlaces de OFT0-295.

## Decisiones tomadas (usuario, 2026-10-18)

1. **Solo calcular.** `POST /portal/pedidos/resumen` recalcula y devuelve el resumen; no persiste. El pedido real se crea en OFT0-296 junto con el pago. Sin migración.
2. **Dirección:** opcional en el body, solo para este pedido; si no viene, la del perfil.
3. **Alcance de precio:** solo mayorista (RN17). Se valida activo + `visible_portal_b`. Promociones y stock fuera.

## Decisiones de implementación (2026-10-18)

- Ruta real: `POST /api/v1/portal/pedidos/resumen` (prefijo global `api/v1`, `src/app.setup.ts:6`). `@HttpCode(200)`: no crea recurso.
- `@Roles('cliente')` a nivel de controlador (`PortalPedidosController`). Sin `@UseGuards` (guards globales).
- El cliente se resuelve con `findClienteParaResumenPorUser(userId)` (User -> Persona -> Cliente) usando `user.userId` del JWT. Como el `ValidationPipe` global tiene `forbidNonWhitelisted` (`src/app.setup.ts:9-11`), un `cliente_id` en el body responde 400 (cubierto en e2e).
- `visible_portal_b` se añadió a `PresentacionParaPedido` y al select de `findPresentacionesParaPedido` (aditivo). `CreatePedidoUseCase` no lo lee: el pedido manual no cambia. Consecuencia: los fixtures tipados de `create-pedido.use-case.spec.ts` y `pedido.utils.spec.ts` necesitaron `visible_portal_b: true` (una línea cada uno) para compilar con ts-jest.
- `es_mayorista` se calcula con la misma condición que `precioAplicado` (`precio_mayorista` y `umbral_mayorista` no nulos y `cantidad > umbral`).
- Dirección en delivery: `body.direccion_entrega` (ya recortada por el DTO) o, si no viene, `Persona.direccion` recortada; si queda vacía -> 400 `InvalidRequestError`. `direccion_perfil` devuelve el valor del perfil tal cual.
- Una presentación inactiva, con producto inactivo o no visible responde 409 con un mismo mensaje ("no está disponible en el catálogo").
- `subtotal` y `total` del resumen son iguales (sin costo de delivery).
- Context7 no estaba disponible para el agente en esta sesión: no se consultó documentación externa. Solo se reutilizaron APIs ya usadas en el módulo (NestJS 11 `@HttpCode`, class-validator `@ArrayUnique`/`@IsOptional`, Prisma 7 `findFirst` con filtro de relación).

## Supuestos

- **Supuesto:** "cancelar la confirmación" (RF-B21) es un paso de UI: el front vuelve a llamar al resumen con otra dirección. · *Confirma:* PO / dueño de OFT0-530.
- **Supuesto:** el precio que verá el cliente en OFT0-296 será el mismo cálculo (se reutilizará este caso de uso). · *Confirma:* dueño de OFT0-296.

## Decisiones pendientes

- **Decisión:** ¿promociones (`precio_final` de #46) se combinan con el mayorista? · *Decide:* PO · *Bloquea:* no (fuera de alcance).
- **Decisión:** validación de stock al confirmar (OFT0-294, sin asignar). · *Decide:* PO · *Bloquea:* no.

## Alcance

CA-1 a CA-12.

## Fuera de alcance

- Persistir el carrito o el pedido; cobrar (OFT0-296).
- Promociones y stock.
- Editar la dirección del perfil.
- Cambios en `POST /pedidos` (manual) más allá de reutilizar utilidades.

## Plan técnico

| Capa | Archivos |
| --- | --- |
| `domain` | `pedido-repository.types.ts`: `ClienteParaResumen` (id, estado, direccion); `visible_portal_b` en `PresentacionParaPedido`. `pedido.repository.ts`: `findClienteParaResumenPorUser(userId)` |
| `application` | `dto/pedido-dtos/resumen-pedido-portal.dto.ts`; `use-cases/pedido/resumir-pedido-portal.use-case.ts` + spec |
| `infrastructure` | `prisma-pedido.repository.ts`: nueva consulta y `visible_portal_b` en el select |
| `presentation` | `controllers/portal-pedidos.controller.ts`; registro en `sales.module.ts`; presenter |

## Autorización de endpoints

| Endpoint | Método | Roles requeridos |
| --- | --- | --- |
| `/api/v1/portal/pedidos/resumen` | POST | `cliente` |

## Migraciones

Ninguna.

## Dependencias con el frontend

Endpoint nuevo para `frontend-next-francos` (OFT0-530). Avisar al dueño del front y
al de OFT0-296.

## Plan de pruebas

| Prueba | Tipo | Estado |
| --- | --- | --- |
| Caso de uso: mayorista, dirección perfil/override, recojo, errores | unitaria | hecha: `resumir-pedido-portal.use-case.spec.ts`, 14 tests en verde |
| Endpoint: 401/403 por rol, 200 con cálculo, 400/404/409 | e2e | hecha: `test/portal-pedidos.e2e-spec.ts`, 20 tests en verde |

## Verificación

- [x] `pnpm build` (exit 0)
- [x] `pnpm lint:check` (exit 0, sin warnings)
- [ ] `pnpm format:check` global: no se corrió; se corrió `pnpm exec prettier --check` sobre los 12 archivos tocados: "All matched files use Prettier code style!"
- [x] `pnpm test`: 84 suites, 536 tests en verde
- [x] `pnpm test:e2e --ci --runInBand`: 16 suites, 293 tests en verde
- [x] `docker build` + smoke
- [x] `pnpm exec prisma migrate status`: 28 migraciones, "Database schema is up to date!"
- [x] `git diff --check` (exit 0)
- [x] Sin `.env`, secretos, `dist/`, caches ni logs en el diff (git status solo muestra archivos de `src/modules/sales` y `test/portal-pedidos.e2e-spec.ts`)

No ejecutado y por qué: `format:check` global falla en local por CRLF del worktree (`core.autocrlf=true`); se corrió `prettier --check` sobre los 12 archivos del diff y pasó.

## Riesgos

- Conflictos en `prisma-pedido.repository.ts` / `sales.module.ts` con #40 y #49.
- Si OFT0-296 no reutiliza este cálculo, el cliente podría ver un total y pagar otro.

## Entrega

| | |
| --- | --- |
| PR | [#53](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/53) · commit `0bd14cc` |
| Estado del CI | 6/6 verde (build, lint, test-unit, test-e2e, docker, security) |
| Jira | comentado (10098 inicio, 10099 PR) · transicionado a En revisión |

## Actualización 2026-10-18 y 2026-10-24 — develop al día

- 2026-10-18: merge de develop `4a57d99` tras #40 y #54; verificado 660 unitarias, 407 e2e; CI 6/6.
- 2026-10-24: merge de develop `890e160` (develop en `33a5559`, PRs #57 a #70), sin conflictos. No trae datos de referencia ni migraciones, así que el aviso de "datos de referencia como migración" no le aplica.
- **Verificado en local** (Postgres 16 desechable): build, `lint:check`, prettier del diff, 921/921 unitarias, `migrate deploy` + seed sin deriva, e2e 562/562 con `--runInBand --testTimeout=60000` (en esta máquina `AppModule` arranca en más de 5 s; el CI usa el timeout normal).
- **Revisión `backend-reviewer`:** listo para push. Develop solo añadió en sales un filtro `cliente_id` al listado; `findPresentacionesParaPedido` y `findClienteParaResumenPorUser` siguen válidos; `Persona.direccion` no cambió (develop añadió `distrito_id` y `Cliente.codigo`).
- **Observación no bloqueante:** el resumen devuelve la dirección en texto libre, sin `distrito_id`. Si producto quiere el distrito en la dirección de entrega, es otra incidencia. · *Decide:* PO.
- **Entrega:** push `4a57d99..890e160`; CI del PR #53 6/6 en verde (run 40166801163).
- 2026-10-25: tras el merge del #49 en develop (`868c900`, hasta #74), conflicto en `sales.module.ts` (providers: `ResumirPedidoPortalUseCase` frente a los tres de despacho), resuelto conservando ambos. Merge `68a20bc`. Local: 1060/1060 unitarias, e2e 646/646 (`--testTimeout=60000`). CI 6/6. Push `890e160..68a20bc`.
