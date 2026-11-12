# OFT0-582 — QA paso 2: contrato de la API, IDOR y datos inválidos

> **Regla de esta ficha:** separa siempre lo que **verificaste** de lo que
> **supones**. Todo hecho lleva evidencia (`archivo:línea`, commit o salida de
> comando). Un supuesto sin confirmar nunca se escribe como hecho.

## Identificación

| | |
| --- | --- |
| Subtarea | `OFT0-582` |
| Padre | `OFT0-580` — QA: pipeline de pruebas automatizadas (E2E y API) |
| Sprint | 6 |
| Rama | `feature/OFT0-582-qa-contrato-api` |
| Commit base de `develop` | `012aa14` |
| Fecha de auditoría | 2026-11-12 |

## Criterios de aceptación

Del texto de la subtarea en Jira: *contrato validado contra `/api/docs-json`;
IDOR: un cliente no ve el reembolso de otro (404); datos inválidos: el resumen
del pedido responde 400, nunca 500.*

| # | Criterio | Estado | Evidencia |
| --- | --- | --- | --- |
| CA-1 | En cada PR, el contrato OpenAPI (`/api/docs-json`) se compara con el de `develop` y el job da rojo si hay un cambio que rompe a los frontends | ausente | No hay ningún job que lea `/api/docs-json` |
| CA-2 | IDOR: un cliente recibe 404 al pedir el reembolso de otro | cubierto | `test/portal-reembolsos.e2e-spec.ts:691`, y una solicitud sobre un pedido ajeno en `:511` |
| CA-3 | Datos inválidos: el resumen del pedido responde 400, no 500 | cubierto | `test/portal-pedidos.e2e-spec.ts:503-583`: 15 casos que devuelven 400 |
| CA-4 | Es informativo: no toca `ci.yml`, `cd.yml`, `src/`, `test/` ni AWS | restricción | — |

## Hechos auditados

- **Hecho:** Swagger se publica en `api/docs`, así que el JSON está en `/api/docs-json`. · *Evidencia:* `src/main.ts:34-35`; `curl` local → 200
- **Hecho:** para arrancar, la API solo necesita conectarse a la base: `PrismaService.onModuleInit` llama a `$connect`, y no hay crons ni tareas al arrancar. · *Evidencia:* `src/infrastructure/database/prisma/prisma.service.ts`
- **Hecho:** los e2e de Jest ya prueban IDOR en los tres endpoints `:id` del portal. · *Evidencia:* `portal-pedidos-pago.e2e-spec.ts:506`, `portal-reembolsos.e2e-spec.ts:511` y `:691`, `portal-notificaciones.e2e-spec.ts:389`
- **Hecho:** la mayoría de los `@ApiOkResponse` no declaran tipo, así que validar las respuestas contra el contrato no comprobaría casi nada. · *Evidencia:* por ejemplo, `portal-notificaciones.controller.ts:46,58,70,82`
- **Hecho:** `format:check` solo revisa `src/**/*.ts` y `test/**/*.ts`. · *Evidencia:* `package.json:12`
- **Hecho:** oasdiff `v1.34.1` se publica como imagen `tufin/oasdiff` con digest `sha256:67a23cfe…b85f`. · *Evidencia:* `docker run … --version` → `oasdiff version v1.34.1`

## Supuestos

Ninguno abierto.

## Decisiones tomadas

- **CA-1 se cumple comparando contratos, no validando respuestas.** Jira dice
  «respuestas validadas contra `/api/docs-json`», pero las respuestas no tienen
  tipo en Swagger. Lo que de verdad protege a los frontends es detectar un
  endpoint borrado o un campo nuevo obligatorio antes de fusionar.
- **CA-2 y CA-3 no se duplican en `qa/`.** Ya los prueban los e2e de Jest
  contra PostgreSQL real, y en cada PR (`test-e2e`). Una segunda copia solo
  añadiría mantenimiento.

## Alcance

CA-1, con CA-4 como restricción. CA-2 y CA-3 quedan documentados como cubiertos.

## Fuera de alcance

- Tipar las respuestas de Swagger (`@ApiOkResponse({ type })`) en los controladores.
- Hacer de `qa-contrato` un check obligatorio de `develop`.
- Modificar los frontends.

## Plan técnico

| Archivo | Cambio |
| --- | --- |
| `.github/workflows/qa.yml` | Job `qa-contrato`, solo en `pull_request`: compila la API del PR y la de la rama destino (como `git worktree` en `$RUNNER_TEMP`), extrae los dos contratos, los compara y los sube como artefacto |
| `qa/contrato/extraer.sh` | Arranca una API compilada en un puerto, descarga `/api/docs-json` y la apaga |
| `qa/contrato/comparar.sh` | `oasdiff changelog` al resumen del job y `oasdiff breaking --fail-on ERR` |
| `qa/README.md` | Qué hace `qa-contrato`, cómo leer el rojo y cómo correrlo en local |

## Autorización de endpoints

No añade endpoints.

## Migraciones

No hay.

## Plan de pruebas

| Prueba | Tipo | Estado |
| --- | --- | --- |
| Contrato de la rama igual al de `develop` | oasdiff local | verde: «No changes detected» |
| `GET preferencias` renombrado a `mis-preferencias` a propósito | oasdiff local | rojo: `api-removed-without-deprecation`, salida 1 |
| `qa-contrato` en el PR | GitHub Actions | verde en 1 min 14 s |

## Verificación

Local, sobre `012aa14`:

- [x] Contrato de `develop` y de la rama extraídos con `extraer.sh` (puertos 3006 y 3005)
- [x] Verde sin cambios y rojo con la ruta renombrada; el cambio de prueba se revirtió
- [x] `pnpm build` y `pnpm lint:check` en verde; `bash -n` en los dos scripts; `git diff --check` limpio
- [x] `pnpm test`: 1571 de 1571 (209 suites); `pnpm test:e2e`: 1159 de 1159 (51 suites)
- [ ] `docker build`: no se corrió; el diff no toca `Dockerfile`, dependencias, `main.ts` ni Swagger
- [x] `qa-contrato` en el PR #117: extrajo los dos contratos y comparó sin cambios; resto del CI en verde

## Riesgos

- El job compila el backend dos veces: unos minutos más por PR.
- Solo ve lo que Swagger documenta: un cambio en una respuesta sin tipo pasa sin aviso.

## Entrega

| | |
| --- | --- |
| PR | [#117](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/117), commit `01e34ff` |
| Estado del CI | Verde: build, lint, test-unit, test-e2e, docker, security, qa-e2e y qa-contrato («No changes detected» contra `develop` en `baa2ec5`) |
| Jira | En revisión desde el 2026-11-12 |
