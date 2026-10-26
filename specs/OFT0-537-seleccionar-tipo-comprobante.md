# OFT0-537 — HU-B-009 Seleccionar tipo de comprobante

> **Regla de esta ficha:** separa siempre lo que **verificaste** de lo que
> **supones**. Todo hecho lleva evidencia (`archivo:línea`, commit o salida de
> comando). Un supuesto sin confirmar nunca se escribe como hecho.

## Identificación

| | |
| --- | --- |
| Subtarea backend | `OFT0-537` |
| HU padre | `OFT0-297` — HU-B-009 Seleccionar tipo de comprobante (13 SP) |
| Épica | `OFT0-318` — Módulo de Compras del Cliente |
| Sprint | Sprint 3 |
| Rama | `feature/OFT0-537-seleccionar-tipo-comprobante` |
| Commit base de `develop` | `ce92c91` (merge #78) |
| Fecha de auditoría | 2026-10-26 |

## Texto de la HU (Jira, leído el 2026-10-26)

> El cliente debe poder elegir entre boleta o factura. Si elige factura debe ingresar RUC y
> razón social. (RF-B29)

Bloquea a OFT0-298 (HU-B-010 Generar comprobante, subtarea backend OFT0-541, mía). No tiene
"is blocked by", aunque en la práctica el pedido del portal lo crea OFT0-296 / OFT0-533
(Piero Lanche, *Por hacer*, sin rama ni PR).

## Criterios de aceptación descompuestos

| # | Criterio | Origen | Estado en `develop` | Evidencia |
| --- | --- | --- | --- | --- |
| CA-1 | El cliente (rol `cliente`) elige `boleta` o `factura`; otro valor → 400. Por defecto `boleta` | RF-B29 | parcial (solo el enum) | `prisma/schema.prisma:170-176`; `resumen-pedido-portal.dto.ts:41-73` no lo acepta |
| CA-2 | Con `factura`, `ruc` obligatorio → si falta, 400 | RF-B29 | ausente | — |
| CA-3 | Con `factura`, `razon_social` obligatoria: no vacía tras trim, máx. 200 → si falta, 400 | RF-B29 | ausente | límite igual a `Cliente.razon_social VarChar(200)` (`schema.prisma:278`) |
| CA-4 | RUC válido: 11 dígitos, prefijo 10/15/17/20 y dígito verificador módulo 11 → si no, 400 | decisión D-2 | ausente | solo hay regex de 11 dígitos (`numero-documento.validator.ts:12`, `create-empresa.dto.ts:18`) y prefijo 10/20 (`registro-cliente.util.ts:18-24`) |
| CA-5 | Con `boleta`, `ruc` y `razon_social` se ignoran (no se validan ni se devuelven) | decisión D-3 | ausente | — |
| CA-6 | El resumen devuelve un bloque `comprobante` normalizado, listo para que OFT0-533 lo use al crear el pedido y OFT0-541 al emitir | decisión D-1 | ausente | `pedido.presenter.ts:74-75` reserva `comprobante: null` |
| CA-7 | El cliente sale del JWT; nunca del body | DoD | cubierto | `resumir-pedido-portal.use-case.ts:37-48` |
| CA-8 | Endpoint con `@Roles('cliente')`: 401 sin token, 403 con otro rol | DoD | cubierto | `portal-pedidos.controller.ts:20` |
| CA-9 | Errores en Swagger; pruebas unitarias y e2e (caso feliz por tipo y negativos) | DoD | ausente | — |
| CA-10 | El resumen propone RUC y razón social del perfil cuando el cliente es empresa con RUC | derivado | ausente; los datos existen | `Persona.tipo_documento/numero_documento` (`schema.prisma:201-202`), `Cliente.tipo_cliente/razon_social` (`schema.prisma:277-278`) |

## Hechos auditados

- **Hecho:** OFT0-537 es mía, *Por hacer*, padre OFT0-297. · *Evidencia:* Jira, auditoría `jira-task-auditor` 2026-10-26.
- **Hecho:** `TipoComprobante { boleta, factura }` existe y solo lo usan las series. · *Evidencia:* `schema.prisma:170-176, 624`; `reservar-correlativo.use-case.ts:15`.
- **Hecho:** `Pedido` no guarda tipo de comprobante ni datos del receptor; no hay `model Comprobante`. · *Evidencia:* `schema.prisma:551-576`.
- **Hecho:** el pedido del portal no se crea en ningún endpoint; RN5: el pedido nace solo con el pago confirmado. · *Evidencia:* `portal-pedidos.controller.ts:27-33`, `schema.prisma:139-140`.
- **Hecho:** no hay algoritmo de dígito verificador de RUC en `src/`. · *Evidencia:* grep de `ruc|digito|isRuc|validarRuc`.
- **Hecho:** el front Next (rama `origin/feature/Crear-pedido`) ya tiene el selector y exige RUC y razón social para factura. · *Evidencia:* `frontend-next-francos` `src/features/checkout/types.ts:1` (`"boleta" | "factura"`), `CheckoutForm.tsx:45-58`.
- **Hecho:** no hay PRs ni ramas de OFT0-537, OFT0-297 ni OFT0-533. · *Evidencia:* `gh pr list --state all --search` (vacío para las tres claves), `git branch -r`.
- **Hecho:** `RolesGuard` deniega sin `@Roles` y es global. · *Evidencia:* `roles.guard.ts:40-41`, `auth.module.ts:62-66`.

## Decisiones tomadas (usuario, 2026-10-26)

1. **D-1 Persistencia:** validar y devolver en `POST /portal/pedidos/resumen`, sin migración. Se exporta el DTO de datos de comprobante para que OFT0-533 lo reutilice. Mismo criterio que OFT0-529.
2. **D-2 RUC:** 11 dígitos + prefijo 10/15/17/20 + dígito verificador módulo 11 (SUNAT), como validador `@IsRuc()` reutilizable.
3. **D-3 Boleta con RUC:** se ignoran `ruc` y `razon_social`.

## Supuestos

- **S-1:** OFT0-533 reutilizará el resumen y el DTO de comprobante al crear el pedido con el pago. · *Confirma:* Piero Lanche.
- **S-2:** solo boleta y factura (sin notas de crédito/débito). · *Confirma:* PO.
- **S-3:** un RUC 10 (persona natural con negocio) también puede pedir factura. · *Confirma:* PO.
- **S-4:** la boleta no exige datos extra del adquirente (SUNAT lo pide por encima de cierto monto; no verificado). · *Confirma:* PO / contabilidad.
- **S-5:** el front enviará `tipo_comprobante`, `ruc` y `razon_social` en snake_case como el resto del contrato. · *Confirma:* dueño de OFT0-538.

## Decisiones pendientes

- **D-4:** ¿el pedido manual (`POST /pedidos`, admin/ventas) también elige tipo de comprobante para OFT0-541? · *Decide:* PO · *Bloquea:* no (sería otra incidencia).
- **D-5:** registrar en Jira "OFT0-297 is blocked by OFT0-296". · *Decide:* usuario (editar una HU padre requiere petición expresa) · *Bloquea:* no.

## Alcance

CA-1 a CA-10.

## Fuera de alcance

- Persistir el tipo de comprobante o crear el pedido (OFT0-533).
- Emitir el comprobante, el modelo `Comprobante` y el envío por correo (OFT0-541).
- Tipo de comprobante en el pedido manual (D-4).
- Cambiar los validadores de RUC existentes (empresa, registro); solo se crea el nuevo.

## Plan técnico

| Capa | Archivos |
| --- | --- |
| `common` | `src/common/validators/ruc.validator.ts`: `esRucValido(ruc)` (11 dígitos, prefijo, módulo 11) y decorador `@IsRuc()`, con spec |
| `application` | `dto/pedido-dtos/datos-comprobante.dto.ts` (exportable para OFT0-533); `resumen-pedido-portal.dto.ts` gana `comprobante?`; `resumir-pedido-portal.use-case.ts` normaliza (CA-5) y propone desde el perfil (CA-10) + spec |
| `domain` | `ClienteParaResumen` gana `tipo_cliente`, `razon_social`, `tipo_documento`, `numero_documento` |
| `infrastructure` | `prisma-pedido.repository.ts` `findClienteParaResumenPorUser`: select de esos campos |
| `presentation` | `resumen-pedido-portal.presenter.ts`: bloque `comprobante` y `comprobante_sugerido`; Swagger en `portal-pedidos.controller.ts` |

## Autorización de endpoints

| Endpoint | Método | Roles requeridos |
| --- | --- | --- |
| `/api/v1/portal/pedidos/resumen` (modificado) | POST | `cliente` |

## Migraciones

Ninguna (D-1). No hay datos de referencia nuevos.

## Dependencias con el frontend

Cambio aditivo en `POST /portal/pedidos/resumen` (body y respuesta). Avisar al dueño de
OFT0-538 (frontend HU-B-009) y a Piero (OFT0-533).

## Plan de pruebas

| Prueba | Tipo | Estado |
| --- | --- | --- |
| `esRucValido`: válidos, longitud, prefijo, dígito verificador | unitaria | `src/common/validators/ruc.validator.spec.ts` — pasa |
| Resumen: boleta por defecto, factura válida, boleta ignora RUC, sugerido desde perfil y casos sin sugerencia | unitaria | `resumir-pedido-portal.use-case.spec.ts` — pasa |
| Endpoint: 400 por cada caso de validación, 200 boleta y factura, sugerido de empresa, 401/403 | e2e | `test/portal-pedidos.e2e-spec.ts` — pasa |

## Implementación (2026-10-25)

| Capa | Cambio |
| --- | --- |
| `common` | `ruc.validator.ts`: `esRucValido` + `@IsRuc()` (nuevo) |
| `application` | `datos-comprobante.dto.ts` (nuevo, `ValidateIf` solo con factura); `ResumenPedidoPortalDto.comprobante?`; el caso de uso devuelve `comprobante` y `comprobante_sugerido` |
| `domain` | `ClienteParaResumen` gana `ruc?` y `razon_social?`, **opcionales** para no romper los mocks de reembolso |
| `infrastructure` | `findClienteParaResumenPorUser` selecciona `razon_social`, `tipo_documento` y `numero_documento`; `ruc` solo si el documento es RUC |
| `presentation` | presenter con los dos bloques; Swagger con los nuevos 400 |

Ajuste respecto al plan: el sugerido no depende de `tipo_cliente` sino de que el perfil tenga
**RUC válido + razón social**. Así no se propone un RUC que el propio endpoint rechazaría, y el
RUC 10 (S-3) queda cubierto si tiene razón social.

Contrato nuevo (aditivo):

```json
// body
"comprobante": { "tipo_comprobante": "factura", "ruc": "20601234565", "razon_social": "..." }
// respuesta
"comprobante": { "tipo_comprobante": "boleta|factura", "ruc": "string|null", "razon_social": "string|null" },
"comprobante_sugerido": { "ruc": "...", "razon_social": "..." } | null
```

## Verificación

| Puerta | Resultado |
| --- | --- |
| build | pasó |
| lint:check | pasó (0 errores, 0 warnings) |
| format | mis 11 archivos pasan `prettier --check`. El `format:check` global marca 134 archivos ajenos por CRLF del checkout local (en git son LF, `git ls-files --eol`); no aplica al CI |
| test (unit) | pasó: 171 suites, 1146 tests |
| prisma | validate, generate y `migrate deploy` ok sobre postgres:16 desechable; roles sin seed: los 7 |
| deriva | aparece la ya conocida de `inventory.movimiento_insumo` (PR #73, ajena). Esta rama no toca `prisma/` (`git diff origin/develop -- prisma` vacío) |
| test-e2e | pasó: 726 tests (`--runInBand --forceExit --testTimeout=60000`) |
| docker | pasó: `docker build` + smoke, `/api/docs-json` 200 con `DatosComprobanteDto` publicado (se corrió porque cambia Swagger) |
| `git diff --check` | limpio |

## Riesgos

- Si OFT0-533 no reutiliza el DTO, el contrato del pago puede divergir del resumen.
- La HU no se valida de punta a punta hasta que exista OFT0-533 (bloquea en cascada a OFT0-541).

## Entrega

| | |
| --- | --- |
| PR | [#80](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/80) — commit `1fcec99` |
| Estado del CI | en curso al abrirlo |
| Jira | *En revisión*, comentario 10127 (2026-10-26) |
