# OFT0-521 — HU-B-005 Consultar catálogo de productos

> **Regla de esta ficha:** separa siempre lo que **verificaste** de lo que
> **supones**. Todo hecho lleva evidencia (`archivo:línea`, commit o salida de
> comando). Un supuesto sin confirmar nunca se escribe como hecho.

## Identificación

| | |
| --- | --- |
| Subtarea backend | `OFT0-521` |
| HU padre | `OFT0-293` — HU-B-005 Consultar catálogo de productos (COMO cliente) |
| Bloqueada por (Jira) | OFT0-289 HU-B-001 Iniciar sesión (Por hacer), OFT0-249 HU-A-007 Gestionar producto (En revisión) |
| Bloquea a | OFT0-294 (carrito), OFT0-295 (pedido) |
| Sprint | Sprint 2 (208), 2026-09-28 → 2026-10-09 (vencido por fechas) |
| Rama | `feature/OFT0-521-consultar-catalogo-productos` |
| Commit base de `develop` | `4157aa8` |
| Fecha de auditoría | 2026-10-17 |

Criterio de la HU:

- **RF-B15:** listar los productos activos con nombre, descripción, categoría, imagen, presentaciones y precio.
- **RF-B16:** filtrar por categoría, buscar por nombre y ordenar por precio.
- **RF-B17:** ver el detalle con las presentaciones, los precios y las promociones activas.

Otras HU que afectan a esta:

- **RF-A025:** un producto nace oculto del Portal B.
- **RF-A021:** los destacados tienen más visibilidad.
- **RF-A022:** la promoción se aplica automáticamente al precio del catálogo público.
- **RF-A029:** los desactivados no aparecen en el catálogo público.

## Criterios de aceptación descompuestos

| # | Criterio | Estado | Evidencia |
| --- | --- | --- | --- |
| CA-1 | Solo se listan ítems visibles. Las condiciones son: presentación `estado=true`, `visible_portal_b=true`, producto `estado=true` y categoría `estado=true`. El cliente no puede cambiar este filtro. | ausente | `list-producto_presentacion-query.dto.ts:27-31` (filtro opcional); `prisma-producto_presentacion.repository.ts:45-88` |
| CA-2 | Cada ítem muestra nombre, descripción y categoría (`{id, nombre}`). | parcial (hay datos, no hay acceso) | `producto_presentacion.mapper.ts:62-72` |
| CA-3 | Cada ítem muestra su imagen (`imagen_url`). | parcial | `producto_presentacion.presenter.ts:17-19` |
| CA-4 | El listado es plano, una fila por presentación, con su presentación (nombre y medida) y su `precio`. | parcial | `mapper:40-44,73-79` |
| CA-5 | Se filtra con `categoria_id`. | parcial (solo para roles internos) | `list-producto_presentacion-query.dto.ts:33-42` |
| CA-6 | La búsqueda `q` se hace por **nombre de producto** (insensible a mayúsculas). No busca en sku ni en slug. | parcial | `repository:55-66` |
| CA-7 | El orden es `orden=precio_asc` o `orden=precio_desc`. Por defecto, primero los destacados y luego por nombre (RF-A021). El desempate es estable por id. | ausente | `repository:98` |
| CA-8 | El detalle `GET .../productos/:id` (el id es del **producto**) devuelve el producto con sus presentaciones visibles, cada una con su precio. | ausente | `productos.controller.ts:64-69`, `producto.presenter.ts:7-18` |
| CA-9 | Promociones activas y vigentes hoy, con la hora de Lima. En `porcentaje` y `monto_fijo` el backend calcula `precio_final`. En `nxm` y `regalo` devuelve `tipo` y una descripción (`"2x1"`, `cantidad_paga`/`cantidad_lleva`), y `precio_final` es igual al precio. El listado y el detalle exponen `promocion` (o `null`). | parcial | `mapper:17-25` (`take: 1`); `presenter:38-46` (sin `tipo`); `list-producto_presentacion.use-case.ts:25-26` (hora de Lima) |
| CA-10 | Acceso **público** sin login (`@Public()`), con límite de peticiones (rate limit) en este controlador. | ausente | `public.decorator.ts:3-4`; no hay throttler en `src` ni en `package.json` |
| CA-11 | Errores: 404 si el producto no existe o no es visible (inactivo, oculto, sin presentaciones visibles o con categoría inactiva); 400 si los parámetros no son válidos; 429 si se supera el límite. | parcial | `get-producto-by-id.use-case.ts:13-15` |
| CA-12 | Paginación `page`/`limit` (máximo 100) con `meta`, igual que el resto del repo. | cubierto (interno) | `pagination-query-dto.ts:5-25` |
| CA-13 | No se exponen datos internos: sku, `visible_portal_b`, stock mínimo y máximo, `stock_actual` ni auditoría. El stock solo sale como `disponible: boolean` (stock del producto terminado mayor que 0). | ausente si se reutiliza el presenter | `presenter:8-37`; `mapper:80-87` |
| CA-14 | No hay regresiones: los endpoints internos del catálogo y sus roles quedan igual. Swagger documentado, pruebas unitarias y e2e, y las puertas del CI en verde. | — | trabajo nuevo |

