# Repos, rutas y estado

Auditado el 2026-09-28. Todos son carpetas hermanas de este workspace.

## `backend-monolito-francos` — mi repo

- **Ruta:** `../backend-monolito-francos`
- **Remoto:** `https://github.com/Proyecto-Aura/backend-monolito-francos.git` (privado)
- **Rama base:** `develop` · **Nunca:** `main`
- **Stack:** NestJS 11, Prisma 7, PostgreSQL 16, TypeScript, `pnpm@11.10.0`
- **Paquete:** `proyecto-monolito-francos` v0.0.1

### Módulos en `src/modules/`

```
auth        catalog     inventory   persons
production  sales       strategic
```

Cada módulo sigue Clean Architecture: `domain/`, `application/`,
`infrastructure/`, `presentation/`. Respetar las capas existentes; no inventar
una estructura nueva.

### Scripts que importan

| Script | Qué hace | Nota |
| --- | --- | --- |
| `pnpm build` | `nest build` | |
| `pnpm lint:check` | `eslint` sin escribir | **Usar esta para verificar** |
| `pnpm lint` | `eslint --fix` | **Modifica archivos.** No usar en verificación |
| `pnpm format:check` | `prettier --check` | Usar esta para verificar |
| `pnpm format` | `prettier --write` | Modifica archivos |
| `pnpm test` | `jest` | Unitarios |
| `pnpm test:e2e` | `jest --config ./test/jest-e2e.json` | **Necesita PostgreSQL real** |
| `pnpm test:cov` | cobertura | |

### Variables de entorno obligatorias

Validadas por Joi en `src/config/envs.ts`. Requeridas: `DATABASE_URL`,
`JWT_SECRET`, `FRONTEND_URL`, `SMTP_HOST`, `SMTP_USER`, `SMTP_PASS`,
`SMTP_FROM`. Con default: `PORT` (3000), `JWT_ACCESS_EXPIRES_IN` (40m),
`REFRESH_TOKEN_EXPIRES_IN_DAYS` (7), `SMTP_PORT` (587), `SMTP_SECURE` (false).

**El `.env` real contiene la contraseña de PostgreSQL y el `JWT_SECRET` en
claro.** Está en `.gitignore` y jamás se commitea. `docker-compose.override.yml`
también tiene la contraseña y es solo local. Ambos están denegados a la lectura
en `.claude/settings.json`.

### Cambios recientes en `develop` que condicionan todo trabajo nuevo

| PR | Qué cambió | Por qué me afecta |
| --- | --- | --- |
| #7 | CI en GitHub Actions | Todo PR pasa por 5 puertas |
| #9 | Guards globales JWT + RBAC (`HU-A-001 / OFT0-243`) | **La protección ya es global.** No hace falta `@UseGuards` por controlador; hace falta `@Roles` donde el acceso sea restringido |
| #11 | Deuda de lint saldada, 547 → 0 | El repo está limpio: cualquier warning nuevo es mío |
| #12 | `RolesGuard` deniega por defecto si falta `@Roles` | **Un endpoint sin `@Roles` queda inaccesible.** Hay que declararlo siempre |
| #13 | El job `lint` pasó a bloqueante | Un fallo de eslint o prettier tumba el PR |
| #14 | `.gitattributes` normaliza finales de línea | No pelear con CRLF en Windows |

### Contenedores locales

`docker-compose.yml` levanta la base del proyecto. **Existe además un contenedor
`persons_database` que pertenece a otro proyecto: no detenerlo ni borrarlo.**
`docker stop`, `docker rm` y `docker compose down -v` están denegados.

## Frontends — solo lectura

**Usar estos dos clones (2026-11-01), en `develop`:**

| Carpeta local | Repo en GitHub | Stack | Qué es |
| --- | --- | --- | --- |
| `../frontend-angular-francos` | `Proyecto-Aura/frontend-angular-francos` | Angular | Portal de la empresa (Portal A) |
| `../frontend-cliente-angular` | `Proyecto-Aura/frontend-cliente-angular` | Angular (`angular.json`) | Portal del cliente (Portal B) |

Los clones viejos quedan obsoletos y no se borran:

| Carpeta local | Remoto configurado | Estado |
| --- | --- | --- |
| `../frontend-francos` | `Proyecto-Aura/frontend-francos` | 404 — `git fetch` falla |
| `../frontend-next-francos` | `Proyecto-Aura/frontend-next-francos` | 404; era Next + React |

**Verificado:** el portal del cliente se migró de Next a Angular. `frontend-cliente-angular`
tiene `angular.json` y conserva las ramas `feature/Crear-pedido`, `feature/Carrito-compras`, etc.,
del repo Next, además de ramas nuevas `feature/OFT0-XXX-*`. El `CLAUDE.md` raíz sigue citando las
rutas viejas: actualizarlo cuando el usuario lo pida.

Como no son mi responsabilidad, no los arreglo. Se consultan solo para entender
qué contrato de API esperan antes de cambiar un endpoint.

## Este workspace

- **Ruta:** `../francos-dev-workspace` (o la raíz, si OpenCode/Claude arranca aquí)
- **Remoto:** `https://github.com/marksato13/francos-dev-workspace.git` (privado)
- **Rama:** `main` — es un repo de planificación, no de producto, así que no
  aplica Git Flow. Se commitea directo.

## Aviso sobre el token de GitHub

El token de `gh` tiene scopes `gist, read:org, repo`. **No tiene `workflow`**, así
que no se pueden crear ni modificar archivos en `.github/workflows/`. Si hace
falta: `gh auth refresh -s workflow`.
