# OFT0-557 — HU-B-014 Solicitar reembolso

> **Regla de esta ficha:** separa siempre lo que **verificaste** de lo que
> **supones**. Todo hecho lleva evidencia (`archivo:línea`, commit o salida de
> comando). Un supuesto sin confirmar nunca se escribe como hecho.

## Identificación

| | |
| --- | --- |
| Subtarea backend | `OFT0-557` |
| HU padre | `OFT0-302` — HU-B-014 Solicitar reembolso (8 SP, RN9/RN19/RN20) |
| Sprint | Sprint 2 |
| Rama | `feature/OFT0-557-solicitar-reembolso` |
| Base | `develop` `326f1ed` + merge de `feature/OFT0-529` (`0bd14cc`, PR #53) → `054f895` |
| Fecha de auditoría | 2026-10-18 |

> La rama incluye #53 a propósito: reutiliza la consulta User→Persona→Cliente.
> Cuando #53 se fusione, el diff del PR queda solo con lo de reembolsos. **No
> mergear este PR antes que #53.**

## Texto de la HU (Jira, 2026-10-18)

> Como cliente, quiero solicitar el reembolso de un pedido pagado registrando
> obligatoriamente el motivo, solo cuando el pedido se encuentre en estado
> "Entregado", "Confirmado" o "Cancelado" y no cuente ya con una solicitud
> registrada, quedando mi solicitud en estado pendiente hasta la aprobación del
> administrador, consultar el estado de mi solicitud (Pendiente, Aprobado,
> Rechazado, Reembolsado) desde mi historial de pedidos, y ser notificado cuando
> esta sea aprobada o rechazada.

RF-B38 estados permitidos · RF-B39 motivo obligatorio, nace pendiente · RF-B40 una
por pedido · RF-B41 consultar estado · RF-B42 notificar al aprobar/rechazar.
Bloqueada por OFT0-296 (pago en línea, Piero Lanche, Por hacer).

## Criterios de aceptación descompuestos

| # | Criterio | Origen | Estado en develop | Evidencia |
| --- | --- | --- | --- | --- |
| CA-1 | `POST /portal/reembolsos` solo rol `cliente`; 401 sin token, 403 otros roles | DoD | ausente | sin `@Roles('cliente')` en develop; `roles.guard.ts:40-46` |
| CA-2 | Cliente sale del JWT (User→Persona→Cliente); pedido inexistente o de otro cliente → 404 | RF-B39 | ausente | helper en #53; propiedad por `pedido.cliente_id`, **no** `pedido.user_id` (`create-pedido.use-case.ts:51`) |
| CA-3 | El pedido debe tener `Pago` (pagado); si no → 409 | RF-B39 | ausente | `Pago` 1:1 `uq_pago_pedido` |
| CA-4 | Pedido en `entregado`, `confirmado` o `cancelado`; otro estado → 409 | RF-B38 | ausente | enum `schema.prisma:106-117`; `cancelado` hoy no se alcanza (`transiciones-pedido.ts:6-10`) |
| CA-5 | `motivo` (obligatorio) + `descripcion` (obligatoria, ≥10 car. como el front) → se guardan en `motivo_cliente` como `"<motivo>: <descripcion>"`; vacío tras trim → 400 | RF-B39, D-3 | ausente | `migration.sql:13` NOT NULL |
| CA-6 | Evidencia **obligatoria**: multipart `evidencia`, PDF/JPG/PNG/WEBP, ≤5 MB; falta o inválida → 400 | D-1, D-2 | ausente | aprobar exige evidencia: `aprobar-reembolso.use-case.ts:39-43` |
| CA-7 | Se sube a bucket `docs` con key `reembolsos/<codigo>/<archivo-saneado>`; si el insert falla, se borra el objeto | D-2 | ausente | key: `reembolso.presenter.ts:7`; `s3.service.ts:59-81` |
| CA-8 | Nace en `pendiente`; `monto` = `pago.monto` calculado en servidor | RF-B39 | parcial (default BD) | `migration.sql:12,15` |
| CA-9 | `codigo` único `SOL-000001` generado en servidor (secuencia/nextval como pedido) | — | ausente | solo en seed `demo-reembolsos.seed.ts:119-120`; patrón `prisma-pedido.repository.ts:101-111` |
| CA-10 | Una sola solicitud por pedido → 409, también en carrera (P2002 de `uq_reembolso_pago` → 409, no 500) | RF-B40 | parcial | `migration.sql:30`; filtro sales no traduce P2002 |
| CA-11 | `GET /portal/reembolsos` lista paginada de las propias (filtro `estado`) | RF-B41 | ausente | solo staff: `reembolsos.controller.ts:45-74` |
| CA-12 | `GET /portal/reembolsos/:id` detalle propio con URL firmada de la evidencia y `motivo_rechazo`; ajeno → 404 | RF-B41 | ausente | — |
| CA-13 | Notificación al aprobar/rechazar se guarda para el usuario del cliente | RF-B42 | cubierto (escritura) | `prisma-reembolso.repository.ts:157-168` |
| CA-14 | Pruebas unitarias + e2e (401/403/400/404/409/201, carrera, limpieza S3 con fake) | DoD | ausente | `test/fake-s3.service.ts` |

## Decisiones tomadas (usuario, 2026-10-18)

- **D-1** Evidencia obligatoria (respeta la regla de aprobar de #50).
- **D-2** Subida multipart al backend con `FileInterceptor` (patrón de productos / documentos estratégicos).
- **D-3** Un solo campo `motivo_cliente`, sin migración.
- **D-4** Controlador propio `portal/reembolsos`, `@Roles('cliente')`.
- **D-5** Rama sobre #53 para reutilizar la consulta de cliente.

## Hechos auditados

Ver tabla. Además: no hay controller de notificaciones ni correo (lectura de
notificaciones es otra HU); historial de pedidos del cliente es HU-B-011 (OFT0-299,
sin asignar); el front Next (ref local `origin/feature/Perfil-y-solicitudes`
`8c1029a`, posiblemente desactualizada) manda `motivo` + `descripcion`, sin archivo,
y apunta a `POST /solicitudes-reembolso`.

## Supuestos

- **S-1** Monto = total del pago, sin parciales. · *Confirma:* PO (Andres Chavarri).
- **S-2** Sin plazo máximo (RN19/RN20 no legibles). · *Confirma:* PO.
- **S-3** "Pagado" = existe `Pago`. · *Confirma:* Piero Lanche / PO.
- **S-5** Lectura de notificaciones es otra HU. · *Confirma:* PO / SM.

## Decisiones de implementación (2026-10-18)

- **I-1 Código SOL.** `reservarCodigo()` hace `nextval(pg_get_serial_sequence('commerce.reembolso','id'))`
  igual que `prisma-pedido.repository.ts:101-111` y que el seed (`demo-reembolsos.seed.ts:186-189,317`).
  Se reserva **antes** de subir la evidencia (la key lleva el código) y fuera de una
  transacción: `nextval` no se deshace, así que un id reservado nunca se reutiliza.
  El insert usa ese id explícito. Sin migración.
- **I-2 Orden.** reservar código → subir a S3 → insertar. Si el insert falla por
  cualquier motivo se borra el objeto (best-effort: si el borrado también falla se
  registra un `warn` y se responde con el error original).
- **I-3 P2002.** Se traduce en `PrismaReembolsoRepository.crearSolicitud` a
  `ResourceConflictError` (409). Cualquier P2002 de ese insert se trata como
  "solicitud duplicada": `uq_reembolso_codigo` no puede chocar porque el id sale de
  la secuencia.
- **I-4 Tamaño.** El validador de `ParseFilePipe` responde 400 por encima de 5 MB.
  Multer tiene un tope duro de 10 MB para no cargar archivos enormes en memoria:
  por encima de 10 MB la respuesta es **413** (no 400).
- **I-5 Tipo.** `FileTypeValidator` de Nest 11.1.28 valida por *magic number*
  (paquete `file-type`), no por el `Content-Type` del cliente: un texto renombrado a
  `.pdf` da 400.
- **I-6 Nombre del archivo.** Se sanea (`nombreArchivoEvidencia`): sin rutas, sin
  tildes, solo `[A-Za-z0-9._-]`, máx. 100 caracteres; si no queda nada,
  `evidencia.<ext>`. `FileInterceptor` usa `defParamCharset: 'utf8'` para que los
  nombres con tildes no lleguen como latin1.
- **I-7 Consultas.** `GET` lista/detalle exigen que el usuario tenga Cliente (404 si
  no); un cliente **inactivo sí puede consultar** (solo se le bloquea solicitar, 409).
- **I-8 Respuesta del portal.** Presenter propio `ReembolsoPortalPresenter`: id,
  codigo, pedido {id, codigo}, monto, estado, fechas, motivo_cliente,
  motivo_rechazo, evidencia {nombre, url firmada}. No expone `resuelto_por`, nombre
  del cliente ni método de pago.
- **I-9 Contrato ampliado.** `EvidenciaReembolsoService` suma `subir` y `borrar`. El
  doble `FakeEvidenciaReembolso` de `test/reembolsos.e2e-spec.ts` recibió dos stubs
  vacíos para seguir cumpliendo el contrato (único cambio fuera de lo nuevo).
- **Versiones consultadas** (de `node_modules`, Context7 no disponible en esta
  sesión): `@nestjs/common` y `@nestjs/platform-express` 11.1.28, multer 2.2.0,
  `@prisma/client` 7.8.0, jest 30.4.2.

## Decisiones pendientes

- **D-6** ¿Se cierra la HU sin historial (HU-B-011)? Se entrega `GET /portal/reembolsos` como consulta. · *Decide:* PO · *Bloquea:* no.
- Ruta y campo archivo en el front. · *Decide:* frontend · *Bloquea:* no.

## Fuera de alcance

- Leer notificaciones, correo.
- Historial de pedidos del cliente (HU-B-011) y cancelar pedidos (HU-B-012).
- Cambios en el lado staff (#50) y en el front.
- Reembolsos parciales, plazos.

## Plan técnico

| Capa | Archivos |
| --- | --- |
| `domain` | `reembolso.repository.ts`: `crearSolicitud`, `listarDeCliente`, `obtenerDeCliente`; tipos; `EvidenciaReembolsoService.subir/borrar` |
| `application` | DTOs `solicitar-reembolso.dto.ts`, query de listado; casos de uso `solicitar-reembolso`, `list-mis-reembolsos`, `get-mi-reembolso` + specs |
| `infrastructure` | `prisma-reembolso.repository.ts` (nextval + insert en transacción, P2002 → error de dominio); `s3-evidencia-reembolso.service.ts` |
| `presentation` | `controllers/portal-reembolsos.controller.ts`; `sales.module.ts` |

## Autorización de endpoints

| Endpoint | Método | Roles |
| --- | --- | --- |
| `/api/v1/portal/reembolsos` | POST (multipart) | `cliente` |
| `/api/v1/portal/reembolsos` | GET | `cliente` |
| `/api/v1/portal/reembolsos/:id` | GET | `cliente` |

## Migraciones

Ninguna prevista. Si hace falta secuencia para `codigo` y no existe, se evalúa
`nextval` sobre la secuencia del id o una migración mínima (reportar antes).

## Dependencias con el frontend

Avisar al front Next: ruta `/portal/reembolsos`, multipart con `evidencia`
obligatoria, estado `reembolsado`.

## Plan de pruebas

| Prueba | Tipo | Archivo | Estado |
| --- | --- | --- | --- |
| Solicitar: éxito, orden reservar→subir→insertar, monto = pago.monto, `motivo: descripcion`, estados confirmado/cancelado, 404 sin cliente / pedido inexistente / ajeno, 409 inactivo / sin pago / 4 estados no permitidos / duplicado, borrado de S3 si el insert falla (409 y error genérico), error original si el borrado falla, sin insert si la subida falla | unitaria (18) | `src/modules/sales/application/use-cases/reembolso/solicitar-reembolso.use-case.spec.ts` | pasa |
| Listar / detalle propios, 404 sin cliente, 404 ajena, sin evidencia | unitaria (6) | `.../reembolso/consultas-mis-reembolsos.use-case.spec.ts` | pasa |
| `formatCodigoReembolso`, saneado del nombre, key | unitaria (7) | `src/modules/sales/application/utils/reembolso.utils.spec.ts` | pasa |
| `reservarCodigo` (nextval), P2002 → `ResourceConflictError`, otros errores pasan | unitaria (3) | `src/modules/sales/infrastructure/repositories/prisma-reembolso.repository.spec.ts` | pasa |
| 401, 403 admin/ventas, 400 (sin archivo, GIF, texto como PDF, >5 MB, motivo vacío/ausente, descripción corta, pedido_id no numérico), 404 (ajeno, inexistente, sin cliente), 409 (inactivo, sin pago, en camino, duplicado), 201 con `SOL-xxxxxx` y evidencia en fake S3, PNG en pedido confirmado, carrera de 2 POST simultáneos (201 + 409, sin huérfanos en S3), listado y detalle solo propios, filtro estado, ventas aprueba la solicitud creada y el cliente la ve aprobada con notificación | e2e (32) | `test/portal-reembolsos.e2e-spec.ts` | pasa |

La carrera e2e no fuerza qué rama gana (pre-chequeo `tiene_reembolso` o P2002);
la rama P2002 queda cubierta de forma determinista por el unitario del repositorio.

## Verificación

Ejecutado el 2026-10-18 en la rama `feature/OFT0-557-solicitar-reembolso` contra
PostgreSQL local (`francos-db-pg16`). Logs en el scratchpad de la sesión.

- [x] `pnpm build` → exit 0
- [x] `pnpm lint:check` → exit 0, sin warnings
- [x] `pnpm exec prettier --check` sobre los 20 archivos tocados → "All matched files use Prettier code style!"
- [ ] `pnpm format:check` → exit 1 por **145 archivos ajenos** con CRLF en el worktree
  (`core.autocrlf=true`; p. ej. `production.module.ts` es `i/lf w/crlf`). Ninguno es de
  esta incidencia; en CI (checkout LF) no aplica. No se tocaron.
- [x] `pnpm test` → 90 suites, 584 tests, todos pasan
- [x] `pnpm test:e2e --ci --runInBand` (con las variables de CI) → 18 suites, 334 tests, todos pasan
- [ ] `docker build` + smoke → no ejecutado
- [x] `pnpm exec prisma migrate status` → 28 migraciones, "Database schema is up to date!"
- [x] `git diff --check` → sin salida
- [x] Limpieza e2e: 0 pedidos `PED-E2E-SR%`, 0 personas 99999941-45, 0 reembolsos de pedidos `PED-E2E%`
- [x] Sin `.env`, secretos, `dist/`, caches ni logs en el diff

## Riesgos

- Huérfanos en S3 si falla el insert (se compensa con delete).
- Conflictos en `sales.module.ts` con #40/#49.
- Sin pedidos reales del portal ni cancelados: pruebas con datos sembrados.

## Entrega

| | |
| --- | --- |
| PR | [#55](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/55) · commits `175cbb6`, `7fb4440` (depende de #53) |
| Estado del CI | 6/6 verde (build, lint, test-unit, test-e2e, docker, security) |
| Jira | comentado (10100 inicio, 10101 PR) · transicionado a En revisión |

## Actualización 2026-10-24 — develop y #53 al día

- Merge `be4a0f0` de la rama del #53 (que ya trae develop `33a5559`, PRs #57 a #70), sin conflictos; el merge de develop posterior: "Already up to date".
- No trae migraciones, schema ni seeds (`git diff origin/develop...HEAD -- prisma/` vacío): el aviso de datos de referencia como migración no le aplica.
- **Verificado en local** (Postgres 16 desechable): build, `lint:check`, prettier del diff, 955/955 unitarias, `migrate deploy` + seed sin deriva, e2e 595/595 con `--runInBand --testTimeout=60000`.
- **Revisión `backend-reviewer`:** listo para push. Develop no cambia Pedido/Pago/Reembolso ni añade métodos abstractos en sales; #64 (cerrar sesión) exige `sid` en el JWT y los e2e del PR usan login real, así que siguen válidos; solo hay dos rutas `portal/*`, sin solapes.
- **Entrega:** push `7fb4440..be4a0f0`; CI del PR #55 6/6 en verde.
- 2026-10-25: merge `5b3a1db` de la rama del #53 ya resuelta (develop `868c900`, con #49), sin conflictos. Local: 1094/1094 unitarias, `migrate deploy` + seed, e2e 679/679 (`--testTimeout=60000`). CI 6/6. Push `be4a0f0..5b3a1db`.
- **Hallazgo ajeno:** `migrate diff` da deriva en `inventory.movimiento_insumo` (índice sobre `lote_insumo_id` y default de `codigo`), que entró con el #73 (JoelRM1408). Este PR no toca `prisma/` (`git diff origin/develop...HEAD -- prisma/` vacío). El CI solo corre `migrate deploy`, así que no bloquea; avisar a Joel. Sigue dependiendo del #53: se fusiona primero el #53.