## Hechos auditados

- **Hecho:** todo el catálogo exige el rol `admin` o `ventas`; ningún endpoint usa `cliente` ni `@Public`. · *Evidencia:* `productos.controller.ts:33`, `producto-presentaciones.controller.ts:44`, `promociones.controller.ts:33`, `categorias.controller.ts:33,53,63`, `presentaciones.controller.ts:33,55,65`.
- **Hecho:** `@Public()` existe y lo respetan `JwtAuthGuard` y `RolesGuard`. · *Evidencia:* `public.decorator.ts:3-4`, `jwt-auth.guard.ts:13`, `roles.guard.ts:17-24`; se usa en `auth.controller.ts` y `health.controller.ts`.
- **Hecho:** `visible_portal_b` vale `false` por defecto y no se puede editar por API ni por seed. · *Evidencia:* `schema.prisma:363`, `producto_presentacion-repository.types.ts:23-28`, `update-producto_presentacion.dto.ts:4-10`.
- **Hecho:** el catálogo no tiene orden por precio ni un detalle con presentaciones y promociones. · *Evidencia:* `prisma-producto_presentacion.repository.ts:98`, `productos.controller.ts:64-69`.
- **Hecho:** la promoción vigente se limita a una (`take: 1`) y no expone `tipo`. · *Evidencia:* `producto_presentacion.mapper.ts:17-25`, `presenter:38-46`.
- **Hecho:** el repo no tiene rate limiting. · *Evidencia:* `grep throttl` sin resultados en `src` ni en `package.json`.
- **Hecho:** el PR #34 (OFT0-349, bersdecker) está abierto, 19 commits detrás de `develop`, toca `catalog.module.ts` y `test/catalogo.e2e-spec.ts`, y delega en HU-B-005 la tarea de ocultar los desactivados. · *Evidencia:* `gh pr view 34`; `git rev-list --left-right --count` → `19 1`.
- **Hecho:** no hay rama ni PR previo de OFT0-521 u OFT0-293. · *Evidencia:* `gh pr list --search` devuelve `[]`.
- **Hecho:** en frontend-next el catálogo es un mock con un tipo plano por presentación: `{id, name, desc, category, price, weight, img, available, promo: "2x1"|..., stock}`. · *Evidencia:* `origin/feature/Conectar-registro-api:src/features/catalogo/types.ts:1-14`, `mock-data.ts:1`. El remoto responde "Repository not found", así que las refs locales son de agosto de 2026.

## Supuestos

- **Supuesto:** la paginación (CA-12) y no exponer datos internos (CA-13) son requisitos implícitos. · *Confirma:* PO.
- **Supuesto:** "producto activo" exige que la categoría también esté activa. · *Confirma:* PO.
- **Supuesto:** `disponible` significa stock del producto terminado mayor que 0. · *Confirma:* PO o el responsable de OFT0-522.
- **Supuesto:** el Portal A no se afecta porque no se tocan los controladores existentes. · *Confirma:* el responsable de frontend-francos.

