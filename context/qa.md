# Pipeline de QA

Entregado por `OFT0-581` en el
[PR #103](https://github.com/Proyecto-Aura/backend-monolito-francos/pull/103), aún
sin fusionar. El job `qa-e2e` corre en cada PR hacia `develop`, junto al CI
existente. Es informativo: no impide un merge.

```mermaid
flowchart TD
  subgraph R1["Repo: backend-monolito-francos"]
    PR["1. PR hacia develop"]
    QA["2. GitHub Actions lee qa.yml"]
    SRC["Código del PR<br/>NestJS + Prisma"]
    SPEC["Pruebas qa/e2e/humo.spec.ts"]
  end

  subgraph R2["Repo: frontend-cliente-angular"]
    TD["Rama develop de la tienda<br/>solo lectura"]
  end

  subgraph R3["Repo: frontend-angular-francos"]
    PE["Portal de la empresa<br/>no participa en QA"]
  end

  subgraph RUN["Máquina temporal de GitHub Actions"]
    DB["3. PostgreSQL 17<br/>Prisma: migraciones y datos demo"]
    API["4. API NestJS<br/>puerto 3000, Culqi simulado"]
    WEB["5. Tienda Angular<br/>serve, puerto 4200"]
    PW["6. Playwright abre Chromium<br/>login y catálogo"]
  end

  subgraph OUT["Resultado en el PR"]
    OK["Verde: reporte"]
    KO["Rojo: reporte y logs"]
  end

  PR --> QA
  QA --> DB
  SRC --> API
  DB --> API
  TD --> WEB
  API --> WEB
  WEB --> PW
  SPEC --> PW
  PW -- "pasan" --> OK
  PW -- "fallan" --> KO
```

## Qué prueba

| Prueba | Qué exige |
| --- | --- |
| Login y catálogo | `cliente_prueba` entra, llega a `/catalogo` y ve un producto que viene de la API real |
| Contraseña incorrecta | La API responde 401, la pantalla muestra «Credenciales inválidas» y sigue en login |

## Límites

- Es una prueba de humo. No cubre carrito, checkout, pagos, seguridad ni carga.
- La tienda se toma de la punta de `develop`; por eso el resumen registra su SHA.
- Lo que no tiene pantalla se prueba con los e2e de Jest del backend.
- Playwright, Jest y `qa-e2e` no consumen tokens de IA.

## Pendiente

`OFT0-582` añade contrato de la API, IDOR y datos inválidos después del merge del
PR #103.
