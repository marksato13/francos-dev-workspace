# OFT0-586 — QA paso 1b: humo E2E del portal de la empresa

> **Regla de esta ficha:** separa siempre lo que **verificaste** de lo que
> **supones**. Todo hecho lleva evidencia (`archivo:línea`, commit o salida de
> comando). Un supuesto sin confirmar nunca se escribe como hecho.

## Identificación

| | |
| --- | --- |
| Subtarea | `OFT0-586`, creada a pedido del usuario el 2026-11-10 |
| Padre | `OFT0-580` — QA: pipeline de pruebas automatizadas (E2E y API) |
| Sprint | 6 |
| Rama | `feature/OFT0-586-qa-portal-empresa` |
| Commit base de `develop` | `2658d85` |
| Fecha de auditoría | 2026-11-10 |

## Criterios de aceptación

| # | Criterio | Estado | Evidencia |
| --- | --- | --- | --- |
| CA-1 | `qa-e2e` descarga `frontend-angular-francos` desde `develop` en solo lectura, lo compila y lo sirve en `:4201` | ausente | `.github/actions/qa-entorno/action.yml` solo descarga la tienda |
| CA-2 | El admin del seed inicia sesión, llega a `/home` y ve «Configuración», que solo llega desde la API | ausente | No hay spec del portal |
| CA-3 | Una contraseña incorrecta recibe 401, muestra el error de la API y no sale del login | ausente | No hay spec del portal |
| CA-4 | La prueba de la tienda sigue igual y el resumen registra el SHA de ambos frontends | parcial | Hoy solo registra la tienda |
| CA-5 | `qa-e2e` sigue siendo informativo y no toca `ci.yml`, `cd.yml`, `src/`, `test/` ni AWS | cubierto | `qa.yml` no está en los checks requeridos de `develop` |

## Hechos auditados

- **Hecho:** el repo `frontend-angular-francos` es público y su rama por defecto es `develop`. · *Evidencia:* `gh repo view` → `PUBLIC`, `develop`
- **Hecho:** `environment.ts` apunta a `http://localhost:3000/api/v1`, y `development` no reemplaza ese archivo. · *Evidencia:* `src/environments/environment.ts`, `angular.json`
- **Hecho:** la API admite en CORS `FRONTEND_PORTAL_URL`, que `qa.yml` ya fija en `http://localhost:4201`. · *Evidencia:* `src/main.ts:17-19`, `qa.yml`
- **Hecho:** el login navega a `/home` cuando la API acepta las credenciales, y muestra `error.error.message` cuando falla. · *Evidencia:* `auth-form-login.ts`
- **Hecho:** «Configuración» no está en las tarjetas provisionales; aparece solo cuando `/rutas/mi-menu` la devuelve. · *Evidencia:* `home-modules.ts`, `prisma/seeds/rutas.seed.ts:234-235`
- **Hecho:** el admin del seed es `admin` / `admin123`. · *Evidencia:* `prisma/seeds/admin.seed.ts:7`
- **Hecho:** los dos frontends fijan Node 24 en `.nvmrc`.

## Supuestos

- **Supuesto:** el portal se compila en `dist/francos-front/browser`, la salida por defecto del proyecto `francos-front`. · *Confirma:* la corrida local.

## Decisiones pendientes

Ninguna. El usuario pidió aplicar el QA al portal de la empresa.

## Alcance

CA-1 a CA-4, con CA-5 como restricción.

## Fuera de alcance

- Pruebas de módulos del portal más allá del login y del menú.
- Modificar `frontend-angular-francos`.
- Hacer de `qa-e2e` un check obligatorio.

## Plan técnico

| Archivo | Cambio |
| --- | --- |
| `.github/actions/qa-entorno/action.yml` | Entrada `portal-ref`, descarga del portal, SHA en el resumen y compilación en `:4201` |
| `.github/workflows/qa.yml` | Entrada manual `portal-ref` |
| `qa/playwright.config.ts` | Un proyecto por frontend: `tienda` y `portal-empresa` |
| `qa/e2e/portal-empresa.spec.ts` | Dos pruebas de humo del portal |
| `qa/README.md` | Cómo correrlo en local |

## Autorización de endpoints

No añade endpoints.

## Migraciones

No hay.

## Plan de pruebas

| Prueba | Tipo | Estado |
| --- | --- | --- |
| Humo de la tienda, sin cambios | Playwright | pasa |
| Login del admin y menú desde la API | Playwright | pasa |
| Contraseña incorrecta en el portal | Playwright | pasa |
| Contraseña del admin rota a propósito: debe dar rojo | Playwright | rojo, como debía |

## Verificación

Local, base limpia, commit `0277432`, tienda `5ac2941` y portal `cd2cd3f`.

- [x] Corrida local con tienda y portal: 4 de 4 en 25 s
- [x] Rojo provocado: falla el login del admin y la prueba negativa sigue en verde
- [x] Salida `dist/francos-front/browser` confirmada: el supuesto queda cerrado
- [x] `prettier --check` y `git diff --check` sobre los archivos cambiados
- [ ] `pnpm build`, `pnpm lint:check` y `pnpm test`: no se corrieron porque el diff no toca `src/` ni `test/`; los corre el CI
- [x] `qa-e2e` en el PR #114: 4 de 4, 2 min 27 s, y el resto del CI en verde

## Riesgos

- Cada corrida compila un frontend más y tarda más.
- El portal se toma de la punta de `develop`; por eso el resumen registra su SHA.

## Entrega

| | |
| --- | --- |
| PR | [#114](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/114), commit `0277432` |
| Estado del CI | Verde: build, lint, test-unit, test-e2e, docker, security y qa-e2e |
| Jira | En revisión |
