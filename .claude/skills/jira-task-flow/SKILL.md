---
name: jira-task-flow
description: Flujo completo para trabajar una incidencia OFT0 del backend Francos, desde auditar Jira hasta entregar el PR. Usar cuando se mencione una clave OFT0-XXX, una HU, una subtarea de backend, el tablero de Jira, una rama feature/fix, o cuando haya que decidir qué tarea tomar.
---

# Flujo de una incidencia OFT0

## Antes de tocar nada: resuelve la clave

El tablero **se renumeró**. Claves que aparecen en ramas, commits o documentos
viejos pueden estar muertas (`OFT0-55` da 404). **Verifica toda clave contra Jira
antes de usarla.** Si no existe, busca la HU por su título (`HU-A-007 Gestionar
producto`) y usa la clave nueva.

Trabajo siempre sobre la **subtarea de backend** (`Desarrollar backend`), no
sobre la HU padre. La rama y el commit llevan la clave de la subtarea.

## Paso 1 — Leer el alcance de verdad

Las subtareas tienen `description: null`. El criterio de aceptación está **solo
en la HU padre**. Hay que leer siempre `parent`.

Y los criterios vienen como **un párrafo único** con muchas capacidades metidas
en subordinadas. El primer trabajo real es **descomponerlo en criterios numerados
y verificables** y escribirlos en la ficha. Un párrafo no se puede verificar;
una lista sí.

Ejemplo de descomposición de OFT0-249:

```
CA-1  Registrar producto con nombre, categoría y descripción
CA-2  Registrar 1..N presentaciones con imagen, precio unitario,
      precio mayorista y umbral mayorista
CA-3  SKU autogenerado con formato FR-P{productoID}-PR{presentacionID}
CA-4  Por cada presentación se crea un producto terminado
      (cantidad 0, stock actual 0, stock mínimo 1, unidad preseleccionada)
CA-5  El producto nace oculto del Portal B
...
```

## Paso 2 — Auditar contra el código, no contra Jira

El estado de Jira no prueba nada. Clasifica cada criterio como **cubierto /
parcial / ausente / no verificable** comparando con `origin/develop`, con
evidencia `archivo:línea`.

Revisa también si ya existe rama o PR para esa incidencia:

```bash
git fetch --prune origin
git branch -r | grep -i <clave-o-slug>
gh pr list --state all --search "<clave>"
```

Un PR **cerrado sin fusionar** significa que ese trabajo no entró: no lo cuentes
como cubierto.

## Paso 3 — Rama

Sale de `develop` actualizado por fast-forward. Nunca de `main`, nunca de otra
rama de tarea.

- `feature/OFT0-XXX-slug` — funcionalidad nueva
- `fix/OFT0-XXX-slug` — **solo** si corriges algo que ya se fusionó en `develop`

Una incidencia = una rama = un PR.

Si el worktree tiene cambios rastreados que no son tuyos: **detente y reporta.**
No uses `git stash`, `git reset --hard` ni `git clean`; están denegados.

## Paso 4 — Implementar

El cambio mínimo que cubra los criterios aprobados. Respeta las capas del módulo
(`domain`, `application`, `infrastructure`, `presentation`).

Dos cosas que cambiaron en `develop` y que se olvidan:

- Los **guards JWT + RBAC ya son globales** (PR #9). No añadas `@UseGuards` por
  controlador.
- **`RolesGuard` deniega por defecto si falta `@Roles`** (PR #12). Un endpoint sin
  `@Roles` queda inaccesible para todos. Declara siempre el rol.

Las migraciones se crean con `pnpm exec prisma migrate dev`. `migrate reset` y
`db push` están denegados.

Las pruebas del comportamiento nuevo van **en el mismo PR** que el código: QA no
tiene dueño en este proyecto.

## Paso 5 — Verificar

Usa la skill `ci-gates`. Las 5 puertas, reportadas por separado, diciendo
explícitamente qué no se ejecutó y por qué.

Además: `git diff --check`, diff contra `origin/develop`, y confirmar que no
entran `.env`, secretos, caches, logs, `dist/` ni cambios de otra tarea.

## Paso 6 — Entregar

1. Verifica que no exista ya un PR para la incidencia.
2. `git add` con **rutas explícitas**. Nunca `git add -A` ni `git add .`.
3. Commit con la clave de la subtarea en el mensaje.
4. Push de la rama de tarea.
5. `gh pr create --base develop`. Jamás `--base main`.
6. El cuerpo del PR lleva: enlace a Jira, alcance, criterios cubiertos,
   **pruebas ejecutadas y pruebas omitidas**, migraciones, riesgos y evidencia.
7. El merge lo hace una persona en GitHub. `gh pr merge` está denegado.

## Paso 7 — Jira

Con el PR creado: comentar la subtarea con el enlace y la evidencia, y
transicionarla. Esto está autorizado en automático **solo para mis propias
subtareas**.

Crear, borrar o reasignar incidencias, editar la HU padre, tocar incidencias de
otra persona o registrar worklogs **requiere petición explícita del usuario**.

Nunca registres un resultado que no observaste.

## Reglas de reporte

- Hechos auditados, supuestos y decisiones pendientes en **bloques separados**.
- Todo hecho con evidencia: `archivo:línea`, commit o salida de comando.
- Una prueba no ejecutada se reporta como no ejecutada.
- Si una acción está bloqueada por configuración, **reporta el bloqueo; no busques
  un rodeo.**

## Definición de terminado

No basta con que compile. Debe cumplir los criterios numerados, tener pruebas,
pasar las 5 puertas, tener PR hacia `develop` y dejar Jira trazable.
