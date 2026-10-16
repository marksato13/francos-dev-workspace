# Agentes, skills, comandos y MCP

Inventario real al **2026-10-16**. Si algo no está en esta tabla, no existe todavía.

---

## Agentes del workspace

En `.claude/agents/`. Son subagentes: se invocan desde los comandos, no se escriben a mano.

| Agente | ¿Edita? | Para qué |
| --- | --- | --- |
| `jira-task-auditor` | **No** | Audita una subtarea contra Jira, GitHub y el código. Descompone el párrafo de la HU en criterios `CA-x` |
| `backend-implementer` | Sí, solo backend | Implementa el alcance aprobado en la ficha |
| `backend-reviewer` | **No** | Replica las 5 puertas del CI y revisa el diff |
| `frontend-contract-reader` | **No** | Qué contrato de API consume el frontend antes de cambiar un endpoint |

Los tres de solo lectura **no tienen `Edit` ni `Write`** en su lista blanca de herramientas.
No es una convención de texto: es la definición del agente.

---

## Comandos

En `.claude/commands/`. Se escriben con `/` en Claude Code.

| Comando | Etapa | Agente |
| --- | --- | --- |
| `/estado` | Dónde estoy ahora | principal |
| `/sync` | Reconciliar Jira ↔ GitHub ↔ fichas | principal |
| `/task-inbox` | Qué me toca, por rank | principal |
| `/task-audit` | Auditar una subtarea | `jira-task-auditor` |
| `/task-start` | `develop` al día, rama, ficha | principal |
| `/task-implement` | Implementar | `backend-implementer` |
| `/task-verify` | Las 5 puertas del CI | `backend-reviewer` |
| `/task-pr` | Commit, push, PR, Jira | principal |

---

## Skills

### Del workspace — `.claude/skills/`

| Skill | Se carga cuando |
| --- | --- |
| `jira-task-flow` | Se menciona una clave OFT0, una HU, una rama o un PR |
| `ci-gates` | Al verificar, antes de commit/push, o si un PR sale en rojo |

### Globales — `~/.claude/skills/`

Instaladas en la máquina, disponibles en cualquier proyecto. Las relevantes aquí:

| Skill | Para qué |
| --- | --- |
| `orca-cli` | Operar worktrees, terminales y automatizaciones de Orca |
| `orchestration` | Coordinar varios agentes con seguimiento |
| `diagramas-arquitectura` | Diagramas `.drawio` para entregables |
| `diagramas-red` | Topologías con iconos oficiales |
| `meeting-transcript-analysis` | Transcribir y analizar reuniones en local |

El resto (`cisco-device-health`, `esxi`, `fortigate-firewall-audit`,
`configuring-pfsense-firewall-rules`, `audio-transcription`, `herdr`) son de otros proyectos
y no se activan en este.

---

## Servidores MCP

| MCP | Para qué | Estado |
| --- | --- | --- |
| `jira` | Tablero OFT0 — leer, comentar y transicionar mis subtareas | conectado |
| `testsprite` | Generar y ejecutar pruebas | conectado |
| `claude.ai Claude Docs` | Documentos compartidos | conectado |
| `zotero` | Bibliografía (tesis) | conectado |
| `geogebra` | Matemáticas (otro proyecto) | conectado |
| `figma` | Diseño | requiere autenticación |
| `clickup` | Otro tablero | requiere autenticación |

### TestSprite

Lanzado por `herramientas/launch-testsprite.ps1`, que:

1. Lee `TESTSPRITE_API_KEY` de las **variables de usuario de Windows**.
2. La pasa como `API_KEY` al proceso hijo.
3. Ejecuta `npx -y @testsprite/testsprite-mcp@latest`.

**La clave no está en ningún archivo versionado.** El script la lee del entorno y no la
imprime. Por eso el lanzador sí se puede versionar.

El mismo lanzador sirve para Claude Code y para OpenCode: un solo sitio que mantener.
Registrado en Claude Code con ámbito usuario, así que está disponible en cualquier carpeta.

Encaja con el flujo en `/task-verify`: las 5 puertas del CI siguen siendo la verdad, y
TestSprite ayuda a **escribir** las pruebas que faltan — recuerda que `Pruebas / QA` no
tiene dueño en este proyecto.

---

## Agentes de IA disponibles

| Agente | CLI | Autenticación |
| --- | --- | --- |
| `claude` | `C:\Users\markp\.local\bin\claude.exe` | OAuth |
| `codex` | `C:\Users\markp\AppData\Local\Programs\OpenAI\Codex\bin\codex.exe` | OAuth, `Personal (Plus)` |
| `opencode` | `C:\Users\markp\scoop\shims\opencode.exe` | instalado, sin credenciales en Orca |

Los tres se pueden lanzar dentro de un worktree de Orca con `--agent <id>`. El reparto según
presupuesto está en [`orca.md`](orca.md).

---

## Qué falta por crear

No existe todavía. Se crea **cuando haga falta de verdad**, no por adelantado:

| Pieza | Para qué | Cuándo tendría sentido |
| --- | --- | --- |
| Skill de pruebas con TestSprite | Convertir criterios `CA-x` en pruebas | Cuando TestSprite se haya usado en una tarea real y sepamos qué funciona |
| Agente `test-writer` | Escribir pruebas del comportamiento nuevo | Si escribir pruebas se vuelve el cuello de botella |
| Skill de convenciones del equipo | Reglas que salgan de los PDF de `documentos/acuerdos/` | Cuando haya acuerdos subidos y revisados |
| Agente `strategic-*` | Módulo BSC | Solo si me asignan trabajo de ese módulo |

**Criterio para añadir algo nuevo:** que haya fallado al menos una vez por no tenerlo. Un
agente creado "por si acaso" es una regla más que mantener sincronizada, y este workspace ya
tuvo que archivar media configuración por desincronización.
