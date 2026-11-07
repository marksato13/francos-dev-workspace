# Instalación y comprobación del entorno

## Instalación

Clonar como **hermano** de los repos de código, porque las rutas de
`.claude/settings.json` son relativas:

```
PY - PERFIL DE EGRESO -DEV/
├── francos-dev-workspace/        este repo
├── backend-monolito-francos/     mi repo de trabajo
├── frontend-angular-francos/     solo lectura
└── frontend-cliente-angular/     solo lectura
```

Claude Code se abre desde la raíz de este repo. Los comandos `/task-*` y los
agentes solo existen si arranca aquí.

## Comprobar la configuración

| Dentro de Claude Code | Qué debe mostrar |
| --- | --- |
| `/` | Los comandos `/task-*` |
| `/mcp` | `jira` conectado; si no, reautenticar |
| `/permissions` | Reglas allow, ask y deny |
| `/context` | `CLAUDE.md` cargado |

Que Claude Code arranque sin errores no prueba que los permisos sean correctos:
revisar la lista `deny` de `.claude/settings.json`.

## Servidores MCP

| MCP | Para qué | Ámbito |
| --- | --- | --- |
| `jira` | Tablero OFT0 | usuario |
| `testsprite` | Generación y ejecución de pruebas | usuario |
| `claude.ai Claude Docs` | Documentos compartidos | usuario |

TestSprite arranca con
[`herramientas/launch-testsprite.ps1`](../herramientas/launch-testsprite.ps1), que
lee `TESTSPRITE_API_KEY` de las variables de usuario de Windows. La clave no está
en ningún archivo del repo.

## Ver dónde estoy

```powershell
pwsh -NoProfile -File herramientas/estado.ps1
```

Junta Orca, Git y GitHub sin usar IA. Jira queda fuera porque su MCP usa OAuth;
para incluirlo, usar `/estado` dentro de Claude Code. Detalle de Orca en
[`orca.md`](orca.md).

## Documentos

Los PDF que condicionan cómo se trabaja van a
[`documentos/`](../documentos/LEEME.md). `documentos/privado/` está en el
`.gitignore` para lo que lleve datos personales o credenciales.
