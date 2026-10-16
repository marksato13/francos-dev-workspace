---
description: Reconcilia Jira, GitHub y las fichas locales, y reporta que cambio desde la ultima auditoria
argument-hint: (sin argumentos)
---

Dime qué cambió desde la última auditoría. Este comando **no modifica código** y **no toca
Jira**: solo lee, compara y actualiza la documentación del workspace.

Es el comando que se ejecuta **al empezar cualquier sesión** y el que corre la automatización
`OFT0 vigia Jira`.

## 1. Jira: qué tengo asignado hoy

```
project = OFT0 AND assignee = currentUser() AND issuetype = Subtask
AND summary ~ "Desarrollar backend"
ORDER BY cf[10019] ASC
```

Pide `summary`, `status`, `parent`, `customfield_10020` (Sprint). **No pidas
`description`**: las subtareas lo tienen en `null` y solo infla la respuesta.

Compara el resultado con la tabla de `planificacion/backlog-asignado.md` y reporta
**explícitamente**:

- **Subtareas que ya no son mías** — quién las tiene ahora. Esto ya pasó una vez con
  `OFT0-345`, `OFT0-349`, `OFT0-353` y `OFT0-361`: se reasignaron a Roxwell sin aviso.
- **Subtareas nuevas** que aparecieron.
- **Cambios de estado** respecto a lo documentado.
- **Cambios de sprint** o de rank.
- **Sprints vencidos** que siguen `active`, y cuántas de mis subtareas quedaron dentro.

## 2. GitHub: qué entró en `develop`

En `../backend-monolito-francos`:

```bash
git fetch --prune origin
git rev-list --left-right --count HEAD...origin/develop
gh pr list --state all --limit 30
```

Reporta:

- Cuántos commits de atraso llevo.
- PRs fusionados desde la última auditoría y **cuáles invalidan una ficha de `specs/`**.
  Un PR que cambia guards, lint, CI o el schema invalida cualquier ficha anterior.
- **Si alguna de mis claves ya tiene rama o PR de otra persona.** Eso significa que
  alguien está haciendo mi tarea: repórtalo arriba del todo.
- PRs abiertos que lleven días sin moverse.

## 3. Cruce Jira ↔ GitHub

Busca las tres incoherencias que ya se han dado en este proyecto:

1. **Jira dice `Listo` pero el PR sigue abierto.** Pasó con `OFT0-349` (PR #34).
2. **Jira dice `Por hacer` pero ya hay rama o PR.**
3. **Rama que cita una clave Jira que no existe.** El tablero se renumeró una vez:
   `OFT0-55` da 404. Verifica toda clave antes de darla por buena.

## 4. Fichas locales

Revisa `specs/*.md` y marca las que hayan quedado desfasadas: la subtarea ya no es mía, el
PR entró, o `develop` cambió lo que la ficha daba por cierto.

Una ficha obsoleta se mueve a `specs/archivo/` con una línea en
`specs/archivo/LEEME.md` diciendo por qué. **No se reutiliza una ficha archivada**: se
re-audita.

## 5. Actualizar la documentación

Si hubo cambios, actualiza:

- `planificacion/backlog-asignado.md` — la tabla de subtareas y el estado de los sprints.
- `context/equipo.md` — solo si cambió el reparto o apareció un contribuyente nuevo.

Todo hecho con su evidencia: clave Jira, número de PR, `archivo:línea` o salida de comando.
**Nunca escribas un cambio que no verificaste.**

## 6. Entrega

Empieza por lo que me afecta y no sabía:

```
CAMBIOS QUE ME AFECTAN
  - ...

MI SIGUIENTE TAREA
  OFT0-XXX — por qué esta y no la primera por rank

ESTADO
  develop: N commits de atraso
  sprints vencidos: ...
  fichas archivadas: ...
```

Cierra recomendando **una sola** siguiente acción. Si no cambió nada, dilo en una línea.

No hagas commit de los cambios de documentación salvo que te lo pida.
