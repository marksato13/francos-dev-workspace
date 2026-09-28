# francos-dev-workspace

Plano de control para el desarrollo **backend** del proyecto OFT0 (Francos).
No contiene código de producto: contiene la planificación, los agentes, las
skills y las fichas con las que se trabaja cada incidencia Jira.

Se opera desde **Claude Code**. Reemplaza al `.opencode/` que vivía dentro del
repositorio del backend.

## Instalación

Clonar como **hermano** de los repos de código. La estructura tiene que quedar así,
porque las rutas de `.claude/settings.json` son relativas:

```
PY - PERFIL DE EGRESO -DEV/
├── francos-dev-workspace/        <- este repo
├── backend-monolito-francos/     <- mi repo de trabajo
├── frontend-francos/             <- solo lectura
└── frontend-next-francos/        <- solo lectura
```

Luego, desde la raíz del workspace:

```bash
claude
```

El servidor MCP de Jira ya está configurado **a nivel de usuario**, así que está
disponible en cualquier carpeta; este repo no lo declara para no duplicarlo. El
OAuth de Atlassian caduca cada cierto tiempo: si las herramientas `mcp__jira__*`
desaparecen, hay que reautenticar con `/mcp`. No significa que se haya perdido el
acceso.

## Comandos

| Comando | Qué hace | Agente |
| --- | --- | --- |
| `/task-inbox` | Lista y prioriza mis subtareas backend por rank | principal |
| `/task-audit OFT0-345` | Audita la subtarea, su HU padre y el código real | `jira-task-auditor` |
| `/task-start OFT0-345` | `develop` al día, crea la rama y escribe la ficha | principal |
| `/task-implement OFT0-345` | Implementa el alcance aprobado | `backend-implementer` |
| `/task-verify OFT0-345` | Replica las 5 puertas del CI en local | `backend-reviewer` |
| `/task-pr OFT0-345` | Commit, push, PR a `develop` y sincroniza Jira | principal |

Los comandos son genéricos: una tarea nueva no crea un comando propio. Se
ejecuta `/task-inbox` para descubrirla y luego `/task-audit OFT0-XXX`.

## Agentes

| Agente | Edita | Para qué |
| --- | --- | --- |
| `jira-task-auditor` | **No** | Audita Jira + GitHub + código, descompone criterios |
| `backend-implementer` | Sí (solo backend) | Implementa el alcance aprobado |
| `backend-reviewer` | **No** | Replica el CI y revisa el diff |
| `frontend-contract-reader` | **No** | Qué contrato de API consume el frontend |

Los tres de solo lectura no tienen `Edit` ni `Write` en su lista blanca de
herramientas: la restricción no depende solo de patrones de Bash.

## Skills

| Skill | Cuándo se carga |
| --- | --- |
| `jira-task-flow` | Al mencionar una clave OFT0, una HU, una rama o un PR |
| `ci-gates` | Al verificar, antes de commit/push, o si un PR sale en rojo |

## Estructura

```
CLAUDE.md                     instrucciones raíz, siempre en contexto
.claude/settings.json         matriz de permisos (deny gana sobre allow)
.claude/agents/               4 agentes
.claude/commands/             6 comandos
.claude/skills/               2 skills
context/equipo.md             mi rol y el reparto del equipo, auditado
context/repos.md              rutas, stacks, scripts y estado de los 3 repos
context/jira.md               estructura del tablero, campos y trampas
planificacion/                backlog asignado y estado del sprint
specs/TEMPLATE.md             plantilla de ficha
specs/OFT0-XXX-slug.md        una ficha por incidencia
orchestration/                ciclo de vida y matriz de bloqueos
```

## Reglas que el workspace hace cumplir

- Rama desde `develop`, PR **solo** hacia `develop`. `main` está bloqueado en
  todas sus formas: push, checkout, switch, merge, rebase y `--base main`.
- Una incidencia Jira = una rama = un PR.
- `git reset --hard`, `git clean`, `git stash` y `git restore` están denegados:
  protegen el worktree de cambios ajenos.
- `gh pr merge` está denegado. El merge lo hace una persona en GitHub.
- `prisma migrate reset`, `db push` y `db execute` están denegados.
- El `.env` del backend no se puede leer y nunca se commitea.
- Los frontends son de solo lectura.
- `docker stop`, `docker rm` y `docker compose down -v` están denegados: hay un
  contenedor `persons_database` de otro proyecto que no se debe tocar.
- Commit, push, `gh pr create`, `pnpm lint`/`format` y `prisma migrate dev` piden
  confirmación.
- Jira: lectura libre; comentar y transicionar **mis propias subtareas** en
  automático; crear, editar, borrar, reasignar o registrar worklogs requiere
  petición explícita.

Matriz completa en [`orchestration/task-lifecycle.md`](orchestration/task-lifecycle.md).

## Verificar la configuración

Desde la raíz del workspace, dentro de `claude`:

```
/agents        deben aparecer los 4 agentes del proyecto
/mcp           jira debe estar conectado (si no, reautenticar)
/permissions   revisar allow / ask / deny
/task-inbox    el flujo arranca aqui
```

**Los comandos `/task-*` y los agentes solo existen si arrancaste Claude Code
dentro de esta carpeta.** La configuración de `.claude/` es por proyecto: si
abres Claude en el repo del backend o en la carpeta padre, no aparecerán.

Que Claude Code arranque sin errores **no prueba** que los permisos sean
correctos. Revisa la lista `deny` de `.claude/settings.json`.

## Estado conocido (2026-09-28)

- Mi rol es **backend**: 16/16 subtareas asignadas son `Desarrollar backend`.
- El tablero OFT0 **se renumeró**: las claves `OFT0-5x` están muertas.
- Siguiente tarea por rank: **`OFT0-345`** (HU-A-007 Gestionar producto).
- Sprint 1 está activo pero **vencido** desde el 2026-09-25.
- `develop` avanzó 26 commits en septiembre: CI con 5 puertas, guards globales
  JWT+RBAC, `RolesGuard` denegando por defecto y `lint` bloqueante.

Detalle en [`planificacion/sprint-1.md`](planificacion/sprint-1.md).
