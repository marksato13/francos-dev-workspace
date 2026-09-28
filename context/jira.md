# Jira: estructura, campos y trampas

Sitio `oracle-f1.atlassian.net` · proyecto `OFT0` · board `2`.
Se opera con el MCP `jira`. Auditado el 2026-09-28.

## Jerarquía

```
Epic  (Módulo funcional, sin asignar)
 └─ Historia  "HU-A-007 Gestionar producto"   <- aquí vive el criterio de aceptación
     ├─ Subtask  Diseñar prototipo funcional   (Pamela)
     ├─ Subtask  Desarrollar backend           (yo)   <- aquí trabajo
     ├─ Subtask  Desarrollar frontend          (Roxwell)
     └─ Subtask  Pruebas / QA                  (sin asignar)
```

Las HU del **Portal A** (`HU-A-xxx`) son la operación interna de la empresa. Las
del **Portal B** (`HU-B-xxx`) son el portal público del cliente.

## Épicas donde tengo trabajo

| Epic | Módulo |
| --- | --- |
| OFT0-310 | Gestión de Ventas — Catálogo de Productos |
| OFT0-311 | Gestión de Ventas — Pedidos |
| OFT0-315 | Despacho |
| OFT0-316 | Configuración del Sistema |
| OFT0-318 | Compras del Cliente |
| OFT0-319 | Configuración de Cuenta |

## Campos personalizados relevantes

| Campo | ID | Uso |
| --- | --- | --- |
| Rank | `cf[10019]` | Orden de prioridad del backlog. `ORDER BY cf[10019] ASC` da el orden en que hay que atacar las tareas. |
| Sprint | `customfield_10020` | Array de sprints. Contiene `name`, `state`, `startDate`, `endDate` y `goal`. |

## JQL de mi backlog

```
project = OFT0 AND assignee = 712020:ef37d90b-c74e-42fc-88fd-f3caf818b5bf
ORDER BY cf[10019] ASC
```

Para solo las subtareas de backend que me toca implementar:

```
project = OFT0 AND assignee = currentUser() AND issuetype = Subtask
AND summary ~ "Desarrollar backend" AND statusCategory != Done
ORDER BY cf[10019] ASC
```

## Trampas confirmadas

### 1. El tablero se renumeró. Las claves viejas están muertas

`OFT0-55` **ya no existe** (`getJiraIssue OFT0-55` devuelve 404: *"La incidencia
no existe o no tienes permiso para verla"*). Lo que era OFT0-55 hoy es la HU
**OFT0-249** con subtarea backend **OFT0-345**.

Consecuencia: **nunca reutilizar una clave leída de una rama, un commit o un
documento viejo sin verificarla contra Jira primero.** El repo tiene una rama
`feature/OFT0-55-gestionar-producto` y un commit `854f76e` que citan la clave
muerta; ninguno se vincula con el tablero.

### 2. Las subtareas no tienen descripción

Las 16 subtareas `Desarrollar backend` asignadas a mí tienen `description: null`.
El criterio de aceptación vive **solo en la Historia padre**.

Consecuencia: **auditar una subtarea obliga a leer su `parent`.** Trabajar solo
con la subtarea es trabajar a ciegas.

### 3. Algunas subtareas mías cuelgan de HU que no son mías

`OFT0-353` y `OFT0-357` están asignadas a mí, pero sus padres `OFT0-251` y
`OFT0-252` no lo están. Su criterio de aceptación hay que pedirlo o leerlo
directamente del padre.

### 4. Los criterios de aceptación son un párrafo único

Las HU no usan lista de criterios: meten todo el alcance en una sola frase
larguísima con subordinadas. OFT0-249 encierra ~10 capacidades distintas en un
párrafo.

Consecuencia: **el primer paso de `/task-audit` es descomponer ese párrafo en
criterios numerados y verificables** y dejarlos escritos en la ficha. Sin eso no
hay forma de decir si la tarea está terminada.

### 5. Sprint 1 está activo pero vencido

`Sprint 1` tiene `state: active` y `endDate: 2026-09-25`. Al 2026-09-28 lleva
3 días vencido sin cerrar. No asumir que las fechas del sprint son fiables para
planificar.

### 6. El endpoint del MCP caduca

El MCP apunta a `https://mcp.atlassian.com/v1/sse`. Atlassian avisa que **después
del 30 de junio de 2026 ese transporte deja de estar soportado**; hay que
reapuntar a `https://mcp.atlassian.com/v2/mcp` y volver a autorizar OAuth.
La sesión OAuth además caduca sola cada cierto tiempo: si las herramientas
`mcp__jira__*` desaparecen, hay que reautenticar, no asumir que no hay acceso.

## Permisos de escritura

- **Automático** (autorizado por el usuario el 2026-09-28): comentar y
  transicionar **mis propias subtareas**.
- **Requiere petición explícita:** crear, borrar o reasignar incidencias, editar
  una HU padre, tocar incidencias de otra persona, registrar worklogs.
- **Nunca** inventar datos de Jira. Si el MCP falla, se reporta el fallo.
