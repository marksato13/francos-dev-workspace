# OFT0-345 — HU-A-007 Gestionar producto

> **Regla de esta ficha:** separa siempre lo que **verificaste** de lo que
> **supones**. Todo hecho lleva evidencia. Un supuesto sin confirmar nunca se
> escribe como hecho.

## Identificación

| | |
| --- | --- |
| Subtarea backend | `OFT0-345` — *Desarrollar backend* |
| HU padre | `OFT0-249` — HU-A-007 Gestionar producto (**En curso**) |
| Épica | `OFT0-310` — Módulo de Gestión de Ventas — Catálogo de Productos |
| Sprint | Sprint 1 (activo, vencido el 2026-09-25) |
| Rama | *sin crear* — se creará `feature/OFT0-345-gestionar-producto` desde `develop` en `b0c8656` |
| Clave anterior (muerta) | `OFT0-55` → devuelve 404 |
| Fecha de auditoría | 2026-09-28 |
| Estado de la ficha | **auditoría parcial** — ver decisiones pendientes |

## Criterios de aceptación descompuestos

La HU trae todo el alcance en **un único párrafo**. Descompuesto en 11 criterios
verificables:

| # | Criterio | Estado | Evidencia |
| --- | --- | --- | --- |
| CA-1 | Registrar producto con nombre, categoría y descripción | **cubierto** | `catalog/application/use-cases/producto/create-producto.use-case.ts` |
| CA-2 | Registrar 1..N presentaciones con imagen, precio unitario, precio mayorista y umbral mayorista | **no verificado** | existe `create-producto-with-presentaciones.dto.ts`; falta comprobar los 4 campos |
| CA-3 | SKU autogenerado con formato `FR-P{productoID}-PR{presentacionID}` | **cubierto** | `catalog/application/utils/producto-presentacion.utils.ts:8` devuelve `` `FR-P${productoId}-PR${presentacionId}` `` |
| CA-4 | Por cada presentación se crea un producto terminado (cantidad 0, stock actual 0, stock mínimo 1, unidad preseleccionada) | **no verificado** | requiere revisar el módulo `inventory`, no solo `catalog` |
| CA-5 | El producto nace oculto del Portal B (`Visible en el Portal B` desactivado) | **ausente** | `prisma/schema.prisma` **no tiene ningún campo** `visible` ni `portal` |
| CA-6 | Editar producto y presentaciones **sin** poder modificar SKU ni slug | **no verificado** | `sku` y `slug` existen con `@unique` en `model ProductoPresentacion`; falta comprobar que el update los rechaza |
| CA-7 | Mensajes de error descriptivos ante campos incompletos o datos inválidos | **no verificado** | existe `domain/errors/catalog-domain.errors.ts` y `presentation/filters/catalog-domain-exception.filter.ts` |
| CA-8 | Marcar uno o varios productos como destacados | **parcial** | `model Producto` tiene `destacado Boolean @default(false)`; falta el endpoint y el caso de uso |
| CA-9 | Promoción opcional por presentación con % de descuento y vigencia, aplicada automáticamente al precio | **ausente** | ver hallazgo crítico abajo |
| CA-10 | Listado paginado con nombre, categoría, presentación, precio unitario y estado | **no verificado** | existe `list-producto.use-case.ts` y `list-producto-query.dto.ts` |
| CA-11 | Búsqueda por nombre y filtro por categoría, presentación, estado y disponibilidad | **no verificado** | existe `list-producto-query.dto.ts`; falta comprobar los 5 filtros |

## Hechos auditados

- **La clave `OFT0-55` está muerta.** `getJiraIssue OFT0-55` → 404 *"La incidencia
  no existe o no tienes permiso para verla"*. La incidencia equivalente hoy es la
  HU `OFT0-249` con subtarea `OFT0-345`.
  *Evidencia:* respuesta del MCP Jira, 2026-09-28.

- **El PR #6 se cerró sin fusionar.** `gh pr list --state all` →
  `6  OFT0-55: Gestionar producto  feature/OFT0-55-gestionar-producto  CLOSED  2026-08-30T21:21:00Z`.
  Ese trabajo (25 archivos, +1461/-82) **no entró en `develop`**.

