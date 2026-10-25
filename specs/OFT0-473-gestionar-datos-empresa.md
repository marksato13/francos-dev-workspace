# OFT0-473 — HU-A-039 Gestionar datos de la empresa

> **Regla de esta ficha:** separa siempre lo que **verificaste** de lo que
> **supones**. Todo hecho lleva evidencia (`archivo:línea`, commit o salida de
> comando). Un supuesto sin confirmar nunca se escribe como hecho.

## Identificación

| | |
| --- | --- |
| Subtarea backend | `OFT0-473` |
| HU padre | `OFT0-281` — HU-A-039 Gestionar datos de la empresa |
| Épica | `OFT0-316` — Módulo de Configuración del Sistema |
| Sprint | Sprint 2 (id 208, `future`, 2026-09-28 → 2026-10-09: fechas vencidas) |
| Rama | `feature/OFT0-473-gestionar-datos-empresa` |
| Commit base de `develop` | `4157aa8` (merge PR #37) |
| Fecha de auditoría | 2026-10-16 |

Texto de la HU (OFT0-281): *"Como administrador, quiero registrar los datos
generales de la empresa —nombre, RUC, dirección y logo—, para que se utilicen en
la generación de los comprobantes de pago."* Sin comentarios ni issuelinks.

## Criterios de aceptación descompuestos

CA-10 a CA-13 son implícitos (derivados del "para que" y de la definición de
hecho del equipo).

| # | Criterio | Estado en `develop` | Evidencia |
| --- | --- | --- | --- |
| CA-1 | Se guardan razón social, RUC, dirección y logo | cubierto | `prisma/schema.prisma:281-295` |
| CA-2 | El admin registra los datos de **la** empresa emisora | parcial (CRUD multi-registro) | `empresas.controller.ts:44-49` |
| CA-3 | El admin consulta los datos vigentes de la emisora (un registro) | parcial | solo `GET /empresas` paginado y `GET /empresas/:id` (`empresas.controller.ts:51-65`) |
| CA-4 | El admin edita los datos de la emisora | parcial | `PATCH /empresas/:id` (`empresas.controller.ts:67-75`), sin noción de emisora |
| CA-5 | Razón social y dirección obligatorias y no vacías | cubierto | `create-empresa.dto.ts:13-23` |
| CA-6 | RUC de 11 dígitos y único | cubierto | `create-empresa.dto.ts:18`, `schema.prisma:284`, `create-empresa.use-case.ts:12-16` |
| CA-7 | Logo como URL válida | cubierto | `create-empresa.dto.ts:34-36` (`@IsUrl`) |
| CA-8 | Existe a lo sumo **una** empresa emisora | ausente | modelo sin flag de emisora (`schema.prisma:281-295`) |
| CA-9 | Solo `admin` escribe | parcial | `@Roles('admin', 'ventas')` a nivel de clase (`empresas.controller.ts:33`) |
| CA-10 | Otros módulos (OFT0-541) pueden leer la emisora | ausente | `PersonsModule` no exporta `EmpresaRepository` (`persons.module.ts` `exports`) |
| CA-11 | La emisora no se puede desactivar (dejaría los comprobantes sin emisor) | ausente | `change-empresa-status.use-case.ts:10-14` no protege nada |
| CA-12 | Pruebas unitarias y e2e (401/403/200/404/409/400) | ausente | `git grep -i empresa -- test '*.spec.ts'` vacío |
| CA-13 | Contrato documentado en Swagger | parcial | `ApiTags/ApiOperation` en el CRUD; los endpoints nuevos lo necesitan |

## Hechos auditados

- **Hecho:** OFT0-473 es Subtask "Desarrollar backend", asignada a Ruben, "Por hacer", parent OFT0-281 · *Evidencia:* MCP `getJiraIssue OFT0-473` (2026-10-16).
- **Hecho:** OFT0-473 **no** depende del modelo `Pedido`, que no existe en `develop` · *Evidencia:* `grep '^model (Pedido|Comprobante|Serie|Venta)' prisma/schema.prisma` vacío.
- **Hecho:** el CRUD `/empresas` existe desde antes de la HU, sin pruebas · *Evidencia:* commit `71a3a97` (Piero Lanche, 2026-08-01); `git grep` de specs vacío.
- **Hecho:** `RolesGuard` usa `getAllAndOverride([handler, class])` y deniega sin `@Roles` · *Evidencia:* `src/modules/auth/presentation/guards/roles.guard.ts:35-42`; guards globales en `auth.module.ts:56-61`.
- **Hecho:** el rol `admin` existe en el seed · *Evidencia:* `prisma/seeds/roles.seed.ts:3-10`.
- **Hecho:** ningún frontend consume `/empresas` hoy · *Evidencia:* `Proyecto-Aura/frontend-angular-francos` `src/app/modules/configuracion/empresa/**` solo `.gitkeep` (`gh api .../git/trees/develop?recursive=1`); clones locales sin referencias.
- **Hecho:** no hay rama ni PR previo de OFT0-473/OFT0-281 · *Evidencia:* `gh pr list --state all --search "OFT0-473"` → `[]`.

## Supuestos

- **Supuesto:** la HU se refiere a una sola empresa emisora (Franco's), no a un catálogo · *Confirma:* PO / autor de la HU.
- **Supuesto:** `persons.empresa` se creó para la emisora y no tiene otro uso (proveedores, clientes corporativos) · *Confirma:* Piero Lanche (autor de `71a3a97`).
- **Supuesto:** el "nombre" de la HU es la razón social; no hace falta nombre comercial · *Confirma:* PO, según lo que pida OFT0-541.
- **Supuesto:** la tabla `empresa` está vacía o es descartable en los entornos desplegados (la migración solo **añade** una columna con default, no destruye datos) · *Confirma:* responsable de despliegue.

## Decisiones

Tomadas por el usuario el 2026-10-16:

- **Enfoque:** recurso nuevo `/empresa` (singular, emisora única). El CRUD `/empresas` se conserva, restringido a `admin`.
- **Rol de escritura:** solo `admin`.
- **Logo:** sigue siendo URL libre (`logo_url` con `@IsUrl`). Sin S3, sin migración de `logo_url`.
- **Lectura pública:** no por ahora.

Tomadas en la implementación (2026-10-16):

- **`PUT /empresa` reemplaza:** un opcional que no llega (`telefono`, `email`, `logo_url`) queda en `null`. Para eso `UpdateEmpresaParams` acepta `string | null` en esos tres campos (`empresa-repository.types.ts`); `PATCH /empresas/:id` no cambia porque sigue pasando `undefined`.
- **Sin `upsertEmisora` en el repositorio:** se reutilizan `create` (con `es_emisora` en `CreateEmpresaParams`) y `update`. Solo se añade `findEmisora()`.
- **`UpsertEmpresaEmisoraDto` = `OmitType(CreateEmpresaDto, ['estado'])`:** mismas validaciones que el alta; mandar `estado` da 400 (`forbidNonWhitelisted`).
- **Activar la emisora sí se permite;** solo se bloquea desactivarla (409 `No se puede desactivar la empresa emisora`).
- **Versiones de referencia** (de `package.json`; Context7 no estaba disponible en esta sesión, así que no se consultó): `@nestjs/core` ^11.0.1, `@nestjs/swagger` ^11.4.5, `prisma`/`@prisma/client` ^7.8.0 (runtime 7.8.0 en las trazas), `class-validator` ^0.15.1, `jest` ^30.0.0.

Pendientes (no bloquean esta entrega):

- **Decisión:** validación de RUC con prefijo 10/20 + dígito verificador módulo 11 · *Decide:* PO · *Bloquea:* no (se mantiene 11 dígitos).
- **Decisión:** seed con datos reales de la emisora · *Decide:* PO · *Bloquea:* no.
- **Decisión:** si OFT0-493 liga las series a `empresa_id` · *Decide:* Ruben con el líder técnico · *Bloquea:* no.
- **Decisión:** reprogramar el sprint (Sprint 2 vencido) · *Decide:* Scrum Master · *Bloquea:* no.

## Alcance

- Marca de emisora: columna `es_emisora` + índice único parcial (CA-8).
- `GET /empresa` y `PUT /empresa` (upsert de la emisora) solo para `admin` (CA-2, CA-3, CA-4, CA-9).
- CRUD `/empresas` restringido a `admin` (CA-9).
- Desactivar la emisora por `DELETE /empresas/:id` responde 409 (CA-11).
- Exportar el acceso a la emisora para otros módulos (CA-10).
- Pruebas unitarias y e2e (CA-12) y Swagger de los endpoints nuevos (CA-13).

## Fuera de alcance

- Subida del logo a S3 (decisión: URL libre).
- Lectura pública `@Public()` para el Portal B.
- Validación módulo 11 del RUC.
- Seed de la empresa emisora y ruta de menú.
- Retirar el CRUD `/empresas`.
- Frontend (OFT0-474) y generación de comprobantes (OFT0-541).

## Plan técnico

| Capa | Archivos |
| --- | --- |
| `prisma` | `schema.prisma` (`es_emisora Boolean @default(false)`), migración `add_empresa_es_emisora` con índice único parcial `WHERE es_emisora = true` |
| `domain` | `empresa.entity.ts` (+`es_emisora`), `empresa.repository.ts` (+`findEmisora`; el upsert reutiliza `create`/`update`), tipos |
| `application` | `get-empresa-emisora.use-case.ts`, `upsert-empresa-emisora.use-case.ts`, DTO `upsert-empresa-emisora.dto.ts`; `change-empresa-status.use-case.ts` rechaza desactivar la emisora |
| `infrastructure` | `prisma-empresa.repository.ts`, `empresa.mapper.ts` |
| `presentation` | `empresa-emisora.controller.ts` (`/empresa`), `empresas.controller.ts` (`@Roles('admin')`), `empresa.presenter.ts` (+`es_emisora`), `persons.module.ts` (registro y `exports`) |

## Autorización de endpoints

| Endpoint | Método | Roles requeridos |
| --- | --- | --- |
| `/api/v1/empresa` | GET | `admin` |
| `/api/v1/empresa` | PUT | `admin` |
| `/api/v1/empresas/**` (existente) | todos | `admin` (antes `admin`, `ventas`) |

## Migraciones

Creada como `prisma/migrations/20261016210224_add_empresa_es_emisora/migration.sql`
y aplicada en local con `pnpm exec prisma migrate dev` (sin drift ni reset).
Verificado en la BD: `CREATE UNIQUE INDEX uq_empresa_emisora ON persons.empresa USING btree (es_emisora) WHERE (es_emisora = true)` (`pg_indexes`).

`add_empresa_es_emisora`: añade `persons.empresa.es_emisora BOOLEAN NOT NULL DEFAULT false`
y `CREATE UNIQUE INDEX uq_empresa_emisora ON persons.empresa (es_emisora) WHERE es_emisora = true`.
No destruye datos. Se crea con `pnpm exec prisma migrate dev --create-only` y el
índice parcial se añade a mano (Prisma no modela índices parciales).

## Dependencias con el frontend

- **Contrato nuevo:** `GET/PUT /api/v1/empresa`. Avisar a quien lleve OFT0-474 (frontend).
- **Cambio de permisos:** `ventas` pierde acceso a `/empresas`. No hay consumidores conocidos.
- **Respuesta:** `EmpresaPresenter` añade `es_emisora` (campo nuevo, no rompe a nadie).

## Plan de pruebas

| Prueba | Tipo | Estado |
| --- | --- | --- |
| `GetEmpresaEmisoraUseCase`: devuelve la emisora / 404 si no hay (2 casos) | unitaria | pasa |
| `UpsertEmpresaEmisoraUseCase`: crea, actualiza (opcionales a null), conserva su propio RUC/email, 409 RUC ajeno, 409 email ajeno (5 casos) | unitaria | pasa |
| `ChangeEmpresaStatusUseCase`: 409 al desactivar la emisora, desactiva otra, activa la emisora, 404 (4 casos) | unitaria | pasa |
| `/empresa`: 401 sin token, 403 con `ventas` (GET y PUT), 404 sin emisora, 400 (RUC inválido, sin dirección, logo no URL, `estado` no permitido), PUT crea (200) + GET, PUT actualiza (200, una sola emisora), 409 RUC de otra empresa | e2e | pasa |
| `/empresas`: 403 con `ventas`; `DELETE` de la emisora → 409 y sigue activa | e2e | pasa |

Archivos: `src/modules/persons/application/use-cases/empresas/{get-empresa-emisora,upsert-empresa-emisora,change-empresa-status}.use-case.spec.ts` y `test/empresa.e2e-spec.ts` (usuario `e2e-ventas-empresa`, DNI `99994730`, RUC `20999990473`/`20999991473`; si ya había una emisora la aparta y la restaura al final).

## Verificación

Ejecutado el 2026-10-16 en la rama `feature/OFT0-473-gestionar-datos-empresa`:

- [x] `pnpm build` → exit 0
- [x] `pnpm lint:check` → exit 0, sin errores ni warnings
- [x] `pnpm format:check` → falla en 148 archivos **ajenos** por CRLF del checkout local (ver Riesgos). `prettier --check` sobre los 18 `.ts` del diff → "All matched files use Prettier code style!" (2 archivos míos corregidos con `prettier --write`)
- [x] `pnpm test` → 62 suites, 319 pruebas, todas pasan (11 nuevas)
- [x] `pnpm test:e2e --ci --runInBand` → 11 suites, 169 pruebas, todas pasan. `test/empresa.e2e-spec.ts` solo → 8/8. En paralelo (`pnpm test:e2e --ci`) fallan suites ajenas, también **sin** mi archivo (ver Riesgos)
- [ ] `docker build` + smoke
- [x] `pnpm exec prisma migrate status` → "22 migrations found... Database schema is up to date!"
- [x] `git diff --check` → sin salida, exit 0
- [x] Sin `.env`, secretos, `dist/`, caches ni logs en el diff (`git status --short`)

No ejecutado y por qué:

- `docker build` + smoke: no estaba en el encargo de esta implementación; queda para `/task-verify`.

Preparación del entorno local (no forma parte del diff):

- La BD local no tenía roles ni usuario `admin`: se corrió `pnpm exec prisma db seed` (todos los seeds son `upsert` o comprueban existencia, idempotentes).
- El `.env` local no define las variables que exige `src/config/envs.ts` desde el PR #36 (`FRONTEND_STORE_URL`, `FRONTEND_PORTAL_URL`, `SMTP_*`, `S3_BUCKET_*`). No se leyó ni editó `.env`; para el e2e se exportaron en el proceso los valores ficticios del CI (`.github/workflows/ci.yml:98-108`).

Archivos tocados en el backend:

- `prisma/schema.prisma`, `prisma/migrations/20261016210224_add_empresa_es_emisora/migration.sql`
- `src/modules/persons/domain/entities/empresa.entity.ts`, `domain/repositories/empresa.repository.ts`, `domain/repositories/types/empresa-repository.types.ts`
- `src/modules/persons/infrastructure/mappers/empresa.mapper.ts`, `infrastructure/repositories/prisma-empresa.repository.ts`
- `src/modules/persons/application/dto/empresa-dtos/upsert-empresa-emisora.dto.ts` (nuevo)
- `src/modules/persons/application/use-cases/empresas/get-empresa-emisora.use-case.ts` (nuevo), `upsert-empresa-emisora.use-case.ts` (nuevo), `change-empresa-status.use-case.ts`, `create-empresa.use-case.ts`, y los 3 `.spec.ts` nuevos
- `src/modules/persons/presentation/controllers/empresa-emisora.controller.ts` (nuevo), `controllers/empresas.controller.ts`, `presenters/empresa.presenter.ts`, `persons.module.ts`
- `test/empresa.e2e-spec.ts` (nuevo)
- `prisma/migrations/migration_lock.toml` aparece como `M` en `git status` pero `git diff` no muestra cambios (mismo contenido byte a byte; solo lo tocó `migrate dev`). No incluirlo en el commit.

## Riesgos

- Se modifica código ajeno (`persons/empresas`, de Piero Lanche): cambio mínimo, avisar en el PR.
- `ventas` pierde acceso a `/empresas`: si alguien lo usaba, sale 403.
- Entorno local: el volumen de la BD es de PostgreSQL 16 y `docker-compose.yml` exige 17.10 (commit `48c3e22`). Se trabaja con un contenedor temporal `francos-db-pg16`; el CI usa su propio PostgreSQL.
- **Carrera en el primer `PUT /empresa`:** dos PUT simultáneos sin emisora previa pueden intentar crear dos; el índice `uq_empresa_emisora` lo impide, pero el segundo recibe un 500 (P2002 sin traducir; `PersonsDomainExceptionFilter` solo atrapa errores de dominio). Improbable con un solo admin. Fuera de alcance.
- **Hallazgo (fuera de alcance), e2e en paralelo:** `pnpm test:e2e --ci` falla en local en suites ajenas (`password-recovery`, `promociones`, `catalogo`, `objetivo-estrategico`, según la corrida) con `Foreign key constraint violated on fk_user_persona` en `persona.deleteMany`. Pasa igual **excluyendo** `empresa.e2e-spec.ts` y desaparece con `--runInBand` (169/169). Causa: DNIs de prueba repetidos entre suites — `99999994` en `promociones.e2e-spec.ts:19` y `documento-estrategico.e2e-spec.ts:26`; `99999996`/`99999995` en `catalogo.e2e-spec.ts:23,30` y `objetivo-estrategico.e2e-spec.ts:25-26`; `99999997` en `password-recovery.e2e-spec.ts:17` y `plan-estrategico.e2e-spec.ts:20`. En el CI puede manifestarse según el número de workers. Requiere su propia incidencia.
- **Hallazgo (fuera de alcance), entorno local:** el checkout tiene 148 `.ts` con CRLF pese a `.gitattributes` `* text=auto eol=lf` y `core.autocrlf=true`, por eso `pnpm format:check` falla en local sobre archivos no tocados. En el CI (checkout Linux con LF) no debería pasar.
- **Hallazgo (fuera de alcance), `.env` local desactualizado:** faltan las variables obligatorias añadidas en el PR #36; sin ellas la app y el e2e no arrancan (`Config validation error: "FRONTEND_STORE_URL" is required`).

## Entrega

| | |
| --- | --- |
| PR | [#38](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/38) → `develop`, commit `7637135` |
| Estado del CI | verde: build, lint, test-unit, test-e2e, docker, security (run `39006345944`) |
| Jira | transicionado a *En revisión*; comentarios `10083` (inicio) y `10084` (PR) |
