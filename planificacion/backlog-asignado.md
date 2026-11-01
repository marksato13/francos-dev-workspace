# Backlog asignado — auditado 2026-10-25

Fuente: Jira `oracle-f1.atlassian.net`, proyecto `OFT0`, orden por rank (`cf[10019] ASC`),
consulta `assignee = currentUser() AND issuetype = Subtask AND summary ~ "Desarrollar backend"`.
Contrastado con `origin/develop` del backend (`868c900`, PR #74) y `gh pr list` el mismo día.

> Reemplaza la auditoría del 2026-10-16.

## Resumen

**12 subtareas `Desarrollar backend`.** 6 en *Listo*, 2 en *En revisión* con PR abierto,
4 en *Por hacer*.

## Mis 12 subtareas, en orden de rank

| # | Subtarea | HU | Sprint | Jira | PR | Quién la hizo |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `OFT0-357` | HU-A-010 Actualizar estado de pedido | 1 | Listo | #45 (bersdecker) MERGED | **Roxwell**, no yo: él la pasó a En revisión (2026-10-17) y a Listo (2026-10-18) |
| 2 | `OFT0-409` | HU-A-023 Procesar pedidos para entrega | 3 | Listo (2026-10-25) | [#49](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/49) MERGED 2026-10-25 | yo |
| 3 | `OFT0-473` | HU-A-039 Gestionar datos de la empresa | 2 | Listo (2026-10-25) | [#38](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/38) MERGED 2026-10-18 | yo; Roxwell abrió el fix #72 (logo) |
| 4 | `OFT0-485` | HU-A-042 Gestionar usuario interno | 2 | Listo (2026-10-25) | [#39](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/39) MERGED 2026-10-18 | yo |
| 5 | `OFT0-493` | HU-A-044 Gestionar series de comprobantes | 2 | Listo (2026-10-25) | [#40](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/40) MERGED 2026-10-18 | yo |
| 6 | `OFT0-521` | HU-B-005 Consultar catálogo de productos | 2 | Listo | [#46](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/46) MERGED 2026-10-18 | yo |
| 7 | `OFT0-529` | HU-B-007 Crear pedido mediante carrito | 2 | Listo | [#53](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/53) MERGED 2026-10-26 | yo |
| 8 | `OFT0-537` | HU-B-009 Seleccionar tipo de comprobante | 3 | Listo (2026-11-01) | [#80](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/80) MERGED 2026-10-27 | yo |
| 9 | `OFT0-541` | HU-B-010 Generar comprobante | 3 | Por hacer | — | — |
| 10 | `OFT0-557` | HU-B-014 Solicitar reembolso | 2 | Listo | [#55](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/55) MERGED 2026-10-26 | yo |
| 11 | `OFT0-573` | HU-B-018 Actualizar dirección de entrega | 6 | Por hacer | — | — |
| 12 | `OFT0-577` | HU-B-019 Gestionar preferencias de notificaciones | 6 | Por hacer | — | — |

Los estados *Listo* de 409, 473, 485 y 493 los puse yo el 2026-10-25 (transición 41),
con un comentario en cada una que cita el PR mergeado (comentarios 10114 a 10117).

## Estado de los sprints

| Sprint | Fechas | Estado en Jira | Mis subtareas | Situación |
| --- | --- | --- | --- | --- |
| 1 | 14-sep → 25-sep | **active** (vencido hace 1 mes) | 357 | Listo (hecha por Roxwell, PR #45) |
| 2 | 28-sep → 09-oct | future | 473, 485, 493, 521, 529, 557 | 4 Listo; 529 y 557 en revisión |
| 3 | 12-oct → 16-oct | future | 409, 537, 541 | 409 Listo; 537 y 541 por hacer |
| 6 | 02-nov → 06-nov | future | 573, 577 | por hacer |

## Lo que cambió desde el 2026-10-16

- `OFT0-357` (Sprint 1) la resolvió Roxwell con el PR #45 sin que se reasignara en Jira:
  sigue a mi nombre. · *Evidencia:* changelog de OFT0-357 (14083, 14106).
- `OFT0-473`: Roxwell abrió el PR #72 `fix/OFT0-473-subir-logo-empresa` (2026-10-25), que
  cambia el contrato de `PUT /empresa` (ya no acepta `logo_url`) y añade `POST/DELETE
  /empresa/logo`.
- `develop` integró mis #38, #39, #40, #46 y #49.

## Sync 2026-11-01

- **Nadie me quitó subtareas:** las 12 siguen a mi nombre. Las HU padre (OFT0-265, 281, 284,
  286, 293, 295, 297, 298, 302, 306, 307) también están a mi nombre, desde que Piero las asignó
  el 2026-09-17. OFT0-286 pasó a Roxwell y volvió a mí el 2026-10-24 en un minuto (Andres
  Chavarri, changelog 14340/14343).
- Roxwell está moviendo las HU padre: OFT0-295 a *En curso* (2026-10-31) y OFT0-286 a
  *En revisión*, con la DoD tachada (2026-10-31).
- OFT0-537 a *Listo* (comentario 10161): el PR #80 entró el 2026-10-27.
- Nadie tiene ramas ni PRs de 541, 573 o 577.
- `develop` del backend en `db8c45c` (#87): +5 migraciones aplicadas en local, 50 en total.
  Ver #88 `20261031000000_ruta_comprobantes`.
- Frontends renombrados: ver `context/repos.md`.

## Siguiente tarea recomendada: `OFT0-541`

- 537 entregada y mergeada (PR #80, 2026-10-27).
- 541 (generar comprobante) depende de 537 y de que el pedido del portal exista (OFT0-533,
  Piero): conviene auditarla antes de programar.

## Las 4 subtareas reasignadas a Roxwell el 2026-10-16

`OFT0-345`, `OFT0-349`, `OFT0-353` y `OFT0-361`: ya no son mías. `bersdecker` es Roxwell.
La ficha `specs/OFT0-345-gestionar-producto.md` está en `specs/archivo/`.

## Trampas del tablero que siguen vigentes

1. Las subtareas tienen `description: null`: el criterio vive en la HU padre.
2. **Sprint 1 sigue `active` y vencido hace un mes**; los sprints 2 y 3 siguen `future`
   aunque sus fechas pasaron. Las fechas del tablero no sirven para planificar.
3. Una subtarea puede quedar a mi nombre aunque la haga otra persona (OFT0-357).
