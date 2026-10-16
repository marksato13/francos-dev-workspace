# Git Flow del equipo

Fuente: `documentos/referencia/guia-git-flow.pdf` y `documentos/referencia/guia-git-prisma.pdf`
(FRANCO'S ERP / proyecto-monolito-francos). Revisados el **2026-10-16**.

Este documento recoge lo que dicen los PDF, **lo que se aplicó**, y **dónde no coinciden
con la realidad del repositorio**. Si un PDF y este documento discrepan, gana el PDF — pero
las discrepancias están anotadas abajo a propósito.

## Las 5 ramas

| Rama | Sale de | Vuelve a | ¿Es mi trabajo? |
| --- | --- | --- | --- |
| `main` | — | — | No. Producción |
| `develop` | — | — | Base de todo |
| `feature/xxx` | `develop` | `develop` | **Sí, lo habitual** |
| `release/x.x` | `develop` | `main` + `develop` | Solo si me toca |
| `hotfix/xxx` | `main` | `main` + `develop` | Solo urgencias de producción |

```
DESARROLLO NORMAL:    develop → feature/xxx → (PR) → develop
LANZAMIENTO:          develop → release/x.x → (pruebas) → main + develop
BUG URGENTE:          main    → hotfix/xxx  → (fix) → main + develop
```

En `release/` **no se agregan features nuevos**, solo correcciones.

## Las 7 reglas de oro

Literales de la guía:

1. **Nunca pushear directo a `main` ni `develop`**, siempre mediante Pull Request.
2. **Un PR = una funcionalidad**, no mezclar tareas en la misma rama.
3. **Hacer pull de `develop` antes de crear una rama nueva.**
4. **Nunca subir `.env`, `dist`, `node_modules`** al repositorio.
5. **Todo PR debe ser revisado por al menos un compañero** antes de mergear.
6. **Resolver conflictos en tu rama**, no en `develop`.
7. Cada microservicio tiene su propio repositorio; coordinar quién trabaja en cuál.

## Convención de commits

| Prefijo | Uso |
| --- | --- |
| `feat:` | Nueva funcionalidad |
| `fix:` | Corrección de bug |
| `refactor:` | Refactorización |
| `docs:` | Documentación |
| `chore:` | Configuración, dependencias |
| `test:` | Pruebas |

## Qué se aplicó el 2026-10-16

### Hueco cerrado: push directo a `develop`

La regla #1 lo prohíbe, pero la configuración solo bloqueaba `main`. Añadido a `deny`:

```
Bash(git push origin develop:*)
Bash(git push origin HEAD:refs/heads/develop)
```

### Hueco cerrado: `prisma migrate deploy` tras el pull

Regla de oro del manual de Prisma que no estaba en ningún sitio. Añadida a `allow` —
solo aplica migraciones pendientes, es seguro y repetible. Detalle completo en la skill
[`prisma-migraciones`](../.claude/skills/prisma-migraciones/SKILL.md).

### `hotfix/` habilitado, `main` sigue protegido

Decisión del usuario el 2026-10-16: por su rol **sí puede** hacer `release/` y `hotfix/`
cuando haga falta, y los hará él con ayuda en los pasos.

Lo que cambió:

| Antes | Ahora |
| --- | --- |
| `git switch main` / `git checkout main` denegados | **permitidos** — hacen falta para ramificar |
| `gh pr create --base main` denegado | **pide confirmación** |

Lo que **no** cambió, por instrucción explícita: *"no quiero que subas a main directo a no
ser que yo te lo pida"*.

| Sigue denegado |
| --- |
| `git push origin main` |
| `git push origin HEAD:refs/heads/main` |
| `git push --force` / `-f` |
| `gh pr merge` |

El camino a `main` existe, pero pasa por un PR y por una persona.

## Discrepancias que quedan abiertas

### 1. `git add .` — resuelto con verificación previa

| Fuente | Dice |
| --- | --- |
| Manual Prisma, paso 6 | `git add .` — *"agregar TODOS los archivos (schema + migrations + src)"* |
| Guía Git Flow | `git add .` |
| Riesgo real | El repo lo tocan 6 personas y ya aparecieron cambios ajenos en el worktree |

**Decisión del usuario:** usar `git add .` **pero solo después de verificar `git status`**.

`/task-pr` lo aplica así: muestra `git status`, confirma que no hay archivos ajenos ni
ningún `.env`, y solo entonces hace `git add .`. Si aparece algo ajeno, se detiene.

Esto cumple el objetivo real del manual — que `prisma/migrations/` nunca se quede fuera —
sin arrastrar el trabajo de otro.

### 2. Los dos PDF se contradicen entre sí

El manual de Prisma, sección 4, ofrece **"Opción B: Merge directo"**:

```bash
git checkout develop
git merge feature/mi-feature
git push origin develop
```

Eso **contradice frontalmente la regla de oro #1** de la guía de Git Flow. El propio manual
lo acota a *"proyectos personales o urgencias"*, pero queda escrito como opción válida.

**Se sigue la regla de oro: siempre PR.** La Opción B está bloqueada por configuración
(`git push origin develop` denegado). Si el equipo quiere permitirla, es una decisión
suya, no una omisión mía.

### 3. `prisma db push` — coincidencia, no conflicto

El manual lo reserva a *"prototipado rápido sin historial, desarrollo individual"*.
Estaba denegado desde septiembre por desincronizar la base local. Misma conclusión,
ahora con respaldo del equipo.

## Cómo se traduce a mi flujo

| Regla del equipo | Dónde vive |
| --- | --- |
| Rama desde `develop` actualizado | `/task-start`, paso 3 |
| Un PR = una funcionalidad | `/task-start` comprueba que no exista otra rama |
| Pull de `develop` antes de rama nueva | `/task-start`, `git pull --ff-only` |
| No subir `.env`, `dist`, `node_modules` | `/task-verify` + `deny` de lectura del `.env` |
| Revisión de un compañero | `gh pr merge` denegado: el merge lo hace una persona |
| Resolver conflictos en mi rama | skill `prisma-migraciones` para `schema.prisma` |
| Prefijos de commit | `/task-pr`, paso 4 |
| `migrate deploy` tras el pull | skill `prisma-migraciones` |