- **La rama vieja estaba 26 commits por detrás y ya se eliminó.**
  `git rev-list --left-right --count origin/develop...feature/OFT0-55-gestionar-producto` → `26  1`.
  Borrada en local y remoto el 2026-09-28. El commit `854f76e` sigue accesible en
  `refs/pull/6/head`, porque GitHub conserva los refs de los PR cerrados:
  `git fetch origin refs/pull/6/head`.

- **Parte de la lógica de SKU sí está en `develop`.** Aunque el PR #6 se cerró,
  `producto-presentacion.utils.ts:8` existe en `origin/develop` y genera el SKU con
  el formato exacto que pide el criterio. Entró por otra vía, no por el PR #6.

- **Las promociones siguen sin conectar.** En `origin/develop` existen
  `domain/entities/promocion.entity.ts`, `domain/repositories/promocion.repository.ts`,
  `infrastructure/repositories/prisma-promocion.repository.ts`,
  `infrastructure/mappers/promocion.mapper.ts`,
  `presentation/presenters/promocion.presenter.ts` y los 3 DTO. Pero:
  - **no existe** el directorio `application/use-cases/promocion/`;
  - `grep -i promocion` sobre `presentation/catalog.module.ts` **no devuelve nada**:
    no está registrado ni como provider.

  Es decir: **infraestructura completa sin caso de uso y sin cableado.** Código
  muerto que ahora el criterio CA-9 convierte en requisito.

- **No existe el concepto `Visible en el Portal B` en la base.**
  `grep -i "portal\|visible"` sobre `prisma/schema.prisma` en `origin/develop` no
  devuelve nada. CA-5 requiere **migración**.

- **`destacado` ya existe en el modelo.** `model Producto` incluye
  `destacado Boolean @default(false)`. CA-8 no necesita migración, solo caso de
  uso y endpoint.

- **`sku` y `slug` son únicos a nivel de base.** En `model ProductoPresentacion`:
  `sku String @unique(map: "uq_producto_presentacion_sku")` y
  `slug String? @unique(map: "uq_producto_presentacion_slug")`.

- **Los 4 controladores de catalog declaran `@Roles`.** Una ocurrencia en cada uno
  de `categorias.controller.ts`, `presentaciones.controller.ts`,
  `producto-presentaciones.controller.ts` y `productos.controller.ts`.
  *Nota:* esto **corrige** un hallazgo de la auditoría de agosto, que reportaba
  cero guards en catalog. Desde el PR #9 los guards son globales y desde el PR #12
  `RolesGuard` deniega por defecto si falta `@Roles`.

## Supuestos

- **Supuesto:** "reflejar en el catálogo público" se implementa con el flag
  `Visible en el Portal B` y no con una tabla o vista aparte.
  *Confirma:* el usuario / analista funcional.

- **Supuesto:** el "producto terminado" que CA-4 manda crear automáticamente es una
  entidad del módulo `inventory`, no de `catalog`.
  *Confirma:* revisión del módulo `inventory` (pendiente) o el analista.

