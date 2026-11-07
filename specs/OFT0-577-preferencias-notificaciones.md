# OFT0-577 — HU-B-019 Gestionar preferencias de notificaciones

> **Regla de esta ficha:** separa siempre lo que **verificaste** de lo que
> **supones**. Todo hecho lleva evidencia (`archivo:línea`, commit o salida de
> comando). Un supuesto sin confirmar nunca se escribe como hecho.

## Identificación

| | |
| --- | --- |
| Subtarea backend | `OFT0-577` |
| HU padre | `OFT0-307` — HU-B-019 Gestionar preferencias de notificaciones |
| Sprint | 6 (02-nov → 06-nov) |
| Rama | `feature/OFT0-577-preferencias-notificaciones` |
| Commit base de `develop` | `ce73d7d` |
| Fecha de auditoría | 2026-11-06 |

## Criterios de aceptación descompuestos

La HU dice: *"Como cliente, quiero activar o desactivar, desde la configuración
de mi perfil, las notificaciones de cambio de estado de mis pedidos, para
recibir únicamente la información que me interesa."*

| # | Criterio | Estado | Evidencia |
| --- | --- | --- | --- |
| CA-1 | El cliente consulta su preferencia; activa por defecto | ausente | No hay campo en `User` (`prisma/schema.prisma`) |
| CA-2 | La cambia con `GET` y `PATCH /portal/notificaciones/preferencias`, rol `cliente` | ausente | `portal-notificaciones.controller.ts` solo tiene listar y marcar leída |
| CA-3 | Desactivada, al despachar no se crea el aviso | ausente | `marcarEnCamino` lo crea siempre que hay `userId` (`prisma-pedido.repository.ts`) |
| CA-4 | Activada, el comportamiento es el de hoy | cubierto | `test/despacho-pedidos.e2e-spec.ts`, «pasa el pedido a en camino y notifica…» |
| CA-5 | Un cliente solo cambia la suya | ausente | Se resuelve con `@CurrentUser()`; el `userId` nunca viene de la petición |

## Hechos auditados

- **Hecho:** el único aviso de cambio de estado del pedido es `pedido_en_camino`;
  se crea en `marcarEnCamino`, dentro de la transacción del cambio de estado.
  · *Evidencia:* `src/modules/sales/infrastructure/repositories/prisma-pedido.repository.ts`, `despachar-pedido.use-case.ts:30`
- **Hecho:** `marcarEntregado` no notifica. · *Evidencia:* mismo repositorio.
- **Hecho:** los avisos de pago y reembolso se crean por otros caminos y esta
  preferencia no los toca. · *Evidencia:* `prisma-pedido.repository.ts`, `prisma-reembolso.repository.ts`
- **Hecho:** `PATCH preferencias` no choca con `PATCH :id/leida`, que tiene dos
  segmentos. · *Evidencia:* `portal-notificaciones.controller.ts`
- **Hecho:** la `ValidationPipe` global no convierte tipos implícitamente, así
  que `@IsBoolean()` rechaza `"false"` como texto. · *Evidencia:* `src/app.setup.ts`
- **Hecho:** la tienda no tiene código de notificaciones, así que Playwright no
  puede probar esta función por pantalla. · *Evidencia:* auditoría del 2026-11-05 sobre `frontend-cliente-angular`.

## Supuestos

- **Supuesto:** el contrato `{ "pedido_en_camino": boolean }` le sirve al
  frontend cuando exista la pantalla. · *Confirma:* responsable del frontend de la tienda.

## Decisiones pendientes

Ninguna. Cerradas por el usuario el 2026-11-06:

- La preferencia cubre solo `pedido_en_camino`. Los avisos de pago llegan siempre
  y `pedido_entregado` no se crea.
- Se guarda como campo de `User`, activo por defecto.

## Alcance

CA-1, CA-2, CA-3 y CA-5, más la prueba que confirma CA-4 con la preferencia activa.

