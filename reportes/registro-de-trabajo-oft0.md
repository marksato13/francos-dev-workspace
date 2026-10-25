# Registro de trabajo — backend OFT0

Ruben Mark Salazar Tocas (`marksato13`), desarrollador backend del proyecto OFT0.
Repositorio de producto: [`Proyecto-Aura/backend-monolito-francos`](https://github.com/Proyecto-Aura/backend-monolito-francos).
Actualizado el 2026-10-25.

Este registro existe para poder justificar **qué hice, en qué rama y con qué evidencia**.
Todo dato sale de GitHub (`gh pr list`), de `git log` o de Jira; el detalle de cada tarea está
en su ficha de `specs/`.

## Cómo trabajo

Una subtarea Jira = una rama = un PR hacia `develop`. Nunca hago merge a `develop` ni a
`main`: el merge lo hace una persona en GitHub. Para cada tarea:

1. `/task-audit`: audito la subtarea, su HU padre y el código real; separo hechos,
   supuestos y decisiones pendientes.
2. `/task-start`: `develop` al día, rama `feature/OFT0-XXX-slug`, ficha en `specs/`.
3. `/task-implement`: implemento solo el alcance aprobado, con pruebas unitarias y e2e.
4. `/task-verify`: replico en local las puertas del CI (build, lint, test-unit, test-e2e
   sobre PostgreSQL 16 desechable, docker) y el agente `backend-reviewer` revisa el diff.
5. `/task-pr`: commit, push, PR a `develop`, CI en verde, comentario y transición en Jira
   (*En revisión*). Paso a *Listo* solo cuando el PR ya está mergeado (autorizado por el usuario el 2026-10-25).

Cuando `develop` avanza, traigo `develop` a **mis** ramas abiertas (merge, nunca rebase ni
force push), renombro mis migraciones para que queden después de las de `develop` y vuelvo a
verificar.

## Entregas

| PR | Subtarea | HU | Rama | Creado | Estado |
| --- | --- | --- | --- | --- | --- |
| [#38](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/38) | OFT0-473 | HU-A-039 Gestionar datos de la empresa | `feature/OFT0-473-gestionar-datos-empresa` | 2026-10-17 | mergeado 2026-10-18 (PieroLan) |
| [#39](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/39) | OFT0-485 | HU-A-042 Gestionar usuario interno | `feature/OFT0-485-gestionar-usuario-interno` | 2026-10-17 | mergeado 2026-10-18 (PieroLan) |
| [#40](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/40) | OFT0-493 | HU-A-044 Gestionar series de comprobantes | `feature/OFT0-493-gestionar-series-comprobantes` | 2026-10-17 | mergeado 2026-10-18 (PieroLan) |
| [#46](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/46) | OFT0-521 | HU-B-005 Consultar catálogo de productos | `feature/OFT0-521-consultar-catalogo-productos` | 2026-10-18 | mergeado 2026-10-18 (PieroLan) |
| [#49](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/49) | OFT0-409 | HU-A-023 Procesar pedidos para entrega | `feature/OFT0-409-procesar-pedidos-para-entrega` | 2026-10-18 | mergeado 2026-10-25 (PieroLan) |
| [#53](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/53) | OFT0-529 | HU-B-007 Crear pedido mediante carrito | `feature/OFT0-529-crear-pedido-mediante-carrito` | 2026-10-18 | abierto, CI 6/6 |
| [#55](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/55) | OFT0-557 | HU-B-014 Solicitar reembolso | `feature/OFT0-557-solicitar-reembolso` | 2026-10-18 | abierto, CI 6/6 (depende de #53) |

Fichas: `specs/OFT0-473-gestionar-datos-empresa.md`, `specs/OFT0-485-gestionar-usuario-interno.md`,
`specs/OFT0-493-gestionar-series-comprobantes.md`, `specs/OFT0-521-consultar-catalogo-productos.md`,
`specs/OFT0-409-procesar-pedidos-para-entrega.md`, `specs/OFT0-529-crear-pedido-mediante-carrito.md`,
`specs/OFT0-557-solicitar-reembolso.md`.

El PR #6 (`feature/OFT0-55-gestionar-producto`, 2026-08-30) está cerrado sin merge.

## Mantenimiento de las ramas abiertas

| Fecha | Qué | Ramas | Evidencia |
| --- | --- | --- | --- |
| 2026-10-18 | Merge de develop tras #40, #50 y #54; conflictos en `sales.module.ts` resueltos conservando las dos partes; migraciones renombradas tras las de develop | #49, #53, #40 | CI 6/6 en cada PR |
| 2026-10-24 | Aviso del equipo: en AWS solo corre `prisma migrate deploy`, no el seed. El rol `despacho` del #49 pasa a migración `20261024020000_rol_despacho` (idempotente); `fecha_entrega` renombrada a `20261024010000` | #49 | commit `2f6e2d5`; con solo `deploy` el rol existe; CI 6/6 (run 40166157358) |
| 2026-10-24 | Merge de develop (PRs #57 a #70) | #49 `84ea9cb`, #53 `890e160`, #55 `be4a0f0` | local: 931 / 921 / 955 unitarias, 567 / 562 / 595 e2e; CI de #49, #53 y #55 6/6 |

#53 y #55 no traen datos de referencia ni migraciones; el aviso no les aplica.

## Nota sobre la verificación local

Desde el 2026-10-24, en esta máquina `AppModule` arranca en más de 5 s y los `beforeAll` de
las e2e superan el timeout por defecto de Jest. Las e2e locales se corren con
`--runInBand --testTimeout=60000`; la prueba de referencia sigue siendo el CI del PR, que usa
la configuración normal.

## Pendiente

- 2026-10-25: pasé a *Listo* OFT0-409, 473, 485 y 493 (PR mergeados), con comentario en cada una (10114 a 10117).
- OFT0-357 (Sprint 1, HU-A-010) sigue a mi nombre en Jira, pero la hizo Roxwell (PR #45); él la movió a *Listo*.
- 2026-10-25: tras el merge del #49, conflicto en `sales.module.ts` de #53 y #55, resuelto en sus ramas (#53 `68a20bc`, #55 `5b3a1db`); los dos con CI 6/6 y MERGEABLE.
- Deriva ajena en `inventory.movimiento_insumo` (entró con el #73 de JoelRM1408): `migrate diff` la detecta; el CI no la revisa.
- Siguiente subtarea: OFT0-537 (HU-B-009 Seleccionar tipo de comprobante), desbloqueada
  porque las series del #40 ya están en `develop`.
