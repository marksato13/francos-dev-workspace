---
description: Actualiza develop, crea la rama de la subtarea y escribe su ficha en specs/
argument-hint: OFT0-345
---

Prepara el trabajo de **$1**. Ejecuta estos pasos en orden y **detente en el
primero que falle**.

## 1. Verificar la clave

Confirma en Jira que **$1** existe y es una subtarea `Desarrollar backend`
asignada a mí. Si da 404, el tablero se renumeró: reporta la clave correcta y
detente.

Obtén el título de la HU padre para construir el slug.

## 2. Proteger el trabajo ajeno

En `../backend-monolito-francos`:

```bash
git status --short --branch
```

Si hay cambios rastreados que no pertenecen a esta incidencia: **detente y
repórtalos**. No los descartes, no los reviertas y no uses `git stash`,
`git reset --hard`, `git clean` ni `git restore` — están denegados por
configuración, y con razón: el repositorio puede estar compartido.

## 3. Actualizar develop

```bash
git fetch --prune origin
git switch develop
git pull --ff-only origin develop
```

Si el `pull --ff-only` falla, hay divergencia local en `develop`: **detente y
repórtalo.** No fuerces nada.

Y acto seguido, **obligatorio** (regla de oro del manual de Prisma del equipo):

```bash
pnpm exec prisma migrate deploy
pnpm exec prisma generate
```

`migrate deploy` aplica solo las migraciones que trajo el pull y que aun no estan en tu
base local; es seguro repetirlo. Saltarse esto es lo que produce los errores
`Property X does not exist on type`. Detalle en la skill `prisma-migraciones`.

## 4. Crear la rama

Una incidencia = una rama = un PR. Comprueba primero que no exista ya
(`git branch -a | grep $1`); si existe, úsala en lugar de crear otra.

- **`feature/$1-slug`** para funcionalidad nueva.
- **`fix/$1-slug`** **solo** si corriges algo que ya se fusionó en `develop`. Si no
  hay entrega previa fusionada, es `feature/`, no `fix/`.

El slug sale del título de la HU, en minúsculas y con guiones. La clave es la de
la **subtarea**, no la de la HU.

Nunca desde `main`. Nunca hacia `main`.

```bash
git switch -c feature/$1-slug
```

## 5. Escribir la ficha

Crea `specs/$1-slug.md` desde `specs/TEMPLATE.md` con el resultado de
`/task-audit`. Obligatorio:

- Los criterios numerados `CA-1`, `CA-2`... descompuestos del párrafo de la HU.
- Los tres bloques: **hechos auditados**, **supuestos**, **decisiones pendientes**.
- Fuera de alcance explícito.
- El rol que necesita cada endpoint nuevo (`RolesGuard` deniega por defecto).

Si quedan decisiones pendientes que afectan al diseño, la ficha lo dice y el
plan técnico queda como "sin definir": **no se programa con criterios ambiguos.**

## 6. Sincronizar Jira

Transiciona **$1** a *En curso* y comenta la rama creada. Esto está autorizado en
automático para mis propias subtareas.

No toques la HU padre ni las subtareas de otras personas.

## Al terminar

Resume: rama creada, ficha escrita, qué decisiones quedan abiertas y si se puede
pasar a `/task-implement` o hay que resolver algo antes.
