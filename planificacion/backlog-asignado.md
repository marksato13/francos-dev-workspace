# Backlog asignado — auditado 2026-10-16

Fuente: Jira `oracle-f1.atlassian.net`, proyecto `OFT0`, orden por rank (`cf[10019] ASC`).
Contrastado contra `origin/develop` del backend el mismo día.

> Esta auditoría **reemplaza** la del 2026-09-28. El reparto cambió.

## Resumen

**12 subtareas `Desarrollar backend`. Las 12 en `Por hacer`. Ninguna tiene rama.**

Eran 16. Cuatro se reasignaron a Roxwell — ver abajo.

## Mis 12 subtareas, en orden de rank

| # | Subtarea | HU padre | Alcance | Sprint | ¿Bloqueada? |
| --- | --- | --- | --- | --- | --- |
| 1 | `OFT0-357` | OFT0-252 | HU-A-010 Actualizar estado de pedido | 1 | **Sí** — depende de OFT0-353 |
| 2 | `OFT0-409` | OFT0-265 | HU-A-023 Procesar pedidos para entrega | 3 | **Sí** — depende de pedidos |
| 3 | `OFT0-473` | OFT0-281 | HU-A-039 Gestionar datos de la empresa | 2 | **No** |
| 4 | `OFT0-485` | OFT0-284 | HU-A-042 Gestionar usuario interno | 2 | No |
| 5 | `OFT0-493` | OFT0-286 | HU-A-044 Gestionar series de comprobantes | 2 | No |
| 6 | `OFT0-521` | OFT0-293 | HU-B-005 Consultar catálogo de productos | 2 | No |
| 7 | `OFT0-529` | OFT0-295 | HU-B-007 Crear pedido mediante carrito | 2 | Parcial — catálogo primero |
| 8 | `OFT0-537` | OFT0-297 | HU-B-009 Seleccionar tipo de comprobante | 3 | Sí — series primero |
| 9 | `OFT0-541` | OFT0-298 | HU-B-010 Generar comprobante | 3 | Sí — series + tipo |
| 10 | `OFT0-557` | OFT0-302 | HU-B-014 Solicitar reembolso | 2 | Sí — pedidos |
| 11 | `OFT0-573` | OFT0-306 | HU-B-018 Actualizar dirección de entrega | 6 | No |
| 12 | `OFT0-577` | OFT0-307 | HU-B-019 Gestionar preferencias de notificaciones | 6 | No |

## Estado de los sprints

| Sprint | Fechas | Mis subtareas | Situación |
| --- | --- | --- | --- |
| 1 | 14-sep → 25-sep | 1 (`357`) | **vencido hace 3 semanas**, sigue `active` |
| 2 | 28-sep → 09-oct | **6** | **vencido hace 1 semana**, ninguna empezada |
| 3 | 12-oct → **16-oct** | 3 | **vence hoy**, ninguna empezada |
| 6 | 02-nov → 06-nov | 2 | futuro |

**9 subtareas atrasadas** entre Sprint 2 y 3.

## Siguiente tarea recomendada: `OFT0-473`

No es la primera por rank, y hay una razón verificada:

- `OFT0-357` (rank 1) necesita que exista la gestión de pedidos: **`OFT0-353` es de Roxwell
  y está `Por hacer`**. No depende de mí.
- `OFT0-409` (rank 2) depende de lo mismo.
- **`OFT0-473` es la primera sin dependencias ajenas.**

Además:

- Pertenece a Sprint 2, que es el bucket más atrasado (6 pendientes).
- El modelo `Empresa` **ya existe** en `prisma/schema.prisma`.
- No hay ningún controlador que toque empresa: `git grep -il "empresa"` sobre
  `src/modules/*/presentation/controllers` no devuelve nada. Es trabajo virgen, sin
  riesgo de colisión.
- Desbloquea `OFT0-493` (series de comprobantes), que es configuración del mismo bloque.

Rama a crear:

```
feature/OFT0-473-gestionar-datos-de-la-empresa
```

## Las 4 subtareas que ya no son mías

Reasignadas a **Roxwell Jesus Ramos Turpo**. Verificado el 2026-10-16:

| Subtarea | Alcance | Estado hoy | Evidencia en GitHub |
| --- | --- | --- | --- |
| `OFT0-345` | HU-A-007 Gestionar producto | **Listo** | PR #31 `feature/OFT0-345-gestionar-producto`, **MERGED**, autor `bersdecker` |
| `OFT0-349` | HU-A-008 Activar/desactivar producto | **Listo** | PR #34 `feature/OFT0-349-...`, **OPEN** desde 11-oct, autor `bersdecker` |
| `OFT0-353` | HU-A-009 Gestionar pedido | Por hacer | sin rama |
| `OFT0-361` | HU-A-011 Gestionar reembolso | Por hacer | sin rama |

`bersdecker` **es Roxwell**: `gh api users/bersdecker` devuelve `name: Roxwell`.

Nota: `OFT0-349` figura como `Listo` en Jira pero su PR #34 sigue **abierto**. El tablero
va por delante del repositorio.

**Consecuencia:** la ficha `specs/OFT0-345-gestionar-producto.md` quedó obsoleta. Se archivó
en `specs/archivo/`. No la uses.

## Trampas del tablero que siguen vigentes

1. **Las 12 subtareas tienen `description: null`.** El criterio de aceptación vive solo en
   la HU padre, y viene como un párrafo único con muchas capacidades mezcladas. Hay que
   descomponerlo en `CA-1`, `CA-2`… antes de programar.
2. **Varias HU padre no son mías.** `OFT0-252` es de Roxwell. Para auditarlas hay que leer
   el padre explícitamente.
3. **Sprint 1 sigue `active` y vencido hace tres semanas.** Las fechas del tablero no son
   fiables para planificar.
4. **Mi `develop` local se quedó 71 commits atrás** entre el 28-sep y el 16-oct. Actualizar
   antes de cualquier rama es obligatorio, no opcional.