## Decisiones

Tomadas por Ruben el 2026-10-17:

- **Acceso:** público (`@Public()`), con rate limit.
- **`visible_portal_b`:** se filtra por él. El toggle lo hace HU-A-007 (bersdecker) y queda como dependencia; los e2e preparan sus propios datos de prueba. **Hasta que exista el toggle, el catálogo real sale vacío.**
- **Promoción:** el backend calcula `precio_final` para `porcentaje` y `monto_fijo`, y describe `nxm` y `regalo`.
- **Stock:** solo `disponible: boolean`.

Tomadas con el criterio recomendado por la auditoría:

- **Controlador:** uno nuevo, de solo lectura, con presenter propio. No se tocan los endpoints internos.
- **Forma del listado:** plano, una fila por presentación (encaja con el mock del frontend). El detalle se agrupa por producto.
- **Categorías inactivas:** sus productos se ocultan.
- **PR #34:** no se espera. El conflicto en `catalog.module.ts` es solo textual.

Tomadas durante la implementación (2026-10-17):

- **Rate limit:** 60 peticiones por IP en una ventana de 60 s, configurable con `CATALOGO_PUBLICO_RATE_LIMIT` y `CATALOGO_PUBLICO_RATE_TTL_MS`. Ambas son opcionales y tienen valores por defecto en Joi, así que el CI y el contenedor no necesitan variables nuevas. El contador es por controlador, handler e IP (la clave por defecto de `@nestjs/throttler`): el listado y el detalle cuentan por separado.
- **Repositorio propio:** se crea `CatalogoPublicoRepository` en vez de añadir métodos a `ProductoPresentacionRepository`, para no tocar el contrato ni los mocks internos.
- **`precio_final` va en `application/utils/precio-final.utils.ts`**, junto a `promocion.utils.ts` (el patrón del módulo), y no en `domain` como decía el plan técnico. El presenter la llama.
- **El orden por precio usa `precio_unitario`** (el precio de lista), no `precio_final`. Ordenar por el precio con descuento exigiría SQL crudo. El desempate es por `id`.
- **El detalle ordena sus presentaciones** por `precio_unitario` asc y luego por `id`.
- **No se exponen `precio_mayorista` ni `umbral_mayorista`:** ningún CA los pide.
- **Descripción de la promoción:** `porcentaje` → `"N% de descuento"`, `monto_fijo` → `"S/ N.NN de descuento"`, `nxm` → `"{lleva}x{paga}"` (o el nombre, si faltan cantidades), `regalo` → el nombre de la promoción.
- **Contrato público** (para OFT0-522):
  - Listado: `{ data: [{ id, slug, producto_id, nombre, descripcion, destacado, categoria: {id, nombre}, presentacion: {id, cantidad, unidad_medida, descripcion}, imagen_url, precio, precio_final, disponible, promocion }], meta: {total, page, limit, total_pages} }`. El `id` es el de `producto_presentacion`.
  - Detalle: `{ id, nombre, descripcion, destacado, categoria, presentaciones: [{ id, slug, presentacion, imagen_url, precio, precio_final, disponible, promocion }] }`.
  - `promocion`: `{ tipo, nombre, descripcion, valor, cantidad_paga, cantidad_lleva, fecha_inicio, fecha_fin }` o `null`.

## Decisiones pendientes

- ~~El límite exacto del rate limit.~~ Implementado con la propuesta (60/min por IP), configurable por env. Si el equipo quiere otro valor, basta con la variable. · *Decide:* Ruben / equipo · *Bloquea:* no.
- **Decisión:** si el catálogo público debe ocultar las presentaciones cuya `presentacion` (la medida, tabla `presentacion`) está inactiva. Hoy no se filtra por ese estado porque ningún CA lo pide. · *Decide:* PO · *Bloquea:* no.

## Alcance

CA-1 a CA-14.

## Fuera de alcance

