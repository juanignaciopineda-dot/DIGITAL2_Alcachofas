# 02 — Flujo de trabajo

El ciclo completo, paso por paso. 🌐 es en la página de GitHub, 💻 es en la terminal.

- [Por qué se trabaja en ramas](#por-qué-se-trabaja-en-ramas)
- [Paso 1 🌐 Agarrar un issue](#paso-1--agarrar-un-issue)
- [Paso 2 💻 Partir de lo último](#paso-2--partir-de-lo-último)
- [Paso 3 💻 Crear tu rama](#paso-3--crear-tu-rama)
- [Paso 4 💻 Trabajar y commitear](#paso-4--trabajar-y-commitear)
- [Paso 5 💻 Subir la rama](#paso-5--subir-la-rama)
- [Paso 6 🌐 Abrir la Pull Request](#paso-6--abrir-la-pull-request)
- [Paso 7 🌐 La revisión](#paso-7--la-revisión)
- [Paso 8 💻 Cerrar el ciclo](#paso-8--cerrar-el-ciclo)
- [Si `main` avanzó mientras trabajabas](#si-main-avanzó-mientras-trabajabas)

---

## Por qué se trabaja en ramas

Imaginate que somos cuatro y los cuatro editamos `main.asm` al mismo tiempo, todos sobre `main`.
El primero que sube, sube. Los otros tres, cuando quieran subir, se encuentran con que el archivo
cambió abajo de sus pies.

Una **rama** es tu copia privada del proyecto. Trabajás tranquilo, rompés lo que quieras, y recién
cuando funciona pedís que se integre. Mientras tanto, nadie ve tu desastre y vos no rompés el de
nadie.

`main` es la rama que **siempre tiene que andar**. Es lo que se entrega. Por eso está protegida:
no se toca directo.

---

## Paso 1 🌐 Agarrar un issue

En la página del repo, pestaña **Issues**. Cada issue es una tarea.

Filtrá por el milestone activo (el sprint en curso): arriba, **Milestones**.

Abrí uno que te interese, leelo entero — sobre todo los **criterios de aceptación**, que son
exactamente lo que voy a mirar cuando revise — y asignátelo:

> Panel derecho → **Assignees** → tu usuario

Asignarte es la forma de avisar "esto lo agarro yo". Si el issue ya tiene a alguien asignado,
agarrá otro.

**Un issue asignado por persona a la vez.** Terminá el que empezaste antes de agarrar otro.

Anotate el número del issue (el `#12` del título). Lo vas a necesitar en el paso 6.

---

## Paso 2 💻 Partir de lo último

Antes de crear tu rama, traete lo que subieron los demás:

```bash
git switch main
git pull
```

| Comando | Qué hace |
|---|---|
| `git switch main` | Te para en la rama principal |
| `git pull` | Baja de GitHub todo lo que se integró desde la última vez |

**Hacelo siempre**, aunque hayas hecho `pull` ayer. Si arrancás tu rama desde una versión vieja,
después vas a tener que resolver conflictos que te podías haber ahorrado.

---

## Paso 3 💻 Crear tu rama

```bash
git switch -c teclado-antirrebote
```

El `-c` es de *create*: crea la rama y te para en ella, todo junto.

**Cómo nombrarla:** libre, pero que se entienda de qué es. Sin espacios, sin acentos, sin eñes.

| Sirve | No sirve |
|---|---|
| `teclado-antirrebote` | `rama1` |
| `lcd-init` | `prueba` |
| `arreglo-display-7seg` | `mi rama de la tarea` |

Para confirmar en qué rama estás:

```bash
git status
```

La primera línea dice `On branch teclado-antirrebote`. Si dice `On branch main`, no creaste la
rama — repetí el comando.

---

## Paso 4 💻 Trabajar y commitear

Ahora sí: MPLAB X, código, ensamblar, probar.

Un **commit** es una foto de tu trabajo en un momento dado. Sirve para poder volver atrás si algo
se rompe.

**Cuándo commitear:** cada vez que tengas algo que ensambla y funciona. Una rutina lista, un
registro bien configurado, un bug arreglado. **No** una vez por día ni todo junto al final.

```bash
git status                                          # veo qué archivos toqué
git add .                                           # los marco todos
git commit -m "agrego la rutina de antirrebote del teclado"
```

| Comando | Qué hace |
|---|---|
| `git status` | Lista lo que cambiaste. Miralo antes de agregar, para no subir basura |
| `git add .` | El punto significa "todo lo que cambié en esta carpeta y las de adentro" |
| `git commit -m "..."` | Saca la foto, con ese mensaje |

### El mensaje del commit

No hay reglas raras ni prefijos que memorizar. **Una sola regla: que diga qué hiciste.**

| Sirve | No sirve |
|---|---|
| `agrego la rutina de antirrebote del teclado` | `asd` |
| `arreglo el delay que se colgaba con TMR0` | `cambios` |
| `configuro los puertos B y D como digitales` | `final finalV2` |
| `corrijo el banco en la rutina de escritura del LCD` | `.` |

Dentro de tres semanas, cuando busquemos dónde se rompió algo, la diferencia entre las dos columnas
es la diferencia entre encontrarlo en un minuto o leer todo de nuevo.

Podés hacer todos los commits que quieras antes de subir. No hay apuro.

---

## Paso 5 💻 Subir la rama

```bash
git push -u origin teclado-antirrebote
```

- `origin` es GitHub (el nombre que git le da al repo remoto).
- El `-u` le dice a git "esta rama de acá corresponde a esta rama de allá".

**El `-u` va solo la primera vez** que subís esa rama. Después, para esa rama, alcanza con:

```bash
git push
```

En la salida del comando vas a ver un link para crear la Pull Request. Podés hacerle click
directamente y te ahorrás el paso siguiente.

---

## Paso 6 🌐 Abrir la Pull Request

Una **Pull Request** (PR) es pedir que tu rama se integre a `main`. Es donde se revisa el código.

Al entrar a GitHub te aparece un cartel amarillo: **"Compare & pull request"**. Click.

Si no aparece: pestaña **Pull requests** → **New pull request** → elegí tu rama en el desplegable
de la derecha.

En el formulario:

1. **Verificá que arriba diga `base: main` ← `compare: tu-rama`.** Si la base no es `main`,
   cambiala.
2. Se carga sola una plantilla con las secciones a completar. Llenala.
3. En la primera línea escribí **`Closes #12`** con el número de tu issue.
   Esa palabra hace que GitHub cierre el issue solo cuando la PR se integre. Sin ella, el issue
   queda abierto para siempre y el tablero deja de reflejar la realidad.
4. **Create pull request**.

---

## Paso 7 🌐 La revisión

Yo la reviso y te dejo comentarios. Pueden ser sobre líneas concretas del código o sobre la PR en
general — los vas a ver en la pestaña **Conversation** de la PR.

**Que te pida cambios es lo normal, no es que esté mal hecho.** Para eso existe la revisión.

Si te pido cambios:

💻 Los hacés **en la misma rama** (asegurate con `git status` de que seguís parado ahí):

```bash
git add .
git commit -m "uso constantes con EQU en vez de números sueltos"
git push
```

Y ya está: **la PR se actualiza sola** con el commit nuevo.

> ⚠️ **No abras una PR nueva.** Es el error más común. La PR sigue viva mientras la rama exista.

Si no entendés un comentario, respondelo ahí mismo preguntando. Es parte del ejercicio.

---

## Paso 8 💻 Cerrar el ciclo

Cuando apruebo la PR, la integro a `main`. El issue se cierra solo (por el `Closes #12`).

De tu lado:

```bash
git switch main
git pull
git branch -d teclado-antirrebote
```

El último comando borra tu rama local, que ya no sirve para nada — su contenido está en `main`.
Si git se niega a borrarla, es porque tiene algo sin integrar: no la fuerces, preguntá.

Y volvés al paso 1 con el próximo issue.

---

## Si `main` avanzó mientras trabajabas

En tareas largas puede pasar que otros integren cosas mientras vos seguís en tu rama. Para traerte
esos cambios sin perder los tuyos:

```bash
git switch main
git pull
git switch teclado-antirrebote
git merge main
```

Si aparece un **conflicto**, no pasa nada malo: está en
[04-problemas-comunes.md](04-problemas-comunes.md) cómo se resuelve.

No hace falta hacer esto todos los días. Solo si la tarea se está estirando o si al abrir la PR
GitHub avisa que hay conflictos.
