# OFT0-XXX — <título de la HU padre>

> **Regla de esta ficha:** separa siempre lo que **verificaste** de lo que
> **supones**. Todo hecho lleva evidencia (`archivo:línea`, commit o salida de
> comando). Un supuesto sin confirmar nunca se escribe como hecho.

## Identificación

| | |
| --- | --- |
| Subtarea backend | `OFT0-XXX` |
| HU padre | `OFT0-YYY` — <título> |
| Épica | `OFT0-ZZZ` — <módulo> |
| Sprint | |
| Rama | `feature/OFT0-XXX-slug` |
| Commit base de `develop` | |
| Fecha de auditoría | |

## Criterios de aceptación descompuestos

La HU trae el alcance en un párrafo único. Aquí se descompone en criterios
verificables uno por uno.

| # | Criterio | Estado | Evidencia |
| --- | --- | --- | --- |
| CA-1 | | cubierto / parcial / ausente / no verificable | `archivo:línea` |
| CA-2 | | | |

## Hechos auditados

Solo lo que comprobaste, con su evidencia.

- **Hecho:** … · *Evidencia:* `src/...:42`
- **Hecho:** … · *Evidencia:* salida de `git log -1` → `<sha>`

## Supuestos

Lo que estás asumiendo porque no se pudo verificar. Cada uno con **quién debe
confirmarlo**.

- **Supuesto:** … · *Confirma:* <persona o rol>

## Decisiones pendientes

Lo que hay que decidir antes o durante la implementación. Cada una con **quién
decide**.

- **Decisión:** … · *Decide:* <persona o rol> · *Bloquea:* sí / no

## Alcance

Qué entra en esta entrega. Solo los criterios marcados como ausente o parcial.

## Fuera de alcance

Qué **no** entra, explícitamente, para que nadie lo espere en la revisión.

## Plan técnico

Capas y archivos a tocar. Si hay decisiones pendientes que afectan al diseño:
*"Sin definir. No se programa hasta cerrar las decisiones pendientes."*

| Capa | Archivos |
| --- | --- |
| `domain` | |
| `application` | |
| `infrastructure` | |
| `presentation` | |

## Autorización de endpoints

`RolesGuard` deniega por defecto cuando falta `@Roles` (PR #12). Todo endpoint
nuevo tiene que declarar su rol o queda inaccesible.

| Endpoint | Método | Roles requeridos |
| --- | --- | --- |

## Migraciones

¿Cambia la persistencia? Nombre de la migración y qué hace. Se crean con
`pnpm exec prisma migrate dev`.

## Dependencias con el frontend

Si esto cambia un contrato de API: qué cambia, quién lo consume y **a quién hay
que avisar**. No se arregla el frontend desde aquí.

## Plan de pruebas

| Prueba | Tipo | Estado |
| --- | --- | --- |
| | unitaria / e2e | pendiente / pasa / falla |

## Verificación

Marca solo lo que ejecutaste. **Lo que no se corrió se deja sin marcar y se
anota por qué.**

- [ ] `pnpm build`
- [ ] `pnpm lint:check`
- [ ] `pnpm format:check`
- [ ] `pnpm test`
- [ ] `pnpm test:e2e`
- [ ] `docker build` + smoke
- [ ] `pnpm exec prisma migrate status`
- [ ] `git diff --check`
- [ ] Sin `.env`, secretos, `dist/`, caches ni logs en el diff

No ejecutado y por qué:

## Riesgos

## Entrega

| | |
| --- | --- |
| PR | |
| Estado del CI | |
| Jira | comentado / transicionado |