- El endpoint para activar o desactivar `visible_portal_b`: es HU-A-007 de bersdecker.
- Cambiar roles, presenters o filtros de los endpoints internos.
- Un rate limit global de la app.
- Carrito y pedido (OFT0-294 y OFT0-295).
- El frontend.

## Plan técnico

Todo vive dentro del módulo `src/modules/catalog/` (no es un módulo nuevo), reutilizando sus repositorios cuando sirvan y agregando métodos de lectura específicos.

| Capa | Archivos |
| --- | --- |
| `domain` | Tipos de lectura del catálogo público (`CatalogoPublicoItem`, `CatalogoPublicoProducto`); una función pura para calcular `precio_final` y la descripción de la promoción; métodos de repositorio de solo lectura. |
| `application` | `ListCatalogoPublicoQueryDto` con `page`, `limit`, `q`, `categoria_id` y `orden` (`precio_asc`/`precio_desc`); `ListCatalogoPublicoUseCase`; `GetProductoPublicoUseCase` (404 si no es visible). |
| `infrastructure` | Una query Prisma con filtros **fijos**: presentación activa, visible en el Portal B, producto activo y categoría activa. Incluye la promoción vigente (promoción activa con `fecha_inicio <= hoy <= fecha_fin`, hora de Lima, igual que el use case actual), la categoría y el stock del producto terminado para `disponible`. Ordena por `precio_unitario` cuando se pide. |
| `presentation` | `catalogo-publico.controller.ts` con `@Controller('catalogo')`, `@Public()` a nivel de clase y rate limit; `GET /catalogo/productos` y `GET /catalogo/productos/:id`. Un presenter propio que no expone datos internos. |
| deps | `@nestjs/throttler`, registrado en `CatalogModule` o en `AppModule` **sin** guard global; el `ThrottlerGuard` se aplica solo en este controlador con `@UseGuards`. Este cambio toca dependencias, así que la puerta docker es obligatoria. |

Versiones usadas: `@nestjs/throttler` 6.7.1 (peer `@nestjs/common`/`@nestjs/core` `^11`, comprobado con `pnpm view`), NestJS 11.1.28 y Prisma 7.8.0. **Context7 no estaba disponible en la sesión del agente.** La API de `@nestjs/throttler` se tomó de sus tipos y su código instalados (`node_modules/@nestjs/throttler/dist/*.d.ts`, `throttler.guard.js` y `throttler.service.js`, v6.7.1).

Archivos (todos en `backend-monolito-francos`):

- `src/config/envs.ts` (modificado)
- `src/modules/catalog/presentation/catalog.module.ts` (modificado)
- `src/modules/catalog/domain/repositories/catalogo-publico.repository.ts`
- `src/modules/catalog/domain/repositories/types/catalogo-publico-repository.types.ts`
- `src/modules/catalog/infrastructure/mappers/catalogo-publico.mapper.ts`
- `src/modules/catalog/infrastructure/repositories/prisma-catalogo-publico.repository.ts`
- `src/modules/catalog/application/dto/catalogo-publico-dtos/list-catalogo-publico-query.dto.ts`
- `src/modules/catalog/application/use-cases/catalogo-publico/list-catalogo-publico.use-case.ts`
- `src/modules/catalog/application/use-cases/catalogo-publico/get-producto-publico.use-case.ts`
- `src/modules/catalog/application/use-cases/catalogo-publico/catalogo-publico.use-case.spec.ts`
- `src/modules/catalog/application/utils/precio-final.utils.ts` y `.spec.ts`
- `src/modules/catalog/presentation/controllers/catalogo-publico.controller.ts`
- `src/modules/catalog/presentation/presenters/catalogo-publico.presenter.ts` y `.spec.ts`
- `test/catalogo-publico.e2e-spec.ts`
- `package.json` y `pnpm-lock.yaml` (generados por `pnpm add @nestjs/throttler`)

## Autorización de endpoints

| Endpoint | Método | Roles requeridos |
| --- | --- | --- |
| `/api/v1/catalogo/productos` | GET | público (`@Public()`) + rate limit |
| `/api/v1/catalogo/productos/:id` | GET | público (`@Public()`) + rate limit |

