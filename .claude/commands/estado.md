---
description: Vista unica de donde estoy: agentes de Orca, automatizaciones, backend, mis PRs y mis subtareas Jira
argument-hint: (sin argumentos)
---

Dime dónde estoy ahora mismo, en una sola pantalla.

Esto es **solo lectura**: no modifica código, no toca Jira, no hace commit. Es la foto, no
la acción.

## 1. Lo que no necesita IA

Ejecuta primero el script, que resuelve Orca, Git y GitHub sin gastar nada:

```powershell
pwsh -NoProfile -File herramientas/estado.ps1
```

Si falla, sigue a mano con `orca worktree ps --json`, `orca automations list --json`,
`git rev-list --left-right --count HEAD...origin/develop` y `gh pr list --author @me`.

## 2. Jira

Esto es lo que el script no puede hacer. Consulta:

```
project = OFT0 AND assignee = currentUser() AND issuetype = Subtask
AND summary ~ "Desarrollar backend"
ORDER BY cf[10019] ASC
```

Pide `summary`, `status`, `parent`, `customfield_10020`. **No pidas `description`**: las
subtareas lo tienen en `null`.

Muestra una tabla con subtarea, HU padre, sprint y estado. Marca:

- Las que estén en un **sprint ya vencido**.
- Las que tengan **rama o PR de otra persona** — eso significa que alguien está haciendo mi
  tarea. Ya pasó con `OFT0-345` y `OFT0-349`.
- Las que estén **bloqueadas por trabajo ajeno** según
  `planificacion/backlog-asignado.md`.

## 3. Contraste

Cruza las tres fuentes y señala solo lo que no cuadra:

| Síntoma | Qué significa |
| --- | --- |
| Jira dice `Listo`, el PR sigue abierto | el tablero va por delante del repo |
| Jira dice `Por hacer`, ya hay rama | alguien empezó sin actualizar el tablero |
| Mi rama está N commits atrás | hay que actualizar antes de seguir |
| PR con CI en rojo | eso bloquea la entrega, va primero |
| Worktree de Orca activo sin tarea Jira | trabajo sin trazabilidad |
| Automatización apagada | la vigilancia no está corriendo |

## 4. Entrega

Corta y en este orden:

```
LO QUE REQUIERE ACCION HOY
  1. ...
  2. ...

MI SIGUIENTE TAREA
  OFT0-XXX — por que esta

TODO LO DEMAS ESTA BIEN
  (una linea, sin detallar)
```

**Máximo tres cosas en "requiere acción".** Si hay más, prioriza por: CI en rojo > tarea
reasignada > sprint vencido > atraso de rama > todo lo demás.

Si no hay nada que hacer, dilo en una línea y para. No rellenes.
