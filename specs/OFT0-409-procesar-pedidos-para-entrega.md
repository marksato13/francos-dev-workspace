# OFT0-409 — HU-A-023 Procesar pedidos para entrega

> **Regla de esta ficha:** separa siempre lo que **verificaste** de lo que
> **supones**. Todo hecho lleva evidencia (`archivo:línea`, commit o salida de
> comando). Un supuesto sin confirmar nunca se escribe como hecho.

## Identificación

| | |
| --- | --- |
| Subtarea backend | `OFT0-409` |
| HU padre | `OFT0-265` — HU-A-023 Procesar pedidos para entrega (RN6, 8 pts, 0 comentarios) |
| Épica | `OFT0-315` — Módulo de Despacho |
| Sprint | Sprint 3 (12/10–16/10, sigue `future` en Jira con las fechas ya pasadas) |
| Rama | `feature/OFT0-409-procesar-pedidos-para-entrega` |
| Commit base de `develop` | `12d547c` (merge PR #48) |
| Fecha de auditoría | 2026-10-18 (auditoría hecha sobre `b91e1c7`; #48 solo toca `strategic`) |

## Criterios de aceptación descompuestos

| # | Criterio | Estado | Evidencia |
| --- | --- | --- | --- |
| CA-1 (RF-A094) | El operador de despacho lista los pedidos en `pendiente_entrega` | parcial | `GET /pedidos?estado=` existe solo para admin/ventas: `src/modules/sales/presentation/controllers/pedidos.controller.ts:38`, `application/dto/pedido-dtos/list-pedidos-query.dto.ts:10-13` |
| CA-2 (RF-A094) | El mismo listado incluye los `en_camino` y `entregado` | parcial | `estado` es de un solo valor: `list-pedidos-query.dto.ts:12-13` |
| CA-3 | El operador de despacho no ve pedidos en otros estados | ausente | — |
| CA-4 (RF-A095) | Ver el detalle de un pedido `pendiente_entrega`, `en_camino` o `entregado`; los demás responden 404 | parcial | `GET /pedidos/:id` sin restricción de estado y solo admin/ventas: `pedidos.controller.ts:99-108` |
| CA-5 (RF-A096) | Transición `pendiente_entrega` → `en_camino` | ausente | Única transición hoy: `confirmado→en_espera_inventario`, `domain/rules/transiciones-pedido.ts:6-10` |
| CA-6 (RF-A096) | Desde otro estado responde 409, y dos peticiones simultáneas no pisan el cambio | ausente (reutilizable) | `cambiarEstado` condicional: `infrastructure/repositories/prisma-pedido.repository.ts:187-199` |
| CA-7 (RF-A097) | Al pasar a `en_camino` se notifica al cliente | ausente | Existen `TipoEventoNotificacion.pedido_en_camino` (`prisma/schema.prisma:65`), `ReferenciaTipo.pedido` (`schema.prisma:43`) y `Notificacion`/`NotificacionUser` (`schema.prisma:294-321`); ningún servicio los usa |
| CA-8 (RF-A098) | Transición `en_camino` → `entregado`, solo desde `en_camino` | parcial | `CompletarPedidoUseCase` existe y está exportado pero ningún endpoint lo llama: `application/use-cases/pedido/completar-pedido.use-case.ts:24-30`, `presentation/sales.module.ts` |
| CA-9 (RF-A098) | Se guarda la fecha de entrega | ausente | `Pedido` no tiene el campo: `schema.prisma` (modelo `Pedido`); `marcarEntregado` solo cambia estado: `prisma-pedido.repository.ts:205-208` |
| CA-10 (RF-A036) | Al entregar se descuenta el stock de `ProductoTerminado` en la misma transacción; sin stock → 409 y nada cambia | cubierto (sin endpoint) | `prisma-pedido.repository.ts:201-240`, `completar-pedido.use-case.spec.ts:40` |
| CA-11 (DoD) | 404 si el pedido no existe, 409 si la transición no vale, 400 si el id no es válido | parcial | Patrón de errores y filtro: `completar-pedido.use-case.ts:20-28`, `presentation/filters/sales-domain-exception.filter.ts` |
| CA-12 (seguridad) | Los endpoints nuevos exigen el rol de despacho o admin; ventas no despacha | ausente | No hay rol de despacho: `prisma/seeds/roles.seed.ts:3-10` |

## Hechos auditados

- **Hecho:** OFT0-409 es Subtask "Desarrollar backend", "Por hacer", asignada a mí; padre OFT0-265 asignada a mí. · *Evidencia:* MCP Jira.
- **Hecho:** No hay ramas ni PR que citen 409, 265, despacho o entrega. · *Evidencia:* `git branch -r`, `gh pr list --state all --search`.
- **Hecho:** `@Roles('admin','ventas')` está a nivel de clase en `PedidosController`, y en `RolesGuard` el `@Roles` del método sustituye al de la clase (`getAllAndOverride`). · *Evidencia:* `pedidos.controller.ts:38`, `src/modules/auth/presentation/guards/roles.guard.ts:35-42`.
- **Hecho:** Roles sembrados: `admin, ventas, cliente, inventario, produccion, estrategico`. · *Evidencia:* `prisma/seeds/roles.seed.ts:3-10`.
- **Hecho:** `CompletarPedidoUseCase` solo acepta `en_camino` y descuenta stock en transacción. · *Evidencia:* `completar-pedido.use-case.ts:24`, `prisma-pedido.repository.ts:201-240`.
- **Hecho:** Nadie lleva hoy un pedido a `en_preparacion` ni `pendiente_entrega`; eso es HU-A-018 (OFT0-260, "Por hacer", sin asignar) y `InventoryModule` está vacío. · *Evidencia:* `src/modules/sales/domain/enums/pedido.enums.ts:10-11`, `src/modules/inventory/presentation/inventory.module.ts:3-6`, Jira.
- **Hecho:** El cliente puede no tener `User` (pedidos manuales): el repositorio lee `persona.user?.email ?? null`. · *Evidencia:* `prisma-pedido.repository.ts:62,70`.
- **Hecho:** No existe servicio de notificaciones; en `src/modules/persons` solo hay DTOs y entidades de notificación. · *Evidencia:* auditoría.

## Supuestos

- **Supuesto:** "Entregar" reutiliza `CompletarPedidoUseCase` (descuento de stock RF-A036), como anuncia el comentario de `sales.module.ts`. · *Confirma:* Roxwell (bersdecker) en la revisión del PR.
- **Supuesto:** La fecha de entrega es la hora del servidor al marcar el pedido, no un dato que escribe el operador. · *Confirma:* PO.
- **Supuesto:** La DoD admite probar con pedidos sembrados en `pendiente_entrega` mientras no exista HU-A-018. · *Confirma:* PO / QA (OFT0-411).
- **Supuesto:** El texto de la notificación ("Tu pedido PED-000123 está en camino") es libre. · *Confirma:* PO.

## Decisiones

Tomadas por Ruben el 2026-10-18:

- **Rol:** se crea el rol `despacho` en el seed; los endpoints aceptan `admin` y `despacho`. Ventas no despacha.
- **API:** controlador nuevo `DespachoPedidosController` en `/despacho/pedidos`, con su propio `@Roles`. No se toca `PedidosController`.
- **Listado:** filtro fijo a `pendiente_entrega`, `en_camino` y `entregado`; `estado` opcional para quedarse con uno solo de esos tres.
- **Notificación (RF-A097):** in-app. Se crea `Notificacion` (`tipo=pedido_en_camino`, `referencia_tipo=pedido`, `referencia_id=<id>`) y su `NotificacionUser` para el usuario del cliente, en la misma transacción que el cambio de estado. Si el cliente no tiene usuario, se omite sin error.
- **Dependencia con HU-A-018:** se arranca ya; los e2e siembran pedidos en `pendiente_entrega` directo en la base.

Tomadas al implementar (2026-10-18):

- **Migración:** `20261018180000_add_fecha_entrega_pedido` (`ALTER TABLE "commerce"."pedido" ADD COLUMN "fecha_entrega" TIMESTAMPTZ(6)`), creada con `prisma migrate dev`.
- **Entidad:** `PedidoEntity.fecha_entrega` va como último parámetro opcional (`= null`) para no tocar los `new PedidoEntity(...)` de las pruebas existentes.
- **Presenter:** `fecha_entrega` se añade al resumen y al detalle de `PedidoPresenter`, que comparte `/pedidos`: es un campo nuevo, no se quita ni renombra nada.
- **Listado:** `ListPedidosParams.estados` (filtro fijo, `estado: { in }` dentro de un `AND`) + `estado` opcional; reutiliza `findMany`, sin consulta nueva.
- **En camino:** `PedidoRepository.marcarEnCamino(id, { titulo, mensaje })` en una `$transaction`: `updateMany` condicional `pendiente_entrega -> en_camino`; si `count = 0` devuelve false (409 en el caso de uso). El texto lo arma el caso de uso: título "Tu pedido está en camino", mensaje "Tu pedido PED-XXXXXX salió a reparto y está en camino.". Si el cliente no tiene usuario no se crea ni `Notificacion` ni `NotificacionUser`.
- **Entregado:** el controlador llama a `CompletarPedidoUseCase` y responde con el detalle vía `GetPedidoDespachoUseCase`. `marcarEntregado` escribe `fecha_entrega: new Date()` en el mismo `updateMany` condicional.
- **409 vs 404:** `en-camino` y `entregado` sobre un pedido existente en otro estado responden 409 (no 404), como piden CA-6 y CA-8; solo el GET de detalle oculta con 404 los pedidos fuera de despacho.
- **Ubicación:** los casos de uso nuevos van en `application/use-cases/pedido/` junto a los existentes (el módulo agrupa por agregado, no por actor).
- **Documentación:** no hubo herramienta Context7 en la sesión; no se consultó documentación externa y se siguió el código del repo. Versiones instaladas: `@nestjs/core 11.1.28`, `@prisma/client` y `prisma 7.8.0`, `jest 30.4.2`, `class-validator 0.15.1`.

Pendientes que no bloquean:

- **Decisión:** si el menú del Portal A necesita una ruta "despacho" en `rutas.seed.ts` y su acceso para el rol. · *Decide:* frontend OFT0-410 / PO · *Bloquea:* no.

## Alcance

CA-1 a CA-9, CA-11 y CA-12. CA-10 ya existe y solo se conecta al endpoint.

## Fuera de alcance

- Las transiciones `en_espera_inventario → en_preparacion → pendiente_entrega` (HU-A-018, OFT0-260).
- Notificación por correo o SNS y el listado de notificaciones del cliente (HU-B-011, OFT0-299).
- Ruta de menú y accesos del rol `despacho` en `rutas.seed.ts` / `accesos.seed.ts`.
- Cancelar un pedido, reprogramar entrega o asignar repartidor.
- La pantalla de despacho (OFT0-410).

## Plan técnico

| Capa | Archivos |
| --- | --- |
| `domain` | `rules/transiciones-pedido.ts`: transición de despacho `pendiente_entrega→en_camino`. `repositories/pedido.repository.ts`: `despacharConNotificacion` (o equivalente) y `marcarEntregado` devolviendo `fecha_entrega`. |
| `application` | DTO `list-pedidos-despacho-query.dto.ts`. Casos de uso `list-pedidos-despacho`, `get-pedido-despacho`, `despachar-pedido` (en camino + notificación). `CompletarPedidoUseCase` se reutiliza. |
| `infrastructure` | `prisma-pedido.repository.ts`: listado con `estado in (...)`, `updateMany` condicional + `Notificacion` en `$transaction`, `fecha_entrega = now()` dentro de `marcarEntregado`. Mapper con `fecha_entrega`. |
| `presentation` | `controllers/despacho-pedidos.controller.ts` (`@Roles('admin','despacho')`), presenter con `fecha_entrega`, registro en `sales.module.ts`. |
| `prisma` | `schema.prisma`: `Pedido.fecha_entrega DateTime? @db.Timestamptz(6)`. `seeds/roles.seed.ts`: `despacho`. |

## Autorización de endpoints

| Endpoint | Método | Roles requeridos |
| --- | --- | --- |
| `/api/v1/despacho/pedidos` | GET | admin, despacho |
| `/api/v1/despacho/pedidos/:id` | GET | admin, despacho |
| `/api/v1/despacho/pedidos/:id/en-camino` | PATCH | admin, despacho |
| `/api/v1/despacho/pedidos/:id/entregado` | PATCH | admin, despacho |

`@Roles('admin', 'despacho')` a nivel de clase en `DespachoPedidosController`; ningún método lo sobrescribe.

## Migraciones

- `20261024010000_add_fecha_entrega_pedido`: añade `commerce.pedido.fecha_entrega timestamptz NULL`. Posterior a `20261023210000_datos_ubigeo` (última de develop el 2026-10-24).
- `20261024020000_rol_despacho`: `INSERT INTO persons.rol ... ('despacho') ON CONFLICT DO NOTHING`. Dato de referencia como migración, según el aviso del equipo (AWS solo ejecuta `migrate deploy`, no el seed).

## Dependencias con el frontend

Contrato nuevo, sin consumidores todavía. Avisar a quien haga OFT0-410 (pantalla de despacho) de las rutas `/despacho/pedidos` y del campo `fecha_entrega`. Los campos van en español, como el resto de `/pedidos`.

## Plan de pruebas

| Prueba | Tipo | Estado |
| --- | --- | --- |
| Transiciones de despacho válidas e inválidas (`domain/rules/transiciones-pedido.spec.ts`) | unitaria | hecha, pasa |
| Despachar: 404, 409 por estado y por carrera, texto de la notificación (`despachar-pedido.use-case.spec.ts`) | unitaria | hecha, pasa |
| Listado y detalle de despacho (`consultas-despacho.use-case.spec.ts`) | unitaria | hecha, pasa |
| Listado filtra solo los 3 estados y respeta `estado`; otro estado → 400 | e2e | hecha, pasa |
| Detalle de pedido fuera de despacho → 404; id no numérico → 400 | e2e | hecha, pasa |
| `en-camino` crea `Notificacion` + `NotificacionUser`; sin usuario se omite; repetido → 409 sin duplicar | e2e | hecha, pasa |
| `entregado` guarda `fecha_entrega` y descuenta stock; desde `pendiente_entrega` o repetido → 409; sin stock → 409 y nada cambia | e2e | hecha, pasa |
| ventas, cliente → 403; sin token → 401; admin → 200 | e2e | hecha, pasa |

La omisión de la notificación sin usuario vive en el repositorio, así que se prueba en el e2e, no en la unitaria.

## Verificación

Ejecutado por el agente de implementación el 2026-10-18:

- [x] `pnpm build`: sin errores
- [x] `pnpm lint:check`: 0 problemas
- [x] `prettier --check` sobre los archivos tocados: todos pasan
- [x] `pnpm test`: 83 suites, 517 pruebas, todas pasan
- [x] `pnpm test:e2e --ci --runInBand`: 14 suites, 270 pruebas, todas pasan (`despacho-pedidos.e2e-spec.ts`: 25)
- [ ] `docker build` + smoke
- [x] `pnpm exec prisma migrate status`: "Database schema is up to date!"
- [x] `git diff --check`: limpio
- [x] Sin `.env`, secretos, `dist/`, caches ni logs en el diff

No ejecutado y por qué: `pnpm format:check` global (falla por CRLF preexistente, ajeno a esta incidencia; se usó `prettier --check` sobre los archivos tocados) y `docker build` + smoke (le toca a `/task-verify`).

## Riesgos

- Se toca el repositorio de ventas (`marcarEntregado`) entregado en el PR #43; avisar a Roxwell en el PR.
- El flujo real no se puede recorrer hasta que exista HU-A-018.
- El rol `despacho` no tiene ruta de menú ni usuarios todavía; solo admin lo verá en el Portal A hasta que se siembre.

## Entrega

| | |
| --- | --- |
| PR | [#49](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/49), commit `9669133` |
| Estado del CI | Verde en las 6 puertas, run 39144774363. Docker + smoke en local: `/api/docs` 200 y los 4 endpoints de despacho cargan |
| Jira | En revisión (transición 31) + comentario |

Nota: la verificación detectó que gitleaks marcaba `DespachoE2e123` (`generic-api-key`, entropía 3.52) en `test/despacho-pedidos.e2e-spec.ts:16`; se cambió a `VentasE2e123` antes del commit.

## Actualización 2026-10-18

Tras el merge de #50 (reembolsos) en develop: merge `858e968`, conflicto en `sales.module.ts` resuelto conservando despacho y reembolsos. La migración se renombró a `20261018180000_add_fecha_entrega_pedido` para quedar después de `20261018161423_add_reembolso`. Verificado: 560/560 unitarias, e2e en BD limpia 307/307, sin deriva; CI 6/6.

## Actualización 2026-10-24 — rol `despacho` como migración

- **Motivo:** aviso del equipo (Piero Lanche, PR #57 `20261019000000_datos_referencia`): en AWS la base nace vacía y la imagen solo corre `prisma migrate deploy`; todo dato de referencia nuevo va como migración SQL en el mismo PR. El rol `despacho` estaba solo en `roles.seed.ts` y la migración del #57 no lo incluye. · *Evidencia:* `git grep despacho origin/develop -- prisma/migrations` vacío.
- **Cambio:** commit `2f6e2d5` (migración `20261024020000_rol_despacho` + renombre de `fecha_entrega` a `20261024010000`) y merge de develop `84ea9cb` (develop en `33a5559`, PR #70), sin conflictos.
- **Verificado en local** (Postgres 16 desechable): build, `lint:check`, prettier del diff, 931/931 unitarias; `migrate deploy` sin seed deja `admin ventas cliente inventario produccion estrategico despacho`; seed ok; sin deriva; e2e 567/567 con `--runInBand --testTimeout=60000`.
- **No igual al CI:** con el timeout por defecto (5 s) fallan `beforeAll` en suites ajenas porque esta máquina arranca `AppModule` lento (comprobado: `kpi.e2e-spec.ts` pasa 21/21 con 60 s). El CI de develop está verde con su configuración normal.
- **Revisión:** agente `backend-reviewer`, veredicto "listo para push".
- **Entrega:** push `a541487..84ea9cb`; CI del PR #49 6/6 en verde (run 40166157358, test-e2e con la configuración normal). Descripción del PR actualizada con las dos migraciones. Jira: comentario 10106.