## Migraciones

Ninguna. La BD local tiene aplicadas además las migraciones de OFT0-473 y OFT0-493, que no están en esta rama. Es lo esperado y no afecta.

## Dependencias con el frontend

- **Contrato nuevo** para OFT0-522 (frontend-next): `/api/v1/catalogo/productos` y `/:id`. Los campos van en español (`nombre`, `precio`, `imagen_url`...), no con los nombres del mock (`name`, `price`, `img`). Hay que avisar al responsable de OFT0-522.
- **Avisar a bersdecker (HU-A-007):** sin un endpoint que active `visible_portal_b`, el catálogo público sale vacío.

## Plan de pruebas

| Prueba | Tipo | Estado |
| --- | --- | --- |
| `precio_final` para porcentaje, monto fijo, nxm, regalo y sin promoción; redondeo a 2 decimales; nunca menor que 0; sin errores de coma flotante; `describirPromocion` | unitaria (`precio-final.utils.spec.ts`, 10 tests) | **pasa** |
| Use cases: solo pasan los filtros del cliente y el día de Lima; 404 si no es visible | unitaria (`catalogo-publico.use-case.spec.ts`, 3 tests) | **pasa** |
| Presenter: fila plana sin datos internos, `imagen_url`, `precio_final`, promoción, detalle agrupado, `meta` | unitaria (`catalogo-publico.presenter.spec.ts`, 6 tests) | **pasa** |
| Listado sin token → 200 (y con un token inválido → 200); solo aparecen los ítems visibles (la presentación oculta, la inactiva, el producto inactivo y la categoría inactiva no salen) | e2e | **pasa** |
| Filtro por categoría, búsqueda por nombre (sin distinguir mayúsculas, no por sku), orden por defecto (destacados primero), orden por precio asc/desc, paginación, 400 con `limit=101`, `orden` desconocido, `categoria_id=abc`, `estado` y `visible_portal_b` | e2e | **pasa** |
| Detalle: presentaciones visibles ordenadas por precio, porcentaje con `precio_final`, nxm "2x1", promoción vencida → `null`, `disponible=false` sin stock; 404 si está inactivo, en una categoría inactiva, sin presentaciones activas, oculto o no existe; 400 si el id no es numérico | e2e | **pasa** |
| La respuesta (listado y detalle) no incluye sku, `visible_portal_b`, stock_*, `producto_terminado`, timestamps, `estado` ni precios mayoristas | e2e | **pasa** |
| Rate limit: `limit` peticiones → 200 con `X-RateLimit-Limit`; la siguiente → 429 con `Retry-After` | e2e | **pasa** |
| Los endpoints internos siguen exigiendo token (`GET /productos` sin token → 401) y roles | e2e (el nuevo + los existentes, que pasan sin cambios) | **pasa** |

Aislamiento del e2e: los datos usan el prefijo `E2E-521` / `e2e-521-` y se crean y borran con Prisma directo (`beforeAll` limpia restos y `afterAll` borra todo). No hace falta crear usuarios. El contador del rate limit se vacía en `beforeEach` con `ThrottlerStorageService.onApplicationShutdown()`, porque el servicio no tiene un `reset` público. Las demás suites no pueden recibir 429: cada suite levanta su propia app (y su propio storage en memoria), y la clave del contador incluye el controlador.

## Verificación

Ejecutado el 2026-10-17, con las variables falsas de `.github/workflows/ci.yml` exportadas en el proceso (sin leer ni tocar `.env`):

