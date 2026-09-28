---
name: ci-gates
description: Replica en local las 5 puertas del CI del backend Francos antes de abrir un PR. Usar al verificar una entrega, antes de hacer commit o push, cuando un PR sale en rojo, o cuando haya que saber por qué falla build, lint, test-unit, test-e2e o docker.
---

# Puertas del CI del backend

El workflow `.github/workflows/ci.yml` de `backend-monolito-francos` corre en
todo `pull_request` y `push` hacia `develop` y `main`. Son **5 jobs**. `build` va
primero y los otros cuatro dependen de él (`needs: build`), así que si `build`
falla no se ejecuta nada más.

Abrir un PR sin pasar estas puertas en local es gastar un PR en rojo.

## Orden real de ejecución

```
build
  ├─ lint        (ESLint + Prettier)   BLOQUEANTE desde el PR #13
  ├─ test-unit
  ├─ test-e2e    (PostgreSQL 17 real + migrate deploy + seed)
  └─ docker      (build de imagen + smoke contra /api/docs)
```

## Puerta 1 — build

```bash
cd ../backend-monolito-francos
pnpm build
```

Equivale a `pnpm build` en CI. Si esto falla, no sigas: las otras cuatro puertas
ni se van a ejecutar.

## Puerta 2 — lint (bloqueante)

```bash
pnpm lint:check     # ESLint, sin escribir
pnpm format:check   # Prettier, sin escribir
```

En CI el paso de Prettier lleva `if: ${{ !cancelled() }}`, así que **se ejecuta
aunque ESLint ya haya fallado**: los dos errores aparecen en el mismo run. Revisa
ambos antes de volver a subir.

**Nunca uses `pnpm lint` ni `pnpm format` para verificar.** Llevan `--fix` y
`--write`: modifican archivos y te dan un falso verde. Si necesitas corregir,
hazlo como un paso explícito de implementación, no de verificación, y vuelve a
correr las variantes `:check`.

## Puerta 3 — test-unit

```bash
pnpm test
```

En CI es `pnpm test --ci`. Reporta cuántas suites pasaron y cuántas fallaron.
Si una prueba no existe, dilo: "no hay pruebas para X" no es lo mismo que
"las pruebas de X pasan".

## Puerta 4 — test-e2e

Necesita PostgreSQL de verdad. En CI se levanta un servicio
`postgres:17.10-alpine` con:

```
POSTGRES_USER=ci  POSTGRES_PASSWORD=ci  POSTGRES_DB=francos_ci
DATABASE_URL=postgresql://ci:ci@localhost:5432/francos_ci
JWT_SECRET=ci-only-not-a-real-secret
FRONTEND_URL=http://localhost:4200
SMTP_HOST=localhost  SMTP_PORT=1025
SMTP_USER=ci  SMTP_PASS=ci  SMTP_FROM=ci@francos.test
```

y luego:

```bash
pnpm exec prisma migrate deploy
pnpm exec prisma db seed
pnpm test:e2e
```

En local usa la base de desarrollo del `docker-compose.yml` del backend, **no**
la de producción y **no** el contenedor `persons_database` (es de otro proyecto).

`prisma migrate deploy` solo aplica migraciones existentes: es seguro.
`prisma migrate reset`, `prisma db push` y `prisma db execute` están **denegados**
porque destruyen o desincronizan la base local.

## Puerta 5 — docker

```bash
docker build -t francos-backend:ci ..
```

CI además arranca la imagen y hace smoke test: espera hasta 30 intentos a que
`curl -fsS http://localhost:3000/api/docs` responda, y comprueba el healthcheck
del contenedor. Si tu cambio rompe el arranque o Swagger, esta puerta lo caza.

Es la puerta más lenta. Córrela solo si tocaste `Dockerfile`, dependencias,
`main.ts`, la configuración de arranque o la de Swagger.

## Cómo reportar el resultado

Reporta las cinco por separado, y **di explícitamente cuáles no ejecutaste y por
qué**. Nunca declares en verde una puerta que no corriste.

```
build      OK
lint       OK (eslint 0, prettier 0)
test-unit  OK (12 suites, 48 pruebas)
test-e2e   FALLA - 2 pruebas: <detalle>
docker     no ejecutada - no se tocaron Dockerfile ni dependencias
```

## Si el PR ya está abierto y sale en rojo

```bash
gh pr checks <numero>          # qué puerta falló
gh run view <run-id> --log-failed
```

Corrige en la misma rama y vuelve a subir. No abras un PR nuevo: una incidencia
Jira es un solo PR.
