# Equipo y reparto de responsabilidades

Auditado el **2026-10-16** contra Jira `oracle-f1.atlassian.net` (proyecto `OFT0`) y el
historial de `Proyecto-Aura/backend-monolito-francos`.

> Reemplaza la auditoría del 2026-09-28, que describía un equipo de 5 y un reparto que ya
> no se cumple.

## Mi rol: backend

Tengo 16 subtareas asignadas (2026-11-06): 12 `Desarrollar backend` y 4 de QA. Cero frontend y
cero diseño. Mi superficie es `backend-monolito-francos`.

## Quién es quién

El tablero y el repositorio usan identidades distintas. Esta tabla es el puente, y hace
falta para saber de quién es una rama antes de tocarla.

| Persona | Handle GitHub | Rol observado |
| --- | --- | --- |
| Ruben Mark Salazar Tocas (yo) | `marksato13` | Backend |
| Hilter Piero Lanche Cerron | `PieroLan` | **Infraestructura y CI/CD** |
| Jorge Andres Chavarri Centeno | `Andr3sChavarr1` | Backend — módulo `strategic` (BSC) |
| Roxwell Jesus Ramos Turpo | **`bersdecker`** | Frontend en Jira, **backend en la práctica** |
| *(sin nombre público)* | `JoelRM1408` | Backend — inventario, schemas |
| Pamela Vallejos Cotrina | — | Prototipos (no commitea) |

Piero aparece en Git con **dos identidades** (`Piero Lanche` y `Hilter Piero Lanche Cerron`):
al contar commits por autor salen como dos personas. Es una.

## Lo que entregó cada uno desde el 28-sep

```
git shortlog -sn origin/develop --since=2026-09-28
    20  Piero Lanche
    17  Andr3sChavarr1
    16  Hilter Piero Lanche Cerron   <- mismo Piero
     9  JoelRM1408
     6  bersdecker (Roxwell)
```

**71 commits en `develop`, ninguno mío.**

## Hecho auditado: 4 de mis subtareas pasaron a Roxwell

El 2026-09-28 tenía 16 subtareas. El 2026-10-16 tengo 12. Las cuatro de Sprint 1 figuran
ahora a nombre de **Roxwell Jesus Ramos Turpo**:

| Subtarea | Alcance | Estado | Evidencia |
| --- | --- | --- | --- |
| `OFT0-345` | HU-A-007 Gestionar producto | Listo | PR #31 MERGED por `bersdecker` |
| `OFT0-349` | HU-A-008 Activar/desactivar producto | Listo | PR #34 OPEN por `bersdecker` |
| `OFT0-353` | HU-A-009 Gestionar pedido | Por hacer | sin rama |
| `OFT0-361` | HU-A-011 Gestionar reembolso | Por hacer | sin rama |

*Evidencia de identidad:* `gh api users/bersdecker` → `name: Roxwell`.

**Supuesto:** que la reasignación fue una decisión del equipo ante la falta de avance, no un
error del tablero. *Confirma:* el usuario o el líder del proyecto. No se investigó el
historial de cambios de Jira.

**Consecuencia operativa:** dos de mis subtareas pendientes (`OFT0-357`, `OFT0-409`) dependen
de trabajo que ahora es de Roxwell y está sin empezar. No puedo desbloquearlas yo.

## Riesgo abierto: QA sigue sin dueño

La subtarea `Pruebas / QA` está sin asignar en las HU auditadas. La calidad de mi entrega la
sostienen dos cosas:

1. El CI del backend — 5 puertas, `lint` bloqueante.
2. Las pruebas que yo escriba en el propio PR.

**No delego la verificación.** `/task-verify` antes de cualquier PR, y las pruebas del
comportamiento nuevo entran en el mismo PR que el código.

## Límites de mi trabajo

- **Edito:** `backend-monolito-francos`.
- **Leo, no edito:** los frontends. Solo para entender qué contrato de API esperan.
- **No asumo trabajo de otros.** Si hace falta un cambio de frontend, se documenta como
  dependencia y se reporta.
- **No toco ramas ajenas.** Antes de borrar o prunar, comprobar autor y contenido según
  `orchestration/task-lifecycle.md`.
