# Equipo y reparto de responsabilidades

Auditado el **2026-09-28** contra Jira `oracle-f1.atlassian.net`, proyecto
`OFT0`, con la cuenta `712020:ef37d90b-c74e-42fc-88fd-f3caf818b5bf`.

## Mi rol: backend

De las 30 incidencias asignadas a mi cuenta:

| Tipo de trabajo | Subtareas asignadas |
| --- | --- |
| `Desarrollar backend` | **16** |
| `Desarrollar frontend` | 0 |
| `Pruebas / QA` | 0 |
| `Diseñar prototipo funcional` | 0 |

Las otras 14 incidencias son las Historias padre, asignadas a mi cuenta a nivel
de HU pero cuyo trabajo de implementación se reparte en subtareas.

**Conclusión: soy backend puro.** No se me asigna frontend, diseño ni QA.

## Reparto del equipo

Cada Historia se descompone siempre en las mismas 4 subtareas:

| Subtarea | Responsable |
| --- | --- |
| Diseñar prototipo funcional | Pamela Vallejos Cotrina |
| **Desarrollar backend** | **Ruben Mark Salazar Tocas (yo)** |
| Desarrollar frontend | Roxwell Jesus Ramos Turpo |
| Pruebas / QA | *sin asignar* |

Verificado en las HU OFT0-249, OFT0-250 y OFT0-293. Evidencia: subtareas
OFT0-344/345/346/347, OFT0-348/349/350/351 y OFT0-520/521/522/523.

## Riesgo abierto: QA no tiene dueño

En las tres HU auditadas la subtarea `Pruebas / QA` está **sin asignar**
(OFT0-347, OFT0-351, OFT0-523). En la práctica, la calidad de mi entrega la
sostienen dos cosas y nada más:

1. El CI del backend (5 puertas, `lint` bloqueante).
2. Las pruebas que yo escriba en el propio PR.

Consecuencia operativa: **no delego la verificación.** `/task-verify` es
obligatorio antes de abrir cualquier PR, y las pruebas del comportamiento nuevo
entran en el mismo PR que el código.

## Límites de mi trabajo

- **Edito:** `backend-monolito-francos`.
- **Leo, no edito:** los frontends. Los consulto solo para entender qué contrato
  de API esperan y detectar incompatibilidades antes de cambiar un endpoint.
- **No asumo trabajo de otros.** Si una tarea necesita que el frontend cambie,
  se documenta como dependencia en la ficha y se reporta; no se implementa.
