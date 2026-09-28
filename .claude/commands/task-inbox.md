---
description: Lista y prioriza mis subtareas de backend OFT0 pendientes, en orden de rank
argument-hint: (sin argumentos)
---

Consulta Jira y muéstrame qué me toca hacer, en el orden en que debería atacarlo.

## Consulta

Usa el MCP `jira` sobre `oracle-f1.atlassian.net` con este JQL:

```
project = OFT0 AND assignee = currentUser() AND issuetype = Subtask
AND summary ~ "Desarrollar backend" AND statusCategory != Done
ORDER BY cf[10019] ASC
```

`cf[10019]` es el Rank: **el orden que devuelve es el orden de prioridad.**

Pide los campos `summary`, `status`, `parent`, `customfield_10020` (Sprint) y
`updated`. No pidas `description`: las subtareas lo tienen en `null` y solo
infla la respuesta.

Si la respuesta es demasiado grande, guárdala y procésala con `jq` en vez de
volver a consultar.

## Qué muestras

Una tabla ordenada por rank:

| # | Subtarea | HU padre | Título de la HU | Sprint | Estado |
| --- | --- | --- | --- | --- | --- |

Agrupa por sprint y marca cuál es el sprint **activo**. Avisa si el sprint activo
ya pasó su `endDate`.

## Qué comprobar además

1. **Si alguna subtarea tiene una HU padre que no está asignada a mí**, márcala:
   su criterio de aceptación no me llega por la vía normal (pasa con OFT0-353 y
   OFT0-357).
2. **Si ya existe rama o PR** para alguna de las primeras de la lista:
   `git fetch --prune origin` en `../backend-monolito-francos`, luego
   `git branch -r` y `gh pr list --state all --limit 20`. Un PR cerrado sin
   fusionar significa trabajo no entregado.

## Al final

Recomiéndame **una sola** siguiente tarea, con una razón de una frase. No me des
un menú de opciones equivalentes: dime cuál y por qué.

No audites en profundidad aquí. Eso es `/task-audit`.
