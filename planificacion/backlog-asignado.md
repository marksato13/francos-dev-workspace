# Backlog asignado — auditado 2026-09-28

Fuente: Jira `oracle-f1.atlassian.net`, proyecto `OFT0`, cuenta
`712020:ef37d90b-c74e-42fc-88fd-f3caf818b5bf`, orden por rank (`cf[10019] ASC`).

**30 incidencias asignadas:** 14 Historias + **16 subtareas `Desarrollar backend`**.
Las 16 subtareas son mi trabajo real. Las Historias son el contenedor del
criterio de aceptación.

## Mis 16 subtareas de backend, en orden de rank

| # | Subtarea | HU padre | Alcance | Épica | Sprint |
| --- | --- | --- | --- | --- | --- |
| 1 | `OFT0-345` | OFT0-249 | HU-A-007 Gestionar producto | 310 Catálogo | **1** |
| 2 | `OFT0-349` | OFT0-250 | HU-A-008 Activar, desactivar y reactivar producto | 310 Catálogo | **1** |
| 3 | `OFT0-353` | OFT0-251 | HU-A-009 Gestionar pedido | 311 Pedidos | **1** |
| 4 | `OFT0-357` | OFT0-252 | HU-A-010 Actualizar estado de pedido | 311 Pedidos | **1** |
| 5 | `OFT0-361` | OFT0-253 | HU-A-011 Gestionar reembolso | 311 Pedidos | **1** |
| 6 | `OFT0-473` | OFT0-281 | HU-A-039 Gestionar datos de la empresa | 316 Config. Sistema | 2 |
| 7 | `OFT0-485` | OFT0-284 | HU-A-042 Gestionar usuario interno | 316 Config. Sistema | 2 |
| 8 | `OFT0-493` | OFT0-286 | HU-A-044 Gestionar series de comprobantes | 316 Config. Sistema | 2 |
| 9 | `OFT0-521` | OFT0-293 | HU-B-005 Consultar catálogo de productos | 318 Compras Cliente | 2 |
| 10 | `OFT0-529` | OFT0-295 | HU-B-007 Crear pedido mediante carrito | 318 Compras Cliente | 2 |
| 11 | `OFT0-557` | OFT0-302 | HU-B-014 Solicitar reembolso | 318 Compras Cliente | 2 |
| 12 | `OFT0-409` | OFT0-265 | HU-A-023 Procesar pedidos para entrega | 315 Despacho | 3 |
| 13 | `OFT0-537` | OFT0-297 | HU-B-009 Seleccionar tipo de comprobante | 318 Compras Cliente | 3 |
| 14 | `OFT0-541` | OFT0-298 | HU-B-010 Generar comprobante | 318 Compras Cliente | 3 |
| 15 | `OFT0-573` | OFT0-306 | HU-B-018 Actualizar dirección de entrega | 319 Config. Cuenta | 6 |
| 16 | `OFT0-577` | OFT0-307 | HU-B-019 Gestionar preferencias de notificaciones | 319 Config. Cuenta | 6 |

Todas en estado `Por hacer`. La única HU en `En curso` es OFT0-249.

## Carga por sprint

| Sprint | Subtareas backend | Notas |
| --- | --- | --- |
| **1** (activo) | 5 | `endDate` 2026-09-25 → **vencido** |
| 2 | 6 | |
| 3 | 3 | |
| 6 | 2 | |

No hay trabajo asignado en sprints 4 y 5.

## Dependencias lógicas que conviene respetar

El rank ya las respeta, pero vale explicitarlas:

- **OFT0-345** (gestionar producto) antes de **OFT0-349** (activar/desactivar):
  no puedes cambiar el estado de algo que aún no se crea.
- **OFT0-345** antes de **OFT0-521** (consultar catálogo en Portal B): el catálogo
  público lee lo que el Portal A produce, incluido el flag `Visible en el Portal B`.
- **OFT0-353** (gestionar pedido) antes de **OFT0-357** (actualizar estado) y antes
  de **OFT0-361** (reembolso): el reembolso cuelga de un pedido existente.
- **OFT0-529** (carrito) antes de **OFT0-537** y **OFT0-541** (comprobantes).

## Anomalías del tablero

1. **Dos HU mías son de Roxwell.** `OFT0-251` (HU-A-009) y `OFT0-252` (HU-A-010)
   están asignadas a **Roxwell Jesus Ramos Turpo** a nivel de Historia, aunque sus
   subtareas de backend (`OFT0-353`, `OFT0-357`) son mías. Para auditarlas hay que
   leer el padre explícitamente.

2. **Las subtareas no tienen criterio propio.** Las 16 tienen
   `description: null`. Siempre hay que subir a la HU padre.

3. **Las 6 épicas están sin asignar** y en `Por hacer`, incluso aquellas cuyas HU
   ya están en curso. El estado de las épicas no es señal de nada.

4. **`Pruebas / QA` no tiene dueño** en ninguna HU auditada. La verificación es
   mía, vía CI y pruebas en el PR.

5. **Sprint 1 sigue abierto y vencido** (3 días al 2026-09-28).

## Advertencia de renumeración

El tablero se renumeró en algún momento entre agosto y septiembre de 2026. Las
claves de la serie `OFT0-5x` **están muertas**: `OFT0-55` devuelve 404.

Equivalencia conocida:

| Clave vieja | Clave actual |
| --- | --- |
| `OFT0-55` | HU `OFT0-249` / subtarea `OFT0-345` |

El repositorio conserva rastros de la numeración vieja: la rama
`feature/OFT0-55-gestionar-producto`, el commit `854f76e` y el PR #6 (cerrado).
Ninguno se vincula con el tablero actual.
