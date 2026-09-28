---
description: Crea el commit, sube la rama, abre el PR hacia develop y sincroniza Jira
argument-hint: OFT0-345
---

Entrega **$1**. Ejecuta en orden y **detente en el primer paso que falle**.

Commit, push y `gh pr create` **pedirán confirmación**. Eso es intencional: no lo
esquives.

## 1. Comprobar que se puede entregar

- `/task-verify` pasó. Si no lo has corrido en esta sesión, **córrelo ahora**. No
  se abre PR a ciegas: el CI tiene 5 puertas y `lint` es bloqueante.
- La rama actual contiene **$1** y no es `main` ni `develop`.

## 2. Una incidencia, un PR

```bash
gh pr list --state all --search "$1"
```

Si ya existe un PR **abierto** para $1, no crees otro: actualiza esa rama y
termina. Si existe uno **cerrado sin fusionar**, dímelo antes de seguir — puede
haber una razón por la que se rechazó.

## 3. Proteger lo ajeno

```bash
git status --short
```

Si aparece cualquier archivo que no pertenece a **$1**: **detente y repórtalo.**
No lo incluyas y no lo descartes.

## 4. Commit

`git add` con **rutas explícitas**, archivo por archivo. **Nunca `git add -A` ni
`git add .`**: es la forma más fácil de meter un `.env` o el trabajo de otro en el
commit.

Mensaje en formato convencional, con la clave de la **subtarea**:

```
feat(<modulo>): $1 <descripcion corta>
```

Usa `fix(...)` solo si corriges algo ya fusionado. El cuerpo, si hace falta,
explica el *por qué*, no el *qué*.

## 5. Push

```bash
git push -u origin HEAD
```

`--force` está denegado. Cualquier variante que apunte a `main` está denegada.

## 6. PR hacia develop

```bash
gh pr create --base develop
```

**Jamás `--base main`** (está denegado por configuración). El cuerpo del PR lleva:

- Enlace a la subtarea Jira **$1** y a su HU padre.
- Alcance implementado, criterio por criterio (`CA-1` cubierto, `CA-2`...).
- **Pruebas ejecutadas y su resultado.**
- **Pruebas omitidas y por qué.** No las escondas.
- Migraciones incluidas, si hay.
- Riesgos conocidos y dependencias con el frontend.
- Fuera de alcance explícito.

## 7. Comprobar el CI

```bash
gh pr checks <numero> --watch
```

Si alguna puerta sale en rojo, corrige **en la misma rama** y vuelve a subir. No
abras un PR nuevo.

## 8. Sincronizar Jira

Con el PR creado: comenta **$1** con el enlace al PR y la evidencia real, y
transiciónala a *En revisión*. Autorizado en automático para mis subtareas.

- **No muevas nada a *Listo***: eso es después del merge y de la verificación
  final.
- **No toques la HU padre** ni las subtareas de otras personas.
- **No registres worklogs** sin que yo te lo pida.
- No escribas en Jira un resultado que no observaste.

## El merge no es tuyo

`gh pr merge` está **denegado**. El merge a `develop` lo hace una persona en
GitHub. Al terminar, dime el número y la URL del PR y qué queda por hacer.
