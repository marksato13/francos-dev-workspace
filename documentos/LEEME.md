# Documentos

Aquí van los PDF y documentos de referencia que condicionan cómo se trabaja: acuerdos del
equipo, convenciones, actas de reunión, requisitos del curso, guías de Git Flow.

**Deja el archivo en la carpeta que toque y dime que lo revise.** Yo lo leo, extraigo lo que
cambia el flujo de trabajo y lo convierto en regla dentro de `CLAUDE.md`, de una skill o de
un comando. El PDF queda como fuente; la regla operativa vive en el workspace.

## Dónde poner cada cosa

```
documentos/
├── acuerdos/      acuerdos del equipo, actas, convenciones  -> SE VERSIONA
├── referencia/    guias, normas, material del curso         -> SE VERSIONA
└── privado/       cualquier cosa con datos personales o
                   credenciales                              -> NO SE VERSIONA
```

### `acuerdos/` y `referencia/` se versionan

Van a GitHub, al repositorio **privado** `marksato13/francos-dev-workspace`. Ventaja: quedan
respaldados y los puedo leer desde cualquier clon.

### `privado/` no se versiona

Está en el `.gitignore`. Úsala si el documento trae datos personales de compañeros,
credenciales, información del cliente o cualquier cosa que no deba salir de tu máquina
aunque el repo sea privado.

**Ante la duda, `privado/`.** Un archivo se puede mover después a `acuerdos/`; sacarlo del
historial de Git una vez subido es mucho más caro.

## Qué hago con cada documento

Cuando me digas que revise uno:

1. **Lo leo completo.** No resumo por encima.
2. **Extraigo lo que cambia el trabajo**: reglas de ramas, convenciones de commit, criterios
   de aceptación, plazos, responsabilidades, restricciones.
3. **Contrasto con lo que ya está configurado.** Si el acuerdo contradice algo de
   `CLAUDE.md`, `.claude/settings.json` o del ciclo de vida, **te lo digo antes de cambiar
   nada**: puede que el acuerdo sea viejo, o puede que la configuración esté mal.
4. **Lo convierto en regla** donde corresponda, y dejo una línea en el índice de abajo
   diciendo qué documento la originó.

Lo que **no** hago: dar por cierto un documento sin contrastarlo con el repositorio, ni
cambiar la configuración en silencio porque un PDF lo dice.

## Índice

Una línea por documento revisado: qué es, de cuándo, y qué regla salió de él.

| Documento | Fecha | Qué cambió |
| --- | --- | --- |
| *(vacío — sube el primero)* | | |

## Formatos

PDF, Word, Markdown, imágenes y capturas. Si el PDF es escaneado y no tiene texto
seleccionable, dímelo: hace falta OCR y es un paso aparte.
