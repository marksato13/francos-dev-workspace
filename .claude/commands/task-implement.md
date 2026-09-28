---
description: Implementa el alcance aprobado de una subtarea OFT0 en el backend
argument-hint: OFT0-345
---

Implementa **$1**. Delega en el subagente `backend-implementer`.

## Condiciones para empezar

Verifica las cuatro antes de tocar código. Si falla alguna, **detente y
repórtalo**:

1. Existe `specs/$1-*.md` con criterios numerados y sin decisiones pendientes que
   afecten al diseño. **Sin ficha no se programa.**
2. La rama actual contiene la clave **$1** y no es `main` ni `develop`.
3. `git status` no muestra cambios ajenos.
4. La rama no está muy atrasada respecto a `origin/develop`
   (`git rev-list --left-right --count origin/develop...HEAD`). Si lo está,
   avísame antes de seguir: actualizar la rama requiere confirmación.

## Alcance

Solo los criterios `CA-x` marcados como **ausente** o **parcial** en la ficha. El
cambio mínimo correcto. No refactorices de paso, no amplíes, no arregles lo que
no se pidió.

Si durante la implementación aparece algo fuera de alcance que hay que arreglar,
**anótalo en la ficha como hallazgo y sigue con lo tuyo.** No lo implementes.

## Recordatorios del estado de `develop`

- Guards JWT + RBAC ya son **globales** (PR #9): no añadas `@UseGuards`.
- **`RolesGuard` deniega por defecto si falta `@Roles`** (PR #12): todo endpoint
  nuevo necesita su decorador o queda inaccesible.
- El repo está a **0 warnings de lint** y el job `lint` es bloqueante.

## Migraciones

`pnpm exec prisma migrate dev` para crearlas. `migrate reset`, `db push` y
`db execute` están denegados.

Si el cambio toca persistencia, la migración va en el mismo PR.

## Pruebas

En el mismo PR. QA no tiene dueño: si tú no escribes la prueba, no existe. Cubre
el comportamiento nuevo y los errores relevantes.

## Contrato de API

Si cambias o eliminas un endpoint, un DTO o la forma de una respuesta, delega en
`frontend-contract-reader` para ver el impacto y **documéntalo como dependencia
en la ficha**. No edites los frontends: están denegados.

## Al terminar

Actualiza la ficha y resume por separado: **qué cambiaste**, **qué verificaste con
su resultado real** y **qué queda pendiente**.

No hagas commit, push ni PR. Eso es `/task-pr`. Pasa antes por `/task-verify`.