- **Supuesto:** el rol que puede escribir en el catálogo es el de operador de
  ventas o administrador, según el catálogo de roles del seed (PR #10).
  *Confirma:* el usuario. **Bloquea la implementación**: sin el rol correcto en
  `@Roles`, el endpoint queda inaccesible (PR #12).

- **Supuesto:** el descuento de CA-9 se aplica en la capa de aplicación al leer el
  precio, no persistiendo un precio con descuento.
  *Confirma:* el usuario.

## Decisiones pendientes

- **¿Entran las promociones (CA-9) en esta subtarea?**
  Es el criterio más caro: hay que crear los casos de uso, cablear el módulo,
  definir dónde se aplica el descuento y cómo se resuelve el solapamiento de
  vigencias. Podría ser una subtarea propia.
  *Decide:* el usuario. **Bloquea el plan técnico.**

- **¿`OFT0-345` cubre los 11 criterios o solo el núcleo de alta/edición?**
  La HU mezcla CRUD, SKU, inventario automático, visibilidad en otro portal,
  destacados, promociones, paginación y filtros. Son varias entregas razonables,
  no una.
  *Decide:* el usuario. **Bloquea el alcance.**

- **¿La HU se reabre o se re-audita?** Está `En curso` desde antes de la
  renumeración, con un PR cerrado detrás. Conviene decidir si se considera trabajo
  nuevo (lo es, en la práctica).
  *Decide:* el usuario.

- **¿CA-4 obliga a tocar el módulo `inventory`?** Si sí, esta subtarea cruza dos
  módulos y hay que auditar `inventory` antes de estimar.
  *Decide:* el usuario, tras la auditoría de `inventory`.

## Alcance

**Sin definir.** Depende de las dos primeras decisiones pendientes.

## Fuera de alcance

- Cualquier cambio en los frontends. Son de Roxwell y están denegados a la
  escritura. Si CA-5 o CA-9 cambian el contrato de la API, se documenta la
  dependencia y se comunica.
- `HU-A-008 Activar, desactivar y reactivar producto` es la subtarea `OFT0-349`,
  no esta.

## Plan técnico

**Sin definir. No se programa hasta cerrar las decisiones pendientes.**

Lo único ya acotado por la auditoría:

| Necesidad | Tipo de trabajo |
| --- | --- |
| CA-5 `Visible en el Portal B` | **migración Prisma** + campo en entidad, DTO, mapper y presenter |
| CA-8 destacados | caso de uso + endpoint (el campo ya existe, sin migración) |
| CA-9 promociones | casos de uso + cableado en `catalog.module.ts` + aplicación del descuento |

## Autorización de endpoints

`RolesGuard` deniega por defecto cuando falta `@Roles` (PR #12). Todo endpoint
nuevo tiene que declarar su rol.

| Endpoint | Método | Roles requeridos |
| --- | --- | --- |
| *(por definir según alcance)* | | **pendiente de confirmar** |

## Migraciones

**Sí, al menos una:** añadir el campo de visibilidad en Portal B a
`ProductoPresentacion` o a `Producto` (por decidir). Se crea con
`pnpm exec prisma migrate dev`.

## Dependencias con el frontend

CA-5 (visibilidad en Portal B) y CA-9 (precio con descuento aplicado) **cambian lo
que el portal del cliente recibe**. Antes de entregar, invocar
`frontend-contract-reader`.

Ojo: los dos clones locales de frontend apuntan a remotos muertos (404), así que
lo que se lea ahí puede estar desactualizado. Ver `context/repos.md`.

## Plan de pruebas

| Prueba | Tipo | Estado |
| --- | --- | --- |
| *(por definir según alcance)* | | pendiente |

QA no tiene dueño (`OFT0-347` sin asignar): las pruebas van en el mismo PR.

## Verificación

- [ ] `pnpm build`
- [ ] `pnpm lint:check`
- [ ] `pnpm format:check`
- [ ] `pnpm test`
- [ ] `pnpm test:e2e`
- [ ] `docker build` + smoke
- [ ] `pnpm exec prisma migrate status`
- [ ] `git diff --check`
- [ ] Sin `.env`, secretos, `dist/`, caches ni logs en el diff

**No ejecutado y por qué:** nada, todavía no hay implementación. La auditoría de
este documento es estática (lectura de `origin/develop`); no se ejecutó ninguna
prueba.

## Riesgos

1. **El alcance es demasiado grande para una subtarea.** 11 criterios, al menos una
   migración y un módulo (`promocion`) sin cablear. Alto riesgo de PR gigante y
   difícil de revisar.
2. **El sprint está vencido** y esta es la primera tarea por rank sin empezar.
3. **`inventory` puede estar implicado** (CA-4) y no está auditado.
4. **Las promociones son deuda heredada:** infraestructura completa, cero casos de
   uso, cero cableado. Quien las tome carga con el diseño entero.
5. **Riesgo de repetir el destino del PR #6.** Se cerró sin fusionar y no se
   registró por qué. Conviene saberlo antes de reimplementar lo mismo.

## Entrega

| | |
| --- | --- |
| PR | *sin crear* |
| Estado del CI | — |
| Jira | sin tocar |
