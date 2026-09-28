# Sprint 1 — estado al 2026-09-28

| | |
| --- | --- |
| Estado en Jira | `active` |
| Inicio | 2026-09-14 |
| Fin | **2026-09-25** |
| Situación real | **vencido hace 3 días y sin cerrar** |
| Board | 2 |

## Objetivo declarado del sprint

1. Construir el núcleo transaccional del Portal A: autenticación interna, gestión
   de clientes/productos, ciclo de pedidos y pagos (incluyendo reembolsos), y
   control de stock de insumos y productos terminados.
2. Implementar el módulo de Gestión Estratégica de Negocio (BSC): documentos y
   plan estratégico, mapa estratégico, KPIs e iniciativas con su tablero de
   control y gráficos de seguimiento.

## Mi trabajo en este sprint

| Subtarea | HU | Alcance | Estado |
| --- | --- | --- | --- |
| `OFT0-345` | OFT0-249 | HU-A-007 Gestionar producto | Por hacer (HU **En curso**) |
| `OFT0-349` | OFT0-250 | HU-A-008 Activar, desactivar y reactivar producto | Por hacer |
| `OFT0-353` | OFT0-251 | HU-A-009 Gestionar pedido | Por hacer |
| `OFT0-357` | OFT0-252 | HU-A-010 Actualizar estado de pedido | Por hacer |
| `OFT0-361` | OFT0-253 | HU-A-011 Gestionar reembolso | Por hacer |

**5 subtareas, ninguna terminada, sprint vencido.**

## Lo que sí entró en `develop` durante el sprint

Aunque mis subtareas del sprint siguen en `Por hacer`, `develop` avanzó 26 commits
desde el 28 de agosto. Lo relevante:

| PR | Fecha | Qué entró |
| --- | --- | --- |
| #9 | 2026-09-25 | Guards globales JWT + RBAC (`HU-A-001 / OFT0-243`) |
| #10 | 2026-09-27 | Catálogo de roles completo en el seed |
| #11 | 2026-09-27 | Deuda de lint saldada: 547 → 0 |
| #12 | 2026-09-27 | `RolesGuard` deniega por defecto si falta `@Roles` |
| #13 | 2026-09-27 | Job `lint` pasa a bloqueante |
| #14 | 2026-09-27 | `.gitattributes` para finales de línea |
| #7 | 2026-09-20 | Pipeline de CI en GitHub Actions |

Es decir: la autenticación y la infraestructura de calidad del objetivo 1 **sí se
cumplieron**. Lo que falta es la gestión de productos, pedidos y reembolsos.

## Deuda del sprint anterior

`OFT0-55` (hoy `OFT0-345`) se trabajó en agosto: rama
`feature/OFT0-55-gestionar-producto`, commit `854f76e` con 25 archivos y +1461
líneas, y **PR #6 cerrado sin fusionar el 2026-08-30**.

Ese trabajo:

- Cita una clave Jira que ya no existe.
- Está **26 commits por detrás** de `develop`.
- Es anterior a los guards globales, al `RolesGuard` que deniega por defecto, al
  lint bloqueante y al CI.

**Decisión tomada el 2026-09-28: empezar limpio desde `develop`.** La rama vieja no
se rebasa. Lo que se conserva es el conocimiento, no el diff. Ver
`specs/OFT0-345-gestionar-producto.md`.

**Ejecutado el 2026-09-28:** la rama `feature/OFT0-55-gestionar-producto` se borro
en local y en remoto. El commit `854f76e` **sigue siendo recuperable** porque
GitHub conserva el ref del PR cerrado de forma permanente:

```bash
git ls-remote origin refs/pull/6/head   # -> 854f76e3c854ad7c1dd11a8caeedacfad5e5589b
git fetch origin refs/pull/6/head       # para recuperarlo si hiciera falta
```

Las 7 ramas ya fusionadas y las 2 ramas ajenas sin fusionar **no se tocaron**.

## Siguiente paso

`OFT0-345` — es la primera por rank, su HU es la única en curso, y desbloquea
tanto `OFT0-349` como `OFT0-521`.
