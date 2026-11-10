# Backlog asignado — auditado 2026-11-06

Fuente: Jira `oracle-f1.atlassian.net`, proyecto `OFT0`, consulta
`assignee = currentUser() AND issuetype = Subtask`, y PR del backend en GitHub.

## Resumen

**16 subtareas: 12 `Desarrollar backend` y 4 de QA.** 10 en *Listo*, 1 en *En
revisión* y 5 en *Por hacer*, 2 de ellas por eliminar.

## Desarrollo backend

| Subtarea | HU | Sprint | Jira | PR | Quién la hizo |
| --- | --- | --- | --- | --- | --- |
| `OFT0-357` | HU-A-010 Actualizar estado de pedido | 1 | Listo | #45 | Roxwell; sigue a mi nombre en Jira |
| `OFT0-473` | HU-A-039 Gestionar datos de la empresa | 2 | Listo | [#38](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/38) | yo |
| `OFT0-485` | HU-A-042 Gestionar usuario interno | 2 | Listo | [#39](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/39) | yo |
| `OFT0-493` | HU-A-044 Gestionar series de comprobantes | 2 | Listo | [#40](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/40) | yo |
| `OFT0-521` | HU-B-005 Consultar catálogo de productos | 2 | Listo | [#46](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/46) | yo |
| `OFT0-529` | HU-B-007 Crear pedido mediante carrito | 2 | Listo | [#53](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/53) | yo |
| `OFT0-557` | HU-B-014 Solicitar reembolso | 2 | Listo | [#55](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/55) | yo |
| `OFT0-409` | HU-A-023 Procesar pedidos para entrega | 3 | Listo | [#49](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/49) | yo |
| `OFT0-537` | HU-B-009 Seleccionar tipo de comprobante | 3 | Listo | [#80](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/80) | yo |
| `OFT0-541` | HU-B-010 Generar comprobante | 3 | Por hacer | — | bloqueada por `OFT0-297` |
| `OFT0-573` | HU-B-018 Actualizar dirección de entrega | 6 | Por hacer | — | — |
| `OFT0-577` | HU-B-019 Gestionar preferencias de notificaciones | 6 | En revisión | [#111](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/111) | yo |

## QA

| Subtarea | Alcance | Sprint | Jira | PR |
| --- | --- | --- | --- | --- |
| `OFT0-581` | Entorno efímero y humo E2E | 6 | Listo | [#103](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/103) MERGED 2026-11-07 |
| `OFT0-586` | Humo E2E del portal de la empresa | 6 | En revisión | [#114](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/114) |
| `OFT0-582` | Contrato de la API, IDOR y datos inválidos | 6 | Por hacer | desbloqueada |
| `OFT0-583` | Playwright completo y bots sintéticos | 6 | Por hacer | descartada: por eliminar en Jira |
| `OFT0-584` | Triage con IA | 6 | Por hacer | descartada: por eliminar en Jira |

Pipeline descrito en [`context/qa.md`](../context/qa.md).

## Sprints

| Sprint | Fechas | Estado en Jira | Mis subtareas |
| --- | --- | --- | --- |
| 1 | 14-sep → 25-sep | active, vencido | 357 |
| 2 | 28-sep → 09-oct | future | 473, 485, 493, 521, 529, 557 |
| 3 | 12-oct → 16-oct | future | 409, 537, 541 |
| 6 | 02-nov → 06-nov | future | 573, 577, 581, 582, 583, 584 |

## Subtareas que ya no son mías

`OFT0-345`, `OFT0-349`, `OFT0-353` y `OFT0-361` se reasignaron a Roxwell
(`bersdecker`) el 2026-10-16.

## Trampas del tablero

1. Las subtareas tienen `description: null`: el criterio vive en la HU padre.
2. Sprint 1 sigue `active` y los sprints 2, 3 y 6 siguen `future` aunque sus
   fechas pasaron. Las fechas del tablero no sirven para planificar.
3. Una subtarea puede quedar a mi nombre aunque la haga otra persona (`OFT0-357`).
4. El tablero se renumeró una vez: verificar toda clave antes de usarla.
