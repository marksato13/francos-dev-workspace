---
name: prisma-migraciones
description: Reglas del equipo para migraciones de Prisma en el backend Francos. Usar al cambiar schema.prisma, al crear una migracion, despues de un git pull o un merge de develop, o cuando salgan errores de tipo "Property X does not exist on type".
---

# Migraciones de Prisma

Reglas del **manual de Git + Prisma del equipo** (`documentos/referencia/guia-git-prisma.pdf`),
contrastadas contra la configuración real del repositorio.

> El manual abre esta sección diciendo que seguir estas reglas evita el 95% de los
> problemas en proyectos con Prisma y Git en equipo. Esa es la razón de que estén aquí
> y no en la cabeza de nadie.

## Los dos papeles

Toda operación con Prisma depende de cuál de los dos estás haciendo:

| Papel | Situación | Comando |
| --- | --- | --- |
| **Creo la migración** | Yo cambié `schema.prisma` | `pnpm exec prisma migrate dev --name <descriptivo>` |
| **Recibo la migración** | Un compañero cambió el schema y yo hice `pull` | `pnpm exec prisma migrate deploy` |

Confundirlos es el error más caro: `migrate dev` sobre migraciones ajenas puede intentar
reescribir el historial.

## Cuando YO cambio el schema

```bash
# 1. en mi rama de tarea, nunca en develop
# 2. editar prisma/schema.prisma
pnpm exec prisma migrate dev --name add_visible_portal_b
pnpm exec prisma generate
pnpm start:dev                      # verificar que arranca
```

**El nombre de la migración es descriptivo, no un número.** `add_state_to_person`, no
`migration1`. Queda en el historial del equipo para siempre.

Al commitear: **`prisma/schema.prisma` y `prisma/migrations/` van en el MISMO commit.**
Nunca por separado. El manual lo dice sin ambigüedad:

> *"Siempre commitear la carpeta `prisma/migrations/` junto con los cambios de código. Sin
> las migraciones, tus compañeros no pueden actualizar su base de datos."*

## Cuando RECIBO cambios de otro

Esto es lo que más se olvida y lo que rompe el entorno:

```bash
git switch develop
git pull origin develop
git switch feature/OFT0-XXX-slug
git merge develop
pnpm exec prisma migrate deploy     # <- OBLIGATORIO
pnpm exec prisma generate           # <- OBLIGATORIO
pnpm start:dev
```

`migrate deploy` aplica **solo** las migraciones pendientes. Es seguro correrlo las veces
que haga falta, y por eso está permitido sin confirmación.

### Síntoma de que te lo saltaste

```
Property X does not exist on type ...
```

El cliente de Prisma está desactualizado. Solución:

```bash
pnpm exec prisma generate
```

Si persiste, regeneración forzada (pide confirmación porque borra la carpeta):

```bash
rm -rf generated/prisma
pnpm exec prisma generate
```

## Conflicto en `schema.prisma`

Pasa cuando dos personas tocan el mismo modelo. **No se elige un lado: se combinan los dos
campos.**

```prisma
<<<<<<< HEAD
model Person { id Int @id   email String }
=======
model Person { id Int @id   phone String }
>>>>>>> develop
```

Queda:

```prisma
model Person {
  id    Int    @id
  email String   // mio
  phone String   // del compañero
}
```

Y después, migración nueva que recoja la combinación:

```bash
pnpm exec prisma migrate dev --name merge_person_fields
```

## Lo que está bloqueado por configuración

| Comando | Estado | Por qué |
| --- | --- | --- |
| `prisma migrate deploy` | **permitido** | Solo aplica lo pendiente. Seguro y repetible |
| `prisma generate` / `validate` / `migrate status` / `studio` | permitido | No mutan nada |
| `prisma migrate dev` | **pide confirmación** | Crea migración: tiene que ser deliberado |
| `prisma db seed` | pide confirmación | Escribe datos |
| `rm -rf generated/prisma` | pide confirmación | Destructivo pero reversible con `generate` |
| **`prisma migrate reset`** | **denegado** | Borra la base entera |
| **`prisma db push`** | **denegado** | El manual lo reserva a *"prototipado rápido sin historial, desarrollo individual"*. En equipo desincroniza |
| **Borrar `prisma/migrations/` a mano** | **denegado** | Regla de oro del manual |
| **Editar un `migration.sql` ya creado** | **denegado** | El historial es inmutable |

Si algo está bloqueado, repórtalo. No busques un rodeo.

## Reglas de oro, literales del manual

1. **NUNCA** commitear sin incluir `prisma/migrations/`.
2. **SIEMPRE** `prisma migrate deploy` después de un `git pull`.
3. **SIEMPRE** `prisma generate` después de un migrate.
4. **NUNCA** cambios directos en la base sin crear migración.
5. **NUNCA** borrar archivos de `prisma/migrations/` manualmente.
6. **Un solo desarrollador** crea la migración por cada feature de schema — si otro ya la
   está haciendo, se coordina antes, no se duplica.
7. Nombres descriptivos: `add_state_to_person`, no `migration1`.
8. `schema.prisma` + `migration.sql` **juntos**, nunca por separado.

## Dónde encaja en el flujo

- `/task-start` — tras actualizar `develop`, corre `migrate deploy` + `generate`.
- `/task-implement` — si el alcance toca persistencia, `migrate dev` con nombre descriptivo.
- `/task-verify` — `migrate status` tiene que salir limpio. Si reporta pendientes o deriva,
  es bloqueante: el job `test-e2e` del CI corre `migrate deploy` y va a fallar.
- `/task-pr` — la carpeta `prisma/` entra completa en el commit.
