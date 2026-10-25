# OFT0-485 — HU-A-042 Gestionar usuario interno

> **Regla de esta ficha:** separa siempre lo que **verificaste** de lo que
> **supones**. Todo hecho lleva evidencia (`archivo:línea`, commit o salida de
> comando). Un supuesto sin confirmar nunca se escribe como hecho.

## Identificación

| | |
| --- | --- |
| Subtarea backend | `OFT0-485` |
| HU padre | `OFT0-284` — HU-A-042 Gestionar usuario interno (2 SP) |
| Épica | `OFT0-316` — Módulo de Configuración del Sistema |
| Sprint | Sprint 2 (id 208, `future`, 2026-09-28 → 2026-10-09: fechas vencidas) |
| Rama | `feature/OFT0-485-gestionar-usuario-interno` |
| Commit base de `develop` | `4157aa8` (merge PR #37) |
| Fecha de auditoría | 2026-10-17 |

Fuente del alcance: campo "Criterio de Aceptacion" (`customfield_10146`) de
OFT0-284, con 7 requisitos (RF-A178 a RF-A184), más la DoD Backend. Sin
comentarios, sin issuelinks. Hermanas: OFT0-484 (prototipo, no aprobado),
OFT0-486 (frontend), OFT0-487 (QA), todas "Por hacer".

## Criterios de aceptación descompuestos

| # | Origen | Criterio | Estado en `develop` | Evidencia |
| --- | --- | --- | --- | --- |
| CA-1 | RF-A178 | Admin crea usuario interno con nombres, apellidos, documento, email, username, contraseña, rol(es) y estado. Crea persona + user + usuario_rol; contraseña con bcrypt | parcial | `register/empleado` impone username = contraseña = DNI (`src/modules/auth/application/utils/default-credentials.util.ts:19,27`; `register-empleado.use-case.ts:57-59`) |
| CA-1a | RF-A178 + DoD | 409 email/username/documento duplicado; 404 rol inexistente; 409 rol inactivo; 400 datos inválidos (email con `@IsEmail`) | parcial | `register-empleado.use-case.ts:33-54`; email solo `@IsString` (`register-empleado.dto.ts:83-87`) |
| CA-1b | derivado | El usuario creado inicia sesión con el username y contraseña elegidos; si `estado=false`, no | no verificable | no hay alta con credenciales elegidas; login mira `user.estado` (`login.use-case.ts:35`) |
| CA-2 | RF-A179 | Admin edita username, nombres, apellidos y contraseña. Username único (409). Contraseña con hash | parcial | `PATCH /personas/:id` solo datos de persona (`personas.controller.ts:67`); `UpdateUserDto` sin uso |
| CA-3 | RF-A180 | Admin desactiva y reactiva un usuario (`user.estado`). Desactivado no inicia sesión ni refresca | ausente | `UserRepository.setStatus` existe (`prisma-user.repository.ts:68-74`) sin endpoint; `DELETE /empleados/:id` no afecta al login |
| CA-4 | RF-A181 | Admin asigna, cambia y quita roles (`usuario_rol`); mínimo un rol activo. Permisos derivan del rol | ausente (usuario) / cubierto (rol↔ruta) | `UsuarioRolRepository` sin controller (`usuario-rol.repository.ts:7-14`); `accesos.controller.ts:24-47` |
| CA-5 | RF-A182 | `GET` paginado (page/limit, meta total/total_pages) de solo usuarios internos | ausente | `UserRepository` sin `findMany` (`user.repository.ts:7-21`) |
| CA-6 | RF-A183 | Búsqueda por nombre/apellidos/username/email y filtros por rol y estado | ausente | sin listado de usuarios |
| CA-7 | RF-A184 | Usuario autenticado ve sus datos personales y roles | parcial (casi cubierto) | `GET /auth/me` (`auth.controller.ts:64-74`); roles salen del JWT (`:72`) |
| CA-8 | seguridad | CA-1..CA-6 solo `admin`; ninguna respuesta expone contraseña, hash ni tokens | no aplica aún | convención `@Roles('admin')` (`empleados.controller.ts:33`); `UserEntity` lleva contraseña (`user.entity.ts:7-14`) |
| CA-9 | decisión | Autoprotección: un admin no se desactiva a sí mismo, no se quita `admin`, y nunca quedan 0 admins activos (409) | ausente | nada lo impide hoy |
| CA-10 | decisión | Desactivar o cambiar la contraseña revoca todos los refresh tokens del usuario | ausente | `RefreshTokenRepository` sin "revocar todos" (`refresh-token.repository.ts:4-12`); patrón en `prisma-password-reset.repository.ts:51-54` |
| CA-11 | DoD | Pruebas unitarias y e2e que pasen las 5 puertas | ausente | sin specs de usuarios |

## Hechos auditados

- **Hecho:** OFT0-485 es Subtask "Desarrollar backend" asignada a Ruben, parent OFT0-284 · *Evidencia:* `getJiraIssue OFT0-485` (2026-10-17).
- **Hecho:** no depende de `Pedido` · *Evidencia:* `git grep "model Pedido" origin/develop -- prisma/schema.prisma` → exit 1.
- **Hecho:** `Persona` exige `tipo_documento`, `numero_documento` (único), `apellido_paterno` y `apellido_materno` · *Evidencia:* `prisma/schema.prisma:102-106`.
- **Hecho:** el modelo ya soporta N roles por usuario (`uq_usuario_rol`) y refresh tokens · *Evidencia:* `prisma/schema.prisma:152-250`.
- **Hecho:** la estrategia JWT no consulta la BD; el access token dura 40 min por defecto; el refresh sí comprueba `user.estado` · *Evidencia:* `jwt.strategy.ts:30-32`, `src/config/envs.ts:33`, `refresh-token.use-case.ts:37`.
- **Hecho:** guards globales y deny-by-default · *Evidencia:* `auth.module.ts:55-62`, `roles.guard.ts:40-42`.
- **Hecho:** seed con admin `admin`/`admin123` y rol `admin` · *Evidencia:* `prisma/seeds/admin.seed.ts:6-7,37`, `roles.seed.ts:4`.
- **Hecho:** el frontend Angular consume `GET /auth/me` y tiene un `UsuarioDto` especulativo (id number, estado string) que no coincide con el backend · *Evidencia:* `Proyecto-Aura/frontend-angular-francos@982446f` `src/app/modules/auth/interfaces/usuario-dto.interface.ts:7-15,36-44`.
- **Hecho:** no hay rama ni PR previo · *Evidencia:* `gh pr list --state all --search "OFT0-485"` → `[]`.

## Supuestos

- **Supuesto:** "apellidos" = apellido paterno + materno · *Confirma:* PO (Andres Chavarri).
- **Supuesto:** los "permisos de acceso" de RF-A181 derivan del rol (`acceso` rol↔ruta), no son por usuario · *Confirma:* PO.
- **Supuesto:** solo `admin` gestiona usuarios ("Como administrador") · *Confirma:* PO.
- **Supuesto:** el frontend de OFT0-486 se adaptará al contrato `/usuarios` que defina el backend · *Confirma:* responsable de OFT0-486.
- **Supuesto:** el usuario creado por el admin queda con `debe_cambiar_contrasena = true` si el campo existe, y sin correo de verificación · *Confirma:* PO.

## Decisiones

Tomadas por el usuario el 2026-10-17:

- **D1 Documento:** el alta pide tipo y número de documento y los dos apellidos. **Sin migración.**
- **D2 Usuario interno:** todo `User` con al menos un rol distinto de `cliente`.
- **D3 Alta:** `POST /usuarios` nuevo con username y contraseña elegidos por el admin. `register/empleado` no se toca.
- **D5/D6 Seguridad:** autoprotección completa (CA-9) y revocación de refresh tokens al desactivar o cambiar contraseña (CA-10). El access token vigente sigue válido hasta su expiración (≤ 40 min).

Tomadas por defecto (conservadoras, sin bloquear):

- **D4:** varios roles por usuario (`rol_ids`, mínimo uno). No se permite asignar el rol `cliente` a un usuario interno.
- **D7:** el email no se edita (RF-A179 no lo incluye).
- **D8:** `GET /auth/me` no se toca.
- **D9:** no se siembra ruta de menú.

Tomadas al implementar (2026-10-17, conservadoras; revisables por Ruben/PO):

- **I1 Repositorio propio:** en vez de ampliar `UserRepository` y `UsuarioRolRepository` (que usa `auth`), se crea `UsuarioInternoRepository` en `persons`, que opera sobre persona + user + usuario_rol + refresh_token. Mismo enfoque que `RegistroRepository` de `auth` para escrituras de varias tablas.
- **I2 Revocación de refresh tokens:** se hace dentro de la transacción de `PrismaUsuarioInternoRepository` con `tx.refreshToken.updateMany` (patrón de `prisma-password-reset.repository.ts:51-54`). No se importa `RefreshTokenRepository` de `auth`: `AuthModule` ya importa `PersonsModule`, y lo contrario crearía un ciclo.
- **I3 Hash:** se reutiliza `hashPassword` de `src/modules/auth/application/utils/password.util.ts` (bcrypt, 10 rondas). Es una función pura; `persons` ya importaba decoradores de `auth`, así que no se añade dependencia de módulo Nest.
- **I4 "Interno":** al menos una fila `usuario_rol` con `estado = true` y rol de nombre distinto de `cliente`. El `estado` del rol no cuenta (si se desactiva un rol, sus usuarios no desaparecen del listado).
- **I5 Roles en `PUT /usuarios/:id/roles`:** reemplazo completo. Los roles que salen quedan con `usuario_rol.estado = false` (no se borran); los que entran se crean o reactivan (`upsert` sobre `uq_usuario_rol`). Una asignación previa a `cliente` no se toca. Cambiar roles **no** revoca tokens: el refresh relee los roles de la BD (`refresh-token.use-case.ts:41`).
- **I6 Rol `cliente`, rol inactivo:** 409; rol inexistente: 404 (mismas reglas que `register-empleado.use-case.ts:47-54`).
- **I7 Filtro `rol`:** por **nombre** del rol (`?rol=ventas`, sin distinguir mayúsculas). `search` busca en nombres, ambos apellidos, username y email.
- **I8 Username:** `^[a-zA-Z0-9._-]{3,50}$`. Sin `@`, para que un username nunca coincida con un email en el login (que busca por cualquiera de los dos). Contraseña: 8-255 caracteres, como `reset-password.dto.ts`.
- **I9 Alta:** `debe_cambiar_contrasena = true` (el campo existe: `schema.prisma`, modelo `User`), `email_verificado = false`, sin token ni correo de verificación (no hay endpoint de verificación en el repo). No se crea perfil `Empleado`.
- **I10 Cambio de contraseña por el admin:** revoca refresh tokens; **no** cambia `debe_cambiar_contrasena` (ver pendientes).
- **I11 Autoprotección "último admin":** cuenta usuarios activos con `usuario_rol` activo al rol `admin` activo, excluido el afectado. Se comprueba solo si el afectado es admin y está activo. Reactivar no tiene reglas.
- **I12 Respuesta:** objeto plano (`id` = id del user, `persona_id`, nombres, apellidos, documento, email, username, estado, email_verificado, debe_cambiar_contrasena, `roles: [{id, nombre}]`, fechas). Sin contraseña, hash ni `token_*`.

Pendientes (no bloquean):

- **Decisión:** aprobación del prototipo OFT0-484 (la DoD lo pide antes de desarrollar) · *Decide:* PO · *Bloquea:* no para el backend.
- **Decisión:** corte inmediato de sesión (comprobar `estado` en cada request) · *Decide:* Ruben + PO · *Bloquea:* no.
- **Decisión:** si al cambiar el admin la contraseña de otro usuario debe forzarse `debe_cambiar_contrasena = true` (hoy no se toca, I10) · *Decide:* PO · *Bloquea:* no.
- **Decisión:** cómo verifica su email un usuario creado por el admin (no hay endpoint de verificación; queda `email_verificado = false`, I9) · *Decide:* PO · *Bloquea:* no.

## Alcance

CA-1, CA-1a, CA-1b, CA-2, CA-3, CA-4, CA-5, CA-6, CA-8, CA-9, CA-10, CA-11.

## Fuera de alcance

- Cambios en `POST /auth/register/empleado` y en `GET /auth/me` (CA-7 se da por cubierto con lo existente).
- Permisos por usuario individual.
- Edición del email.
- Corte inmediato del access token (estrategia JWT).
- Ruta de menú y seed.
- Perfil `Empleado` (cargo, área): no se crea al dar de alta un usuario interno.
- Frontend (OFT0-486).

## Plan técnico

Controller nuevo en `persons`. Sin migración.

| Capa | Archivos |
| --- | --- |
| `domain` | `UserRepository` (+ listado de internos con persona y roles, + búsqueda por id con persona y roles, + alta en transacción persona+user+roles), `UsuarioRolRepository` (+ reemplazar roles en transacción, + contar admins activos), puerto para revocar refresh tokens, tipos |
| `application` | DTOs `create-usuario-interno`, `update-usuario-interno`, `list-usuarios-internos-query`, `set-roles-usuario`; casos de uso crear, listar, obtener, actualizar, cambiar estado, asignar roles |
| `infrastructure` | `prisma-user.repository.ts`, `prisma-usuario-rol.repository.ts`, revocación de refresh tokens |
| `presentation` | `usuarios-internos.controller.ts` (`@Controller('usuarios')`, `@Roles('admin')`), `usuario-interno.presenter.ts` (sin contraseña ni tokens), `persons.module.ts` |

### Implementado (2026-10-17)

Raíz: `C:\Users\markp\Desktop\PY-MEGATRON\PY - PERFIL DE EGRESO -DEV\backend-monolito-francos`. El plan se ajustó con I1 (repositorio propio en vez de ampliar `UserRepository`/`UsuarioRolRepository`).

| Capa | Archivo | Estado |
| --- | --- | --- |
| `domain` | `src\modules\persons\domain\repositories\usuario-interno.repository.ts` | nuevo |
| `domain` | `src\modules\persons\domain\repositories\types\usuario-interno-repository.types.ts` (`UsuarioInterno`, params, `ROL_ADMIN`, `ROL_CLIENTE`) | nuevo |
| `application` | `src\modules\persons\application\dto\usuario-interno-dtos\create-usuario-interno.dto.ts` | nuevo |
| `application` | `src\modules\persons\application\dto\usuario-interno-dtos\update-usuario-interno.dto.ts` | nuevo |
| `application` | `src\modules\persons\application\dto\usuario-interno-dtos\list-usuarios-internos-query.dto.ts` | nuevo |
| `application` | `src\modules\persons\application\dto\usuario-interno-dtos\set-roles-usuario-interno.dto.ts` | nuevo |
| `application` | `src\modules\persons\application\use-cases\usuarios-internos\usuario-interno.rules.ts` (validación de roles, `tieneRolAdmin`) | nuevo |
| `application` | `...\usuarios-internos\create-usuario-interno.use-case.ts` | nuevo |
| `application` | `...\usuarios-internos\list-usuarios-internos.use-case.ts` | nuevo |
| `application` | `...\usuarios-internos\get-usuario-interno-by-id.use-case.ts` | nuevo |
| `application` | `...\usuarios-internos\update-usuario-interno.use-case.ts` | nuevo |
| `application` | `...\usuarios-internos\change-usuario-interno-status.use-case.ts` | nuevo |
| `application` | `...\usuarios-internos\set-usuario-interno-roles.use-case.ts` | nuevo |
| `infrastructure` | `src\modules\persons\infrastructure\mappers\usuario-interno.mapper.ts` | nuevo |
| `infrastructure` | `src\modules\persons\infrastructure\repositories\prisma-usuario-interno.repository.ts` | nuevo |
| `presentation` | `src\modules\persons\presentation\controllers\usuarios-internos.controller.ts` | nuevo |
| `presentation` | `src\modules\persons\presentation\presenters\usuario-interno.presenter.ts` | nuevo |
| `presentation` | `src\modules\persons\presentation\persons.module.ts` (+controller, +6 casos de uso, +provider del repositorio; no se exporta nada nuevo) | modificado |
| pruebas | 4 `*.use-case.spec.ts` en `...\usuarios-internos\`, `...\presenters\usuario-interno.presenter.spec.ts`, `test\usuarios.e2e-spec.ts` | nuevo |

Sin cambios en `schema.prisma`, migraciones, `auth`, `register/empleado` ni `/auth/me`.

Documentación: Context7 **no estaba disponible** en la sesión del agente. Se siguió el código del repo y las versiones instaladas (`node_modules`): `@nestjs/core` 11.1.28, `@nestjs/swagger` 11.4.5, `@prisma/client` 7.8.0, `class-validator` 0.15.1, `jest` 30.4.2. APIs usadas ya presentes en el repo (`$transaction` interactiva, `updateMany`, `upsert` por clave compuesta, `PartialType/PickType`, `ParseUUIDPipe`).

## Autorización de endpoints

| Endpoint | Método | Roles requeridos |
| --- | --- | --- |
| `/api/v1/usuarios` | POST | `admin` |
| `/api/v1/usuarios` | GET | `admin` |
| `/api/v1/usuarios/:id` | GET | `admin` |
| `/api/v1/usuarios/:id` | PATCH | `admin` |
| `/api/v1/usuarios/:id` | DELETE (desactivar) | `admin` |
| `/api/v1/usuarios/:id/activate` | PATCH | `admin` |
| `/api/v1/usuarios/:id/roles` | PUT | `admin` |

## Migraciones

Ninguna (D1).

**Aviso de entorno:** la BD local tiene aplicada la migración de OFT0-473
(`20261016210224_add_empresa_es_emisora`), que aún no está en `develop`. En esta
rama **no** ejecutar `prisma migrate dev`: detectaría deriva y pediría reset.

## Dependencias con el frontend

- **Contrato nuevo:** `/api/v1/usuarios/**` (ver I7 e I12: filtro `rol` por nombre; respuesta plana con `roles: [{id, nombre}]`; `id` = uuid del user). Avisar a quien lleve OFT0-486: el `UsuarioDto` especulativo del frontend Angular (id number, estado `'activo'|'inactivo'`) no coincide (id uuid, estado boolean).
- `GET /auth/me` sin cambios.

## Plan de pruebas

| Prueba | Tipo | Estado |
| --- | --- | --- |
| Crear: ok con hash (bcrypt verificado con `comparePassword`), `debe_cambiar_contrasena=true`, `estado=false` respetado; 409 username/email/documento; 404 rol; 409 rol inactivo; 409 rol `cliente` | unitaria (`create-usuario-interno.use-case.spec.ts`, 8) | pasa |
| Actualizar: 404; datos personales; 409 username en uso (con `excludeId`); no consulta si el username no cambia; contraseña hasheada | unitaria (`update-usuario-interno.use-case.spec.ts`, 5) | pasa |
| Estado: 404; desactiva a otro; 409 desactivarse a sí mismo; 409 último admin activo; permite si queda otro admin; reactivar sin reglas | unitaria (`change-usuario-interno-status.use-case.spec.ts`, 6) | pasa |
| Roles: 404; reemplaza; 404/409/409 rol inexistente/inactivo/cliente; 409 quitarse `admin`; conserva admin cambiando otros; 409 último admin; permite si queda otro; admin inactivo no exige otro | unitaria (`set-usuario-interno-roles.use-case.spec.ts`, 10) | pasa |
| Presenter: campos exactos; sin `contrasena`, `token_*`, hash ni valores de token; `meta` de paginación | unitaria (`usuario-interno.presenter.spec.ts`, 3) | pasa |
| Revocación de refresh tokens (vive en el repositorio Prisma) | e2e | pasa (ver abajo) |
| Regla I5: `PUT /usuarios/:id/roles` conserva una fila `usuario_rol` previa a `cliente` (creada por Prisma en el test) con `estado=true`; la de `ventas` sigue existiendo con `estado=false` (no se borra); la de `inventario` queda activa; 3 filas en total | e2e (`test/usuarios.e2e-spec.ts`, usuario `e2e-485-mixto`, DNI `99994856`) | pasa (añadido tras la verificación, 2026-10-17) |
| `/usuarios` (23 casos iniciales + 1 de I5 = 24): 401; 403 `ventas` en GET y POST; crear → 201 sin contraseña ni tokens y hash en BD; login con username y con email elegidos; 409 documento/email/username; 409 rol cliente; 404 rol inexistente; 400 email inválido, sin roles, username con `@`, contraseña corta, DNI mal formado, campo no permitido; `estado=false` → login 401; listado: no incluye clientes, `search`, `rol`, `estado`, búsqueda por apellido, paginación con `meta`; GET `:id` 200 y 404 para un cliente; PATCH username/nombres, 409 username duplicado, 400 al intentar editar email; PATCH contraseña → refresh previo 401, contraseña vieja 401, nueva 201; PUT roles reemplaza y el login refleja los roles nuevos, 409 cliente, 400 vacío; DELETE → login 401, refresh 401 y 0 refresh tokens vigentes en BD; `activate` → login 201; autoprotección: DELETE propio 409 y PUT quitándose admin 409 (admin sigue activo y con admin); 404 uuid inexistente; 400 id no uuid | e2e (`test/usuarios.e2e-spec.ts`) | pasa |
| "Último admin" en e2e | e2e | **no cubierto**: exigiría desactivar o quitar admin a todos los demás admins de la BD compartida. Cubierto solo en unitarias |

## Verificación

Ejecutado el 2026-10-17 en la rama `feature/OFT0-485-gestionar-usuario-interno` (base `4157aa8`), sin commit.

- [x] `pnpm build` → `nest build`, exit 0.
- [x] `pnpm lint:check` → 0 errores, 0 warnings (primera pasada: 4 errores `prettier/prettier` en archivos míos, corregidos con `prettier --write` solo sobre ellos).
- [ ] `pnpm format:check` → no ejecutado completo: falla en local por CRLF en archivos ajenos (preexistente, ya conocido). En su lugar: `pnpm exec prettier --check` sobre los 24 archivos del diff → "All matched files use Prettier code style!".
- [x] `pnpm test` → 64 suites, 340 tests, todos pasan.
- [x] `pnpm test:e2e --ci --runInBand` (variables ficticias del job `test-e2e` de `ci.yml` exportadas en el proceso, salvo `DATABASE_URL`, que sale del `.env` local) → 11 suites, 184 tests, todos pasan. Solo la suite nueva: 23/23. Re-ejecución tras añadir la prueba de I5: 11 suites, 185 tests, todos pasan; la suite nueva 24/24; `pnpm lint:check` exit 0; `prettier --check test/usuarios.e2e-spec.ts` OK; `git diff --check` exit 0; 0 restos `9999485%` / `e2e-485%` en BD. Tras la ejecución, 0 personas con DNI `9999485%` y 0 users `e2e-485%` en la BD local.
- [ ] `docker build` + smoke → no ejecutado (fuera de lo pedido al agente; lo cubre `/task-verify`).
- [x] `pnpm exec prisma migrate status` → "21 migrations found in prisma/migrations" y "Database schema is up to date!". **No** reportó la migración extra de OFT0-473 que se esperaba; se anota tal cual.
- [x] `git diff --check` → exit 0 (también con los archivos nuevos marcados intent-to-add). Sin espacios finales ni CRLF en los archivos nuevos.
- [x] Sin `.env`, secretos, `dist/`, caches ni logs en el diff (`git status --short`: 23 archivos nuevos en `src/modules/persons` y `test/`, 1 modificado).

No ejecutado y por qué: `docker build` + smoke (le toca a `/task-verify`); `pnpm format:check` completo (CRLF ajeno preexistente).

Aviso de índice: para que `git diff --check` cubriera los archivos nuevos se ejecutó `git add -N` (intent-to-add) sobre los 24 archivos `.ts` del diff. No añade contenido al índice ni crea commit, pero `git status` los muestra como ` A`. `/task-pr` hará el `git add` real.

## Riesgos

- Conflicto trivial en `src/modules/persons/presentation/persons.module.ts` con el PR #38 (OFT0-473), que también lo toca.
- El prototipo OFT0-484 no está aprobado: si cambia, puede cambiar el contrato.
- Access token vigente tras desactivar (≤ 40 min). También tras quitar un rol: el JWT conserva los roles hasta expirar.
- Autoprotección sin bloqueo de concurrencia: el conteo de admins se hace antes de la escritura, fuera de su transacción. Dos admins desactivándose mutuamente a la vez podrían dejar 0 admins activos. Probabilidad baja; mitigable con transacción serializable o bloqueo si el PO lo pide.
- Un admin cuyo usuario fue desactivado conserva su access token ≤ 40 min y podría seguir gestionando usuarios en ese tiempo (mismo origen que el riesgo anterior).
- `email_verificado = false` sin forma de verificar (no hay endpoint). El frontend no debe bloquear el acceso por ese flag sin una decisión del PO.
- Contrato nuevo para OFT0-486: `id` es el uuid del **user** (no de la persona), `estado` es boolean, `rol` del listado es el **nombre** del rol y `roles` es `[{id, nombre}]`.
- `persons` importa ahora `hashPassword` de `auth/application/utils` (función pura). Si algún día se separan los módulos, convendrá moverla a `src/common`.

## Entrega

| | |
| --- | --- |
| PR | [#39](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/39) → `develop`, commits `3b2a85f` + `6308712` |
| Estado del CI | verde: build, lint, test-unit, test-e2e, docker, security (run `39053368683`). El primer run falló en security por falsos positivos de gitleaks en el e2e; se agregaron a `.gitleaksignore` |
| Jira | transicionado a *En revisión*; comentario `10086` (PR) |
