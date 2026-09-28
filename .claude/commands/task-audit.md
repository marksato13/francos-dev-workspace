---
description: Audita una subtarea OFT0 contra Jira, GitHub y el codigo real, sin modificar nada
argument-hint: OFT0-345
---

Audita la incidencia **$1** sin modificar nada.

Delega en el subagente `jira-task-auditor`. Pásale la clave y estas
instrucciones.

## 1. Resolver la clave

Verifica que **$1** existe en Jira. El tablero OFT0 se renumeró: si da 404, busca
la HU por su título y reporta la clave correcta antes de seguir. No adivines.

Si **$1** es una HU en lugar de una subtarea, identifica su subtarea
`Desarrollar backend` y audita esa.

## 2. Leer el alcance completo

Las subtareas tienen `description: null`. **Lee la HU padre** (`parent`) para
obtener el criterio de aceptación.

Descompón ese párrafo único en criterios numerados `CA-1`, `CA-2`... verificables
uno por uno. Este es el entregable más importante de la auditoría.

## 3. Contrastar contra el código

En `../backend-monolito-francos`, con `origin/develop` actualizado
(`git fetch --prune origin`), clasifica cada criterio:

| Criterio | Estado | Evidencia |
| --- | --- | --- |
| CA-1 | cubierto / parcial / ausente / no verificable | `archivo:línea` |

El estado en Jira no es evidencia. El código sí.

## 4. Buscar trabajo previo

- Ramas remotas que citen la incidencia o su slug.
- `gh pr list --state all --search "<clave>"`.
- Si hay rama previa: `git rev-list --left-right --count origin/develop...<rama>`
  para medir el atraso, y qué cambió en `develop` mientras tanto.

Un PR **cerrado sin fusionar** no cuenta como cubierto. Dilo explícitamente.

## 5. Comprobar el contexto de seguridad

Los guards JWT + RBAC son globales (PR #9) y `RolesGuard` deniega por defecto si
falta `@Roles` (PR #12). Si el alcance añade endpoints, comprueba qué rol
necesitan y si está declarado.

## 6. Impacto en frontend

Si el alcance cambia un contrato de API, delega en `frontend-contract-reader`
para saber quién lo consume. Es una **dependencia a comunicar**, no algo a
arreglar.

## Entrega

Hallazgos por severidad, con `archivo:línea`. Cierra con **tres bloques
separados**:

- **Hechos auditados** — cada uno con evidencia verificable.
- **Supuestos** — y quién debe confirmarlos.
- **Decisiones pendientes** — y quién decide.

Si necesitas que yo aclare algo, **detente y pregúntalo en el informe**; no
inventes la respuesta ni asumas la interpretación más cómoda.

No escribas la ficha todavía: eso lo hace `/task-start`.
