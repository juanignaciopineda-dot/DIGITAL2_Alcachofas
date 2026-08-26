# DIGITAL2 — Alcachofas

Trabajos prácticos de **assembler para PIC16F887** (Electrónica Digital II).

Trabajamos con **SCRUM** y **git**: yo dejo las tareas como *issues*, ustedes las toman, las
resuelven en una rama aparte y mandan una *pull request*. Yo la reviso y la integro.

> **No hace falta que sepan git para arrancar.** Son siete comandos y están todos acá abajo.
> Si algo no sale, está `docs/04-problemas-comunes.md` y estoy yo. No se peleen con la herramienta:
> lo que tienen que aprender es assembler, no git.

---

## Antes de empezar (una sola vez)

Instalar git, configurarlo con su nombre y mail, y clonar el repo.
Está todo explicado paso a paso en **[docs/01-instalacion.md](docs/01-instalacion.md)**.

No hay que instalar nada más: MPLAB X ya lo tienen de la materia.

---

## Los comandos que van a usar siempre

Son estos. No hay más.

| Comando | Qué hace |
|---|---|
| `git status` | Dónde estoy parado y qué tengo sin guardar. **Ante la duda, este.** |
| `git switch main` | Me paro en la rama principal |
| `git pull` | Me bajo lo último que subieron los demás |
| `git switch -c mi-rama` | Creo una rama nueva y me paro en ella |
| `git add .` | Marco mis cambios para guardarlos |
| `git commit -m "..."` | Guardo los cambios con un mensaje que dice qué hice |
| `git push` | Subo mis cambios a GitHub |

---

## El ciclo de trabajo

Prestá atención a los íconos: 🌐 es en la página de GitHub, 💻 es en la terminal.

### 1. 🌐 Agarrar una tarea

Entrás a la pestaña **Issues**, elegís uno del milestone activo y te asignás:
en el panel de la derecha, **Assignees** → tu usuario.

Asignarte es la forma de avisar "esto lo estoy haciendo yo". **Un issue por persona a la vez.**

### 2. 💻 Crear tu rama y trabajar

```bash
git switch main                       # me paro en la rama principal
git pull                              # me traigo lo último
git switch -c teclado-antirrebote     # creo mi rama y me paro en ella
```

Ahora sí: abrís MPLAB X, escribís el código, lo ensamblás y lo probás.
Cada vez que tengas algo que funcione:

```bash
git status                            # veo qué cambié
git add .                             # marco todo lo que cambié
git commit -m "agrego la rutina de antirrebote del teclado"
```

Y cuando la tarea está lista:

```bash
git push -u origin teclado-antirrebote
```

### 3. 🌐 Abrir la Pull Request

Al entrar a GitHub te va a aparecer un cartel amarillo que dice
**"Compare & pull request"**. Click ahí.

Se completa sola una plantilla. Llenala y **escribí `Closes #12`** (con el número de tu issue):
eso hace que el issue se cierre solo cuando la PR se integre.

Verificá que arriba diga `base: main`. Después, **Create pull request**.

### 4. 🌐 Esperar la revisión

Yo la reviso y te dejo comentarios. Si te pido cambios:

💻 los hacés en **la misma rama**, `git add .`, `git commit`, `git push`.
La PR se actualiza sola. **No abras una PR nueva.**

### 5. 💻 Volver al principio

Cuando apruebo y la integro:

```bash
git switch main
git pull
```

Y agarrás el próximo issue.

---

## Reglas del repo

1. **Nunca se commitea directo en `main`.** Está protegida, no te va a dejar.
2. **Una rama por issue.** No mezcles dos tareas en la misma rama.
3. **Toda PR necesita mi aprobación** antes de integrarse.
4. **No se suben archivos generados** (`build/`, `dist/`, `.hex`). Ya está el `.gitignore` para eso.
5. **Si estás trabado, avisá.** Mandá mensaje y dejá un comentario en el issue contando qué probaste.
   Estar trabado es normal; estar trabado en silencio tres días no.

---

## Estructura del repo

```
.
├── docs/          ← las guías (leer al menos la 01 y la 02)
├── tp1/
│   ├── src/       ← acá van los .asm y los .inc
│   └── TP1.X/     ← el proyecto de MPLAB X
└── README.md      ← esto
```

---

## Las guías

| Archivo | Para qué |
|---|---|
| [docs/01-instalacion.md](docs/01-instalacion.md) | Instalar y configurar git, clonar el repo. **Empezá por acá.** |
| [docs/02-flujo-de-trabajo.md](docs/02-flujo-de-trabajo.md) | El ciclo de arriba, pero explicado en detalle |
| [docs/03-como-trabajamos.md](docs/03-como-trabajamos.md) | Cómo nos organizamos y qué se pide para dar una tarea por terminada |
| [docs/04-problemas-comunes.md](docs/04-problemas-comunes.md) | **Cuando algo se rompe.** Buscá el mensaje de error acá antes de asustarte |

---

## Si algo se rompió

1. Buscá el mensaje de error en `docs/04-problemas-comunes.md`.
2. Si no está, mandá mensaje con la salida de `git status` copiada y pegada.

**No borres la carpeta para volver a clonar.** Casi todo tiene arreglo y perder el trabajo hecho
duele más que el problema original.
