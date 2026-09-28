---
description: Replica las 5 puertas del CI en local y revisa el diff antes de abrir el PR
argument-hint: OFT0-345
---

Verifica la entrega de **$1** antes de abrir PR. Delega en el subagente
`backend-reviewer` y carga la skill `ci-gates`.

Este comando **no corrige nada**. Solo dice la verdad sobre el estado.

## Las 5 puertas, en el orden del CI

En `../backend-monolito-francos`:

```bash
pnpm build                                  # puerta 1
pnpm lint:check && pnpm format:check        # puerta 2 - BLOQUEANTE
pnpm test                                   # puerta 3
pnpm test:e2e                                # puerta 4 - necesita PostgreSQL
docker build -t francos-backend:ci .         # puerta 5 - solo si aplica
```

**Nunca uses `pnpm lint` ni `pnpm format` aquí.** Llevan `--fix`/`--write`:
modifican archivos y producen un falso verde.

La puerta `docker` solo si el diff toca `Dockerfile`, dependencias, `main.ts`, el
arranque o Swagger. Si la omites, dilo.

## Controles de Prisma

```bash
pnpm exec prisma validate
pnpm exec prisma generate
pnpm exec prisma migrate status
```

Si `migrate status` reporta migraciones pendientes o deriva, es un hallazgo
bloqueante: el job `test-e2e` del CI corre `migrate deploy` y va a fallar.

## Higiene del diff

```bash
git diff --check
git diff origin/develop...HEAD --stat
git status --short
```

Confirma explícitamente que **no** entran: `.env` ni variantes, secretos o
credenciales, `dist/`, `node_modules/`, caches, logs, ni cambios que pertenezcan
a otra incidencia.

## Revisión de contenido

Contra la ficha `specs/$1-*.md`, criterio por criterio: ¿está cubierto de verdad?
Y además:

1. Bugs de corrección y casos límite.
2. `@Roles` en todo endpoint nuevo (sin él queda inaccesible desde el PR #12).
3. Regresiones sobre comportamiento existente.
4. Pruebas faltantes del comportamiento nuevo — bloqueante.
5. Respeto de las capas del módulo.

## Cómo reportas

Las 5 puertas por separado, con **tres estados posibles: pasó / falló / no se
ejecutó y por qué**. Nunca declares en verde algo que no corriste, y nunca
reportes el resultado esperado en lugar del observado.

Cierra con un veredicto: **listo para PR** o **no listo** + la lista concreta de
lo que falta.

No hagas commit ni push. Eso es `/task-pr`.