## Fuera de alcance

- Pantalla de configuración en los frontends.
- Aviso de `pedido_entregado`.
- Preferencias de correo, pago, reembolso o promociones.
- Pruebas del entorno QA dentro de esta rama: `qa/` pertenece al PR #103.

## Plan técnico

| Capa | Archivos |
| --- | --- |
| `prisma` | `User.notificar_pedido_en_camino`, con su migración |
| `domain` | `notificacion.repository.ts`, `notificacion-repository.types.ts` |
| `application` | `obtener-preferencias-notificacion.use-case.ts`, `actualizar-preferencias-notificacion.use-case.ts`, `actualizar-preferencias-notificacion.dto.ts` |
| `infrastructure` | `prisma-notificacion.repository.ts`, `prisma-pedido.repository.ts` (`sales`) |
| `presentation` | `portal-notificaciones.controller.ts`, `persons.module.ts` |

## Autorización de endpoints

| Endpoint | Método | Roles requeridos |
| --- | --- | --- |
| `/api/v1/portal/notificaciones/preferencias` | `GET` | `cliente` |
| `/api/v1/portal/notificaciones/preferencias` | `PATCH` | `cliente` |

## Migraciones

Añade `persons.user.notificar_pedido_en_camino`, `BOOLEAN NOT NULL DEFAULT true`.
Las filas existentes quedan activas, como hoy.

## Dependencias con el frontend

Dos endpoints nuevos; no cambia ningún contrato existente. Sin pantalla que los
consuma todavía.

## Plan de pruebas

| Prueba | Tipo | Estado |
| --- | --- | --- |
| Casos de uso: obtener, actualizar, usuario inexistente | unitaria | pasa |
| Sin token 401, rol ventas 403 | e2e | pasa |
| Activa por defecto, desactivar, reactivar | e2e | pasa |
| Cuerpo inválido 400 | e2e | pasa |
| Un cliente no cambia la de otro | e2e | pasa |
| Desactivada: despacha sin aviso | e2e | pasa |
| Activa: despacha con aviso | e2e existente | pasa |

## Verificación

Ejecutado en local sobre los cambios sin commit, base `ce73d7d`.

- [x] `pnpm build`
- [x] `pnpm lint:check`
- [ ] `pnpm format:check`
- [x] `pnpm test`: 206 suites, 1551 pruebas
- [x] `pnpm test:e2e`: 49 suites, 1135 pruebas
- [ ] `docker build` + smoke
- [x] `pnpm exec prisma migrate status`
- [x] `git diff --check`
- [x] Sin `.env`, secretos, `dist/`, caches ni logs en el diff

No ejecutado y por qué:

- `format:check` global: falla en local por archivos CRLF ajenos. Se usó
  `prettier --check` sobre los archivos cambiados, en verde.
- `docker build`: el diff no toca `Dockerfile`, dependencias ni arranque. Lo cubre
  el CI.

Notas de entorno:

- `prisma migrate dev` pidió resetear la base local por dos migraciones antiguas
  renombradas. No se reseteó: el SQL se escribió a mano y se aplicó con
  `migrate deploy`.
- Los e2e usaron los valores ficticios de SMTP, S3 y URLs del CI, solo en el
  proceso, porque el `.env` local no los trae.

QA del PR #103 (`f854825`) sobre este código, con `qa/` en copia temporal:

- Humo normal: 2 de 2, con la migración aplicada en una base limpia.
- Contraseña rota en la copia: exit 1; falla el login y pasa la prueba negativa.
- `GET` y `PATCH preferencias` contra la API levantada: 401 sin token, y el valor
  cambia y se vuelve a activar.

## Riesgos

- Un cliente que desactiva el aviso no lo recupera para pedidos ya despachados:
  la preferencia solo decide en el momento del despacho.

## Entrega

| | |
| --- | --- |
| PR | |
| Estado del CI | |
| Jira | En curso, rama comentada |
