# Workspace de desarrollo — Ruben Mark Salazar Tocas

Este repositorio no contiene código de producto. Es el **plano de control**: la
planificación, los agentes, las skills y las fichas con las que se trabaja cada
incidencia Jira asignada al backend de Francos.

## Quién soy y qué me toca

Soy el **desarrollador backend** del proyecto OFT0. Auditado el 2026-09-28:
las 16 subtareas asignadas a mi cuenta son todas `Desarrollar backend`. Cero
frontend, cero QA, cero diseño. Detalle en [`context/equipo.md`](context/equipo.md).

Mi superficie real de trabajo es `backend-monolito-francos`. Los frontends son
de otra persona: los leo para entender contratos de API, **nunca los edito**.

## Repos que orquesta este workspace

Todos son hermanos de esta carpeta. Rutas relativas desde la raíz del workspace:

| Repo | Ruta | Stack | ¿Puedo editar? |
| --- | --- | --- | --- |
| `backend-monolito-francos` | `../backend-monolito-francos` | NestJS 11 + Prisma 7 + PostgreSQL 16 | **Sí** |
| `frontend-francos` | `../frontend-francos` | Angular | No (solo lectura) |
| `frontend-next-francos` | `../frontend-next-francos` | Next + React | No (solo lectura) |

Detalle, remotos y advertencias en [`context/repos.md`](context/repos.md).

## Flujo de una tarea

```
/task-inbox              descubre y prioriza mis subtareas backend
/task-audit OFT0-345     audita la subtarea + su HU padre + el código real
/task-start OFT0-345     develop al día, rama nueva, ficha en specs/
/task-implement OFT0-345 implementa solo el alcance aprobado
/task-verify OFT0-345    replica las 5 puertas del CI en local
/task-pr OFT0-345        commit, push, PR a develop y sincroniza Jira
```

Ciclo completo en [`orchestration/task-lifecycle.md`](orchestration/task-lifecycle.md).

## Reglas que no se negocian

1. **Una subtarea Jira = una rama = un PR.** Nunca mezclar incidencias.
2. **Las ramas salen de `develop` actualizado.** El destino del PR es siempre
   `develop`. `main` no se usa jamás: ni como base, ni como destino, ni como
   objetivo de push o merge.
3. **`feature/OFT0-XXX-slug`** para funcionalidad nueva. **`fix/OFT0-XXX-slug`**
   solo para corregir una entrega que ya se fusionó.
4. **La clave de la rama y del commit es la clave de la subtarea backend**
   (`OFT0-345`), no la de la HU padre. Ver la advertencia de renumeración en
   [`context/jira.md`](context/jira.md).
5. **No se abre PR sin pasar `/task-verify` en verde.** El CI tiene 5 puertas y
   `lint` es bloqueante desde el PR #13. Un PR en rojo es trabajo perdido.
6. **El merge lo hace una persona en GitHub.** Ningún agente fusiona.
7. **Nunca commitear `.env`, secretos, `dist/`, caches ni logs.** El `.env` real
   del backend tiene la contraseña de PostgreSQL y el `JWT_SECRET` en claro.
8. **No tocar cambios ajenos del worktree.** Si `git status` muestra archivos
   que no son de mi incidencia: detenerse y reportar. Jamás `git stash`,
   `git reset --hard` ni `git clean`.
9. **Separar hechos de supuestos.** Toda afirmación sobre el código lleva
   evidencia `archivo:línea`, commit o salida de comando. Nunca reportar el
   resultado de una prueba que no se ejecutó.

## Jira

Sitio `oracle-f1.atlassian.net`, proyecto `OFT0`. Se opera por el MCP `jira`.

- **Lectura: libre.** Consultar incidencias, HU padre, sprints y comentarios
  sin pedir permiso.
- **Escritura automática permitida solo sobre mis propias subtareas:** comentar
  y transicionar estado. Autorizado por el usuario el 2026-09-28.
- **Escritura que sigue requiriendo petición explícita:** crear o borrar
  incidencias, reasignar, editar una HU padre, tocar incidencias de otra
  persona, registrar worklogs.
- **Nunca inventar información de Jira.** Si el MCP falla, reportar el fallo.

Estructura del tablero, campos y trampas conocidas en
[`context/jira.md`](context/jira.md).

## Verificación antes de entregar

El CI del backend corre en cada PR hacia `develop`. Las 5 puertas y su
equivalente local están en la skill [`ci-gates`](.claude/skills/ci-gates/SKILL.md).
`/task-verify` las replica. Resumen:

```
build      pnpm build
lint       pnpm lint:check  +  pnpm format:check     <- BLOQUEANTE
test-unit  pnpm test
test-e2e   pnpm test:e2e     (necesita PostgreSQL real)
docker     docker build + smoke contra /api/docs
```

`pnpm lint` (sin `:check`) aplica `--fix` y modifica archivos. En los agentes de
solo lectura está denegado; usar siempre la variante `:check` para verificar.

## Documentación

- Para APIs de NestJS, Prisma, Jest o Angular: consultar Context7 y registrar la
  versión consultada en la ficha.
- El código del repo y sus pruebas son la evidencia principal del
  comportamiento del negocio. La documentación externa nunca la contradice.

## Fichas

Una ficha por incidencia en `specs/OFT0-XXX-slug.md`, creada desde
[`specs/TEMPLATE.md`](specs/TEMPLATE.md). Obligatorio separar tres bloques:
**hechos auditados** (con evidencia), **supuestos** (con quién los confirma) y
**decisiones pendientes** (con quién decide).