- [x] `pnpm build` → `nest build` sin errores.
- [x] `pnpm lint:check` → exit 0, 0 errores y 0 warnings. La primera pasada dio 8 errores de `prettier/prettier` en 3 archivos nuevos, que se corrigieron a mano (sin `pnpm lint` ni `pnpm format`).
- [x] `prettier --check` sobre los 16 archivos tocados (`.ts`) → "All matched files use Prettier code style!". El `format:check` global no se corrió: falla en local por CRLF preexistente.
- [x] `pnpm test` → 62 suites y 327 tests, todos en verde.
- [x] `pnpm test:e2e --ci --runInBand` → 11 suites y 185 tests, todos en verde (la suite nueva aporta 24). Sale un `DeprecationWarning` de `pg` ("client.query() when the client is already executing a query"), pero ya aparecía en `catalogo.e2e-spec.ts` sin estos cambios.
- [x] `docker build` + smoke → el primer intento falló porque Docker Desktop se cayó (`input/output error` al exportar la imagen; 16,8 GB libres en C:). Tras reiniciar Docker Desktop: `docker build -t francos-backend:oft0-521 .` exit 0. Smoke con contenedor autodestruible (`timeout 60 node dist/main.js`, puerto 3095, env del CI): `/api/v1/health/live` → `{"status":"ok"}`, `/api/docs` → 200, `GET /api/v1/catalogo/productos` sin token → 500 (no hay BD en el contenedor; **no 401**, así que la ruta es pública), `GET /api/v1/productos` sin token → 401, cabeceras `X-RateLimit-Limit: 60` presentes.
- [x] `pnpm exec prisma migrate status` → "Database schema is up to date!" (21 migraciones). Esta rama no trae migraciones. `prisma validate` → válido.
- [x] Revisión independiente (`/task-verify`): listo para PR, sin bloqueantes. 0 filas `e2e-521%` tras el e2e (consulta de solo lectura); gitleaks "no leaks found" en los 17 archivos.
- [x] `git diff --check` → exit 0, sin errores de espacios.
- [x] `pnpm audit --prod --audit-level critical` (la puerta del CI) → exit 0. Las rutas en las que aparece `@nestjs/throttler` son transitivas por `@nestjs/core`, que ya estaba en el proyecto.
- [x] Sin `.env`, secretos, `dist/`, caches ni logs en el diff: `git status` solo muestra los archivos listados en el plan técnico.

No ejecutado y por qué: `pnpm format:check` global (falla en local por CRLF preexistente; en CI pasa).

Desviaciones respecto al plan:

- `precio_final` vive en `application/utils` (el patrón del módulo), no en `domain`.
- Repositorio propio (`CatalogoPublicoRepository`) en lugar de métodos nuevos en los repositorios existentes.
- Se añaden dos variables de entorno opcionales (`CATALOGO_PUBLICO_RATE_LIMIT`, `CATALOGO_PUBLICO_RATE_TTL_MS`) con valores por defecto.

## Riesgos

- **El catálogo real sale vacío hasta que HU-A-007 exponga el toggle de `visible_portal_b`.**
- **Conflicto textual con el PR #34** en `catalog.module.ts` y, posiblemente, en `test/catalogo.e2e-spec.ts`.
- **La nueva dependencia `@nestjs/throttler`** pasa por `pnpm audit` y el Dockerfile.
- **El rate limit en memoria** no se comparte entre réplicas.
- **El contrato con frontend-next no se puede contrastar** con su estado actual: el remoto no es accesible.
- **El rate limit cuenta por `req.ip`.** La app no configura `trust proxy`. Detrás de un proxy inverso o un balanceador, todos los clientes compartirían la IP del proxy y el límite se agotaría entre todos. Hay que revisarlo al desplegar.
- **`ThrottlerModule` es `@Global`.** Registrarlo en `CatalogModule` deja sus providers disponibles en toda la app, pero sin guard global: solo limita donde se use `@UseGuards(ThrottlerGuard)`.
- **El orden por precio usa el precio de lista**, no el `precio_final` con descuento.

## Entrega

| | |
| --- | --- |
| PR | [#46](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/46): commits `fce8004` + `c7ee8fc` (merge de develop, conflicto en `src/config/envs.ts` resuelto conservando las vars de Culqi y las del rate limit) |
| Estado del CI | Verde en las 6 puertas, run 39101104489. En local, sobre develop `b91e1c7`: build, lint, 462 unitarias y 238 e2e sobre una base limpia |
| Jira | En revisión (transición 31) + comentario 10094 |
