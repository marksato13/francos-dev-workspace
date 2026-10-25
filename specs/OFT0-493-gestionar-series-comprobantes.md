# OFT0-493 — HU-A-044 Gestionar series de comprobantes

> **Regla de esta ficha:** separa siempre lo que **verificaste** de lo que
> **supones**. Todo hecho lleva evidencia (`archivo:línea`, commit o salida de
> comando). Un supuesto sin confirmar nunca se escribe como hecho.

## Identificación

| | |
| --- | --- |
| Subtarea backend | `OFT0-493` |
| HU padre | `OFT0-286` — HU-A-044 Gestionar series de comprobantes (RN23, 1 SP) |
| Épica | `OFT0-316` — Módulo de Configuración del Sistema |
| Sprint | Sprint 2 (208), 2026-09-28 → 2026-10-09; por fechas ya terminó |
| Rama | `feature/OFT0-493-gestionar-series-comprobantes` |
| Commit base de `develop` | `4157aa8` (merge del PR #37) |
| Fecha de auditoría | 2026-10-17 |

Criterio de la HU (literal, resumido):
- **RF-A189:** el administrador configura las series.
- **RF-A190:** correlativo automático e incremental por serie.
- **RF-A191:** activar o desactivar series.
- **RF-A192:** alerta cuando una serie está próxima a agotar su rango.

## Criterios de aceptación descompuestos

| # | Criterio | Estado | Evidencia |
| --- | --- | --- | --- |
| CA-1 | El admin crea una serie con `tipo` (`boleta`/`factura`), `serie` (código), `correlativo_inicio`, `correlativo_fin` y, opcionalmente, `umbral_alerta`. Responde 201. | implementado (sin commit) | `git grep -i "serie\|comprobante" origin/develop -- prisma src` sin coincidencias de dominio |
| CA-2 | El admin lista las series (filtros `tipo`, `estado`, `por_agotar`) y consulta una por id. Cada serie expone `correlativo_actual`, `siguiente`, `restantes`, `por_agotar` y `estado`. | implementado (sin commit) | ídem |
| CA-3 | El admin edita una serie. Si ya emitió algún número, solo puede **ampliar** `correlativo_fin` y cambiar `umbral_alerta`; cualquier otro cambio responde 409. Reducir el fin por debajo del correlativo actual responde 409. Si todavía no emitió, puede editarlo todo. | implementado (sin commit) | ídem |
| CA-4 | Validaciones. El código sigue el formato SUNAT: `^B[A-Z0-9]{3}$` para boleta y `^F[A-Z0-9]{3}$` para factura; si el prefijo no corresponde al tipo, 400. El código es único (409). Debe cumplirse `1 ≤ inicio ≤ fin ≤ 99999999` (400). Una serie inexistente responde 404. | implementado (sin commit) | ídem |
| CA-5 | Cada serie tiene su propio correlativo. El primer número reservado es `correlativo_inicio` y los siguientes suman 1, sin huecos. Reservar en una serie no avanza las demás. | implementado (sin commit) | no hay modelo |
| CA-6 | La reserva es atómica en BD: N reservas concurrentes sobre la misma serie dan N números distintos y consecutivos. **No se usa** el patrón `count + 1`. | implementado (sin commit) | `src/modules/strategic/infrastructure/repositories/prisma-objetivo-estrategico.repository.ts:28-37` acepta la carrera; no copiarlo |
| CA-7 | Hay un servicio interno exportado por `SalesModule`, `reservarCorrelativo(tipo)`, que devuelve `{ serie_id, serie, numero }` para OFT0-541. **No es un endpoint HTTP.** | implementado (sin commit) | `src/modules/sales/presentation/sales.module.ts:3-7` vacío |
| CA-8 | Reservar falla con un error de dominio claro (409 si se propaga a HTTP) en tres casos: no hay serie activa del tipo, la serie está agotada o la serie está inactiva. Nunca entrega un número fuera de rango. | implementado (sin commit) | ídem |
| CA-9 | El admin desactiva y reactiva una serie, con la misma convención de rutas que el resto del repo (ver plan). Responde 200 con el estado nuevo y 404 si la serie no existe. | implementado (sin commit) | ídem |
| CA-10 | Una serie inactiva no entrega correlativos. Desactivar no borra ni reinicia el correlativo, y al reactivar se continúa desde el último. No hay borrado físico. | implementado (sin commit) | ídem |
| CA-11 | Solo puede haber **una serie activa por tipo**. Crear o activar una segunda serie activa del mismo tipo responde 409, garantizado con un índice único parcial en la BD. | implementado (sin commit) | mismo patrón que `uq_empresa_emisora` del PR #38 |
| CA-12 | Umbral por serie: `umbral_alerta Int @default(100)`, con `restantes = correlativo_fin - correlativo_actual`. Se cumple `por_agotar = estado && restantes <= umbral_alerta`. | implementado (sin commit) | — |
| CA-13 | `GET /series-comprobante/alertas` devuelve las series activas con `por_agotar = true`. | implementado (sin commit) | — |
| CA-14 | Todos los endpoints llevan `@Roles('admin')`: 401 sin JWT y 403 con `ventas` o `cliente`. | implementado (sin commit) | `src/modules/auth/presentation/guards/roles.guard.ts:40-42`, `src/modules/auth/presentation/auth.module.ts:55-62` |
| CA-15 | Errores manejados, Swagger documentado, pruebas unitarias y e2e (incluida una de concurrencia) y las puertas del CI en verde. | implementado (sin commit) | trabajo nuevo |

## Hechos auditados

- **Hecho:** en `develop` no existe ningún modelo, enum, DTO ni endpoint de serie o comprobante. · *Evidencia:* `git grep -i -E "serie|comprobante|boleta|factura|correlativ" origin/develop -- prisma src test` solo encuentra el correlativo de objetivos estratégicos.
- **Hecho:** tampoco existen `Pedido`, `Pago` ni `Venta` en el schema. · *Evidencia:* `grep "model (Pedido|Pago|Venta)" prisma/schema.prisma` devuelve exit 1.
- **Hecho:** los schemas de PostgreSQL son `public`, `persons`, `commerce` y `strategic`. · *Evidencia:* `prisma/schema.prisma:7`.
- **Hecho:** `SalesModule` está vacío pero ya se importa en la app. · *Evidencia:* `src/modules/sales/presentation/sales.module.ts:3-7`, `src/app.module.ts:21`.
- **Hecho:** `RolesGuard` deniega cuando falta `@Roles` y es global. · *Evidencia:* `roles.guard.ts:40-42`, `auth.module.ts:55-62`.
- **Hecho:** los roles sembrados son admin, ventas, cliente, inventario, produccion y estrategico. · *Evidencia:* `prisma/seeds/roles.seed.ts:3-10`.
- **Hecho:** el correlativo que ya existe en el repo usa `count + 1` y acepta la carrera. · *Evidencia:* `prisma-objetivo-estrategico.repository.ts:28-37`.
- **Hecho:** en Prisma 7, `increment` es atómico en `update` y `updateMany`. · *Evidencia:* https://www.prisma.io/docs/orm/reference/prisma-client-reference (atomic number operations); el repo usa Prisma `^7.8.0` (`package.json:35,46`).
- **Hecho:** el PR #38 (OFT0-473, abierto) toca `prisma/schema.prisma` y agrega la migración `20261016210224_add_empresa_es_emisora`. El PR #39 (OFT0-485, abierto) no toca `prisma/`. · *Evidencia:* `gh pr list`, `git show origin/feature/OFT0-473-gestionar-datos-empresa`.
- **Hecho:** frontend-next define `TipoComprobante = "boleta" | "factura"`. · *Evidencia:* `origin/feature/Crear-pedido:src/features/checkout/types.ts:1`. frontend-francos no tiene referencias a series.
- **Hecho:** no hay ramas, PRs ni commits previos de OFT0-493. · *Evidencia:* `git branch -r`, `gh pr list --state all --search "OFT0-493"`.

## Supuestos

- **Supuesto:** el texto de RN23 no se pudo leer (no aparece en Jira, Confluence ni `documentos/`). Se asume formato SUNAT (B### / F###, correlativo de hasta 8 dígitos) y rango de inicio a fin por serie. · *Confirma:* PO (reporter de la HU), con el texto de RN23.
- **Supuesto:** los únicos tipos de comprobante son boleta y factura; no hay notas de crédito ni de débito. · *Confirma:* PO.
- **Supuesto:** OFT0-541 (HU-B-010, la misma persona) consumirá `reservarCorrelativo`; con exportarlo desde `SalesModule` alcanza. · *Confirma:* Ruben.
- **Supuesto:** el frontend admin (OFT0-494) consumirá el CRUD REST en `/api/v1/series-comprobante`. · *Confirma:* el responsable del frontend.

## Decisiones

Tomadas por Ruben el 2026-10-17:

- **Formato:** SUNAT `B###` / `F###`, validado por tipo.
- **Activas:** una sola serie activa por tipo, con índice único parcial.
- **Alerta:** se expone en los GET (`restantes`, `por_agotar`) más `GET /alertas`, con umbral por serie (100 por defecto). La notificación persistida queda para OFT0-541.
- **Arranque:** se empieza ya, sin FK a Empresa. La emisora es única, así que no hace falta vincularla.

Tomadas con el criterio recomendado de la auditoría (se pueden revisar):

- **Tipo de comprobante:** enum Prisma `TipoComprobante { boleta, factura }`, en minúscula, igual que el frontend Next.
- **Schema PG:** `commerce`.
- **Módulo Nest:** se llena el `SalesModule` que hoy está vacío.
- **Edición después de emitir:** solo se puede ampliar el fin y cambiar el umbral. No hay DELETE físico.
- **Lectura:** solo admin, igual que en los PR #38 y #39. El checkout no lee series.
- **Seed de ruta de menú:** no se hace. Se coordina con el frontend (OFT0-494).

Tomadas durante la implementación (2026-10-17), revisables:

- **Nombre del enum en PG:** `commerce.tipo_comprobante` (`@@map`), no `"TipoComprobante"`, siguiendo la convención de `tipo_promocion` y `unidad_medida_presentacion_enum` del mismo schema.
- **`estado` opcional al crear** (true por defecto), como en `CreateEmpresaDto`. Permite preparar la siguiente serie inactiva mientras otra del mismo tipo está activa.
- **`correlativo_actual` en HTTP es `null` mientras la serie no emitió.** En la BD vale `inicio - 1`; exponer ese valor (por ejemplo, 0) confundía. `siguiente` siempre dice qué número saldrá.
- **"Solo ampliar" es estricto:** tras emitir, cualquier `correlativo_fin` menor que el actual responde 409, con un mensaje distinto si además queda por debajo del último emitido.
- **Edición antes de emitir con condición optimista:** el `UPDATE` exige que `correlativo_actual` no haya cambiado desde la lectura; si alguien reservó en medio, 409.
- **Filtro `por_agotar`:** Prisma no compara columnas con aritmética, así que los ids salen de un `SELECT` con `$queryRaw` tipado y se combinan con el `findMany` paginado.
- **Reserva:** un único `UPDATE ... SET correlativo_actual = correlativo_actual + 1 WHERE tipo = $1 AND estado AND correlativo_actual < correlativo_fin RETURNING` vía `$queryRaw` tipado. Si no devuelve fila, se diagnostica: sin serie del tipo → `sin_serie_activa`; solo inactivas → `serie_inactiva`; activa al tope → `serie_agotada` (`CorrelativoNoDisponibleError`, 409, con `motivo`). Un reintento acotado cubre la carrera "se activó o amplió entre el UPDATE y el diagnóstico".
- **CHECK añadidos a mano:** `ck_serie_comprobante_rango` (1 ≤ inicio ≤ fin ≤ 99999999), `ck_serie_comprobante_actual` (inicio − 1 ≤ actual ≤ fin) y `ck_serie_comprobante_umbral` (umbral ≥ 0).
- **Documentación:** Context7 no estaba disponible en la sesión del agente. Se usaron las versiones instaladas, verificadas en `node_modules`: Prisma 7.8.0, @nestjs/core 11.1.28 y Jest 30.4.2. Los patrones (`$queryRaw` tipado, `updateMany`, P2002) ya existían en el repo.

## Decisiones pendientes

- **Decisión:** que el PO valide el formato SUNAT y el rango cuando aparezca RN23. · *Decide:* PO · *Bloquea:* no.

## Alcance

CA-1 a CA-15.

## Fuera de alcance

- La emisión real del comprobante, el modelo `Comprobante`, el PDF y el correo. Es OFT0-541 / HU-B-010.
- La elección de boleta o factura en el checkout, RUC y razón social. Es OFT0-537 / HU-B-009.
- `Pedido` y `Pago` (no existen todavía).
- La notificación persistida para los admin y el valor nuevo de `TipoEventoNotificacion`.
- Las notas de crédito y de débito.
- La FK a `Empresa`.
- El seed de ruta de menú.
- El frontend.

## Plan técnico

Módulo `src/modules/sales/`, con las mismas capas y estilo que `persons` (repositorio abstracto, use cases, mapper, presenter).

| Capa | Archivos |
| --- | --- |
| `prisma` | `schema.prisma`: enum `TipoComprobante` y modelo `SerieComprobante` en `@@schema("commerce")`, tabla `serie_comprobante`. Campos: `id`, `tipo`, `serie` (VarChar(4), único), `correlativo_inicio`, `correlativo_fin`, `correlativo_actual` (el último emitido; se crea con `inicio - 1`), `umbral_alerta` (100 por defecto), `estado` (true por defecto) y timestamps, con la misma convención de ids y columnas que los modelos de `commerce`. La migración nueva lleva timestamp posterior a `20261016210224` e incluye el índice único parcial `uq_serie_activa_por_tipo ON (tipo) WHERE estado = true` y CHECKs de rango. |
| `domain` | entidad `SerieComprobante` con las reglas `restantes`, `porAgotar`, `haEmitido` y `siguiente`; repositorio abstracto; tipos; error de dominio para "sin serie activa", "agotada" e "inactiva". |
| `application` | DTOs de crear, actualizar y listar (query). Use cases: crear, listar, obtener por id, actualizar, cambiar estado, listar alertas y `ReservarCorrelativoUseCase`, que es el servicio exportado. |
| `infrastructure` | `PrismaSerieComprobanteRepository` y su mapper. La reserva se hace en un solo statement atómico: `UPDATE ... SET correlativo_actual = correlativo_actual + 1 WHERE id = ? AND estado AND correlativo_actual < correlativo_fin RETURNING ...`, o `updateMany` con `increment` y relectura dentro de la misma transacción. P2002 sobre el índice parcial o sobre `serie` se traduce a 409. |
| `presentation` | `series-comprobante.controller.ts` (`@Controller('series-comprobante')`, `@Roles('admin')`), presenter, y `sales.module.ts` registrando todo y exportando `ReservarCorrelativoUseCase`. |

**Migración local:** la BD local ya tiene aplicada la migración de OFT0-473, que no está en `develop`. Por eso `migrate dev` detectaría deriva. El SQL se genera con `prisma migrate diff --from-schema <schema de origin/develop guardado en scratchpad> --to-schema prisma/schema.prisma --script`; el índice parcial y los CHECK se agregan a mano, y se aplica con `pnpm exec prisma migrate deploy`. `migrate reset`, `db push` y `db execute` están denegados.

## Autorización de endpoints

| Endpoint | Método | Roles requeridos |
| --- | --- | --- |
| `/api/v1/series-comprobante` | POST | admin |
| `/api/v1/series-comprobante` | GET | admin |
| `/api/v1/series-comprobante/alertas` | GET | admin |
| `/api/v1/series-comprobante/:id` | GET | admin |
| `/api/v1/series-comprobante/:id` | PATCH | admin |
| desactivar / activar (misma convención que `usuarios-internos.controller.ts`: `DELETE /:id` desactiva y `PATCH /:id/activate` reactiva) | DELETE / PATCH | admin |
| `reservarCorrelativo` | — (servicio interno, sin HTTP) | — |

## Migraciones

Una nueva: `<timestamp>_add_serie_comprobante`. Crea el enum `commerce."TipoComprobante"`, la tabla `commerce.serie_comprobante`, el UNIQUE de `serie`, el índice único parcial por tipo activo y los CHECK de rango. `schema.prisma` y la migración van en el mismo commit.

## Dependencias con el frontend

- **Contrato nuevo** para OFT0-494 (frontend admin): `/api/v1/series-comprobante`, con `tipo` en minúscula `boleta|factura`. Hay que avisar a quien lleve OFT0-494.
- **No se rompe ningún contrato existente.**

## Plan de pruebas

| Prueba | Tipo | Estado |
| --- | --- | --- |
| Reglas de la entidad (restantes, por_agotar, haEmitido, siguiente) | unitaria | hecha, pasa (`serie-comprobante.entity.spec.ts`, 5) |
| Crear: formato por tipo, rango, duplicado, segunda activa → 409 | unitaria + e2e | hecha, pasa (`create-serie-comprobante.use-case.spec.ts`, 7; e2e: 7 casos 400, 409 duplicado, 409 segunda activa, e índice parcial y CHECK probados directo en la BD) |
| Editar: antes y después de emitir, reducir el fin → 409 | unitaria + e2e | hecha, pasa (`update-serie-comprobante.use-case.spec.ts`, 13; e2e: 5) |
| Activar y desactivar: 404, una sola activa por tipo, conserva el correlativo | unitaria + e2e | hecha, pasa (`change-serie-comprobante-status.use-case.spec.ts`, 4; e2e: 4) |
| `alertas` y filtro `por_agotar` | e2e | hecha, pasa (2, más los filtros `tipo` y `estado`) |
| Reserva: el primer número es el inicio, luego +1; agotada, inactiva o sin serie → error | unitaria + e2e (servicio obtenido con `app.get(ReservarCorrelativoUseCase)`) | hecha, pasa (`reservar-correlativo.use-case.spec.ts`, 5; e2e: inicio, +1, independencia entre series, inactiva, agotada) |
| Reserva concurrente: N en paralelo dan N números distintos y consecutivos | e2e | hecha, pasa (25 en `Promise.all` → 4..28; y 6 en paralelo sobre un rango de 3 → exactamente {1,2,3} y 3 `serie_agotada`) |
| 401 sin token y 403 con ventas y cliente | e2e | hecha, pasa |
| Presenter (`correlativo_actual` null sin emitir, restantes, por_agotar) | unitaria | hecha, pasa (`serie-comprobante.presenter.spec.ts`, 2) |
| Repositorio: P2002 → `ResourceConflictError` sin pasar por el caso de uso (`create` con código duplicado, `create` de una segunda activa del tipo, `setStatus` activando una segunda) | e2e (`app.get(SerieComprobanteRepository)`) | hecha, pasa (3; también comprueba que no quedó fila ni cambió el estado) |
| Repositorio: condición optimista de `update` (`expectedCorrelativoActual` incorrecto → `ResourceConflictError`, la fila no cambia; con el valor correcto sí actualiza) | e2e | hecha, pasa (1) |
| `null` explícito en PATCH (`umbral_alerta`, `correlativo_fin`, `serie`, `tipo`, `correlativo_inicio`) y `umbral_alerta: null` en POST → 400, no 500 | e2e | hecha, pasa (6; el PATCH se prueba sobre una serie emitida y otra sin emitir) |

Corrección tras la verificación (2026-10-17): `UpdateSerieComprobanteDto` usa `PartialType(..., { skipNullProperties: false })` (opción de `@nestjs/swagger` 11, comprobada en `node_modules/@nestjs/swagger/dist/type-helpers/partial-type.helper.js:14`), y `umbral_alerta` en `CreateSerieComprobanteDto` cambió `@IsOptional()` por `@ValidateIf((_, v) => v !== undefined)`, igual que en `move-ruta.dto.ts`. Así un campo omitido sigue siendo opcional, pero un `null` explícito da 400. La línea en blanco doble de `migration.sql` no se tocó: la migración ya está aplicada en local y cambiaría el checksum.

Datos del e2e: usuarios `e2e-493-ventas` y `e2e-493-cliente` (DNI 99994931 y 99994932, contraseña `VentasE2e123`), series `BZ91`, `BZ92`, `BZ93`, `FZ91` y `FZ92`. Si al empezar hay series activas ajenas a la suite, se desactivan y se reactivan en el `afterAll`; las series y usuarios de la suite se borran. Comprobado tras la corrida: 0 filas en `commerce.serie_comprobante` y 0 personas con DNI `9999493%`.

## Verificación

Ejecutado el 2026-10-17 sobre la rama sin commit, con la BD local `francos-db-pg16`:

- [x] `pnpm build`: exit 0.
- [x] `pnpm lint:check`: exit 0, 0 errores y 0 warnings.
- [x] `prettier --check` sobre los 33 `.ts` nuevos o modificados: "All matched files use Prettier code style!". El `pnpm format:check` global no se usó porque falla en local por CRLF en archivos preexistentes. El bloque nuevo de `schema.prisma` coincide con `prisma format`; el `--check` global de Prisma ya fallaba en `origin/develop` y no es una puerta del CI.
- [x] `pnpm test`: 65 suites, 344 tests, todos en verde. De ellos, 6 suites y 36 tests son de `sales`.
- [x] `pnpm test:e2e --ci --runInBand`, con las variables falsas de `ci.yml` exportadas en el proceso:
  - **1.ª corrida:** 10/11 suites y 148/192 tests. Falló solo `catalogo.e2e-spec.ts`, en su `beforeAll`: FK `fk_user_persona` al borrar una persona con DNI 99999995/99999996. Esos DNI los comparte con `objetivo-estrategico.e2e-spec.ts` y ninguno es de esta suite. Eran datos que quedaron de una corrida anterior; la propia corrida los limpió.
  - **2.ª corrida:** 11/11 suites y 192/192 tests. La suite nueva sola da 31/31.
  - **3.ª corrida, tras las correcciones de la verificación:** 11/11 suites y 202/202 tests. La suite nueva sola da 41/41. Al terminar, 0 filas en `commerce.serie_comprobante` y 0 personas con DNI `9999493%`.
- [x] Repetido tras las correcciones: `pnpm lint:check` exit 0; `prettier --check` sobre los 33 `.ts` del diff: "All matched files use Prettier code style!"; `pnpm build` exit 0; `pnpm test` 65 suites y 344 tests en verde; `git diff --check` exit 0.
- [x] `docker build`: exit 0. Smoke con las variables de CI en el puerto 3093:
  - `/api/v1/health/live` → `{"status":"ok"}` y `/api/docs` → 200.
  - Swagger expone las 4 rutas de `series-comprobante`.
  - `GET /api/v1/series-comprobante` sin token → 401.
- [x] `pnpm exec prisma migrate deploy`: aplicó `20261017120000_add_serie_comprobante`. `prisma migrate status`: "Database schema is up to date!". `prisma generate`: OK.
- [x] `git diff --check`: exit 0.
- [x] Sin `.env`, secretos, `dist/`, caches ni logs en el diff. `.env` y `dist/` siguen ignorados. `gitleaks dir` sobre los archivos nuevos: "no leaks found".

No ejecutado y por qué:
- `migrate dev`: la BD local tiene aplicada la migración de OFT0-473, que no está en esta rama, y detectaría deriva. El SQL se generó con `prisma migrate diff --from-schema <schema de origin/develop> --to-schema prisma/schema.prisma --script`, y a mano se añadieron el índice parcial y los CHECK.
- El contenedor del smoke, `smoke-oft0-493` (`--rm`, puerto 3093), quedó corriendo porque `docker stop` estaba denegado. Hay que pararlo con `docker stop smoke-oft0-493`. Queda también la imagen local `francos-backend:oft0-493`.

## Riesgos

- **Conflicto en `schema.prisma` con el PR #38.** Si se fusiona primero el #38, hay que actualizar esta rama; las migraciones tienen timestamps distintos y ordenados.
- **El texto de RN23 puede contradecir el formato o el rango asumidos.**
- **El 1 SP es poco para el alcance real.** Es solo informativo; no se toca Jira.
- **Las contraseñas de prueba del e2e pueden disparar gitleaks** (pasó en el PR #39). Hay que reutilizar credenciales cortas, como `VentasE2e123`, o anotar las huellas en `.gitleaksignore`. *Mitigado:* se usan solo `VentasE2e123` y `admin123`, y `gitleaks dir` no encontró fugas.
- **Huecos al emitir (OFT0-541).** La reserva se confirma en su propio statement. Si la emisión falla después, el número queda consumido. Si OFT0-541 necesita reservar y emitir en la misma transacción, habrá que añadir una variante que reciba el cliente transaccional.
- **El e2e toca series ajenas:** si en la BD hay series activas que no son de la suite, las desactiva mientras corre y las reactiva al final, lo que cambia su `updated_at`. Si la suite se interrumpe a mitad, quedan inactivas.
- **El e2e de `catalogo` es frágil:** comparte DNIs con `objetivo-estrategico` (99999995/6), lo que es preexistente y no es de esta incidencia.

## Entrega

| | |
| --- | --- |
| PR | [#40](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/40) → `develop`, commits `d7d1cb3` + `43a0ef7` |
| Estado del CI | verde: build, lint, test-unit, test-e2e, docker, security (run `39079019860`). El primer run falló en security porque gitleaks escanea todas las ramas y encontró las contraseñas de prueba de `3b2a85f` (PR #39); se replicó en esta rama el bloque de `.gitleaksignore` del #39, idéntico |
| Jira | *En curso* (comentario `10087`), luego *En revisión* (comentario `10088`, PR) |

### Actualización 2026-10-18

- `develop` trajo Pedido (#43) y KPI (#44, #45). Merge de develop en la rama: commit `412d6c1`. Se unificó el módulo `sales` (schema, entities, enums, errors, `sales.module.ts`).
- La migración se renombró de `20261017120000_add_serie_comprobante` a `20261018120000_add_serie_comprobante` para quedar después de `20261018000000_mover_tablas_kpi_a_schema_strategic`.
- 2026-10-18 (2): tras el merge de #50 (reembolsos) se volvió a renombrar a `20261018170000_add_serie_comprobante`, para quedar después de `20261018161423_add_reembolso`. Merge `d69bdf8`; e2e en BD limpia 323/323, sin deriva.
- Verificación sobre una base limpia: build, lint, 479 unitarias y 255 e2e en verde; `migrate diff`: "No difference detected". CI verde, run 39101889854.
- Quien ya aplicó la migración con el nombre viejo (mi base local) tendrá en `_prisma_migrations` un registro que ya no existe en la rama.
