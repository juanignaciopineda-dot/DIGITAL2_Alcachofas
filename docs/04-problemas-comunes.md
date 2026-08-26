# 04 — Problemas comunes

Buscá acá el mensaje de error antes de asustarte. **Casi nada de lo que pasa en git es
irreversible**, y lo que sí lo es está avisado.

- [Antes que nada: ¿dónde estoy parado?](#antes-que-nada-dónde-estoy-parado)
- [No me deja pushear: "Updates were rejected"](#no-me-deja-pushear-updates-were-rejected)
- [Un conflicto](#un-conflicto)
- [Trabajé en main sin querer](#trabajé-en-main-sin-querer)
- [Subí build o dist sin querer](#subí-build-o-dist-sin-querer)
- [Me pide usuario y contraseña y la mía no anda](#me-pide-usuario-y-contraseña-y-la-mía-no-anda)
- [Aparecen archivos modificados que no toqué](#aparecen-archivos-modificados-que-no-toqué)
- [No me deja pushear a main](#no-me-deja-pushear-a-main)
- [Dice "detached HEAD"](#dice-detached-head)
- [Me pidieron cambios en la PR](#me-pidieron-cambios-en-la-pr)
- [Me equivoqué en el mensaje del último commit](#me-equivoqué-en-el-mensaje-del-último-commit)
- [not a git repository](#not-a-git-repository)
- [Si nada de esto sirve](#si-nada-de-esto-sirve)

---

## Antes que nada: ¿dónde estoy parado?

El 90% de los problemas de git son en realidad "no sé en qué rama estoy". Estos tres comandos te lo
dicen:

```bash
git status
git branch
git log --oneline --graph --all
```

`git status` te dice la rama actual y qué tenés sin guardar. `git branch` lista todas tus ramas
(la actual tiene un `*`). El tercero dibuja el historial completo — se sale con `q`.

---

## No me deja pushear: "Updates were rejected"

```
! [rejected]  mi-rama -> mi-rama (fetch first)
error: failed to push some refs
hint: Updates were rejected because the remote contains work that you do not have locally.
```

**Qué pasó:** alguien subió algo a esa rama después de la última vez que la bajaste. Git no te deja
pisarlo.

**Arreglo:**

```bash
git pull
git push
```

Si el `git pull` trae un conflicto, seguí con la sección que viene.

---

## Un conflicto

```
CONFLICT (content): Merge conflict in tp1/src/main.asm
```

**Qué pasó:** dos personas editaron **las mismas líneas** del mismo archivo. Git no puede decidir
cuál vale, así que te lo pregunta a vos. **No es un error y no rompiste nada.**

Abrí el archivo que menciona. Vas a ver algo así:

```asm
<<<<<<< HEAD
    movlw   d'250'
=======
    movlw   d'200'
>>>>>>> main
```

Arriba del `=======` está tu versión. Abajo, la que viene de la otra rama.

**Qué hacer:** decidí qué tiene que quedar — una, la otra, o una mezcla — y **borrá las tres líneas
de marcas**. El archivo tiene que quedar como querés que sea, sin rastro de los `<<<<<<<`,
`=======` ni `>>>>>>>`.

Repetí en cada archivo en conflicto (`git status` te los lista). Después:

```bash
git add .
git commit -m "resuelvo el conflicto en main.asm"
```

**Si te perdiste en el medio**, este comando deja todo como estaba antes de empezar:

```bash
git merge --abort
```

Y arrancás de nuevo con la cabeza fresca. Es el botón de pánico y está bueno usarlo.

---

## Trabajé en main sin querer

Te olvidaste de crear la rama e hiciste dos commits parados en `main`. Pasa siempre.

**Si ya commiteaste** (pushear no vas a haber podido, porque `main` no te deja):

```bash
git switch -c la-rama-que-me-olvide
```

Tus commits se van con vos a la rama nueva. Ahora hay que dejar `main` como estaba:

```bash
git switch main
git reset --hard origin/main
git switch la-rama-que-me-olvide
```

> ⚠️ `git reset --hard` **borra sin preguntar** todo lo que no esté commiteado en la rama donde
> estás parado. Acá es seguro porque tus commits ya están a salvo en la rama nueva del paso 1.
> Fuera de esta receta exacta, no lo uses: preguntá.

**Si todavía no commiteaste** nada, alcanza con la primera línea: los cambios sin commitear se
mueven con vos a la rama nueva.

---

## Subí build o dist sin querer

Suele pasar si commiteaste antes de que existiera el `.gitignore`.

```bash
git rm -r --cached build dist
git commit -m "saco del repo los archivos generados por MPLAB"
git push
```

El `--cached` es la parte importante: **saca los archivos del repositorio pero los deja en tu
disco**. Sin él, te los borra de la máquina.

Cambiá `build dist` por lo que tengas que sacar. Si es un archivo suelto, va sin el `-r`:

```bash
git rm --cached tp1/TP1.X/dist/default/production/TP1.X.production.hex
```

---

## Me pide usuario y contraseña y la mía no anda

**Qué pasa:** GitHub no acepta contraseñas desde la terminal desde 2021. Tu contraseña de la web no
sirve acá, por más que la escribas bien.

**Arreglo:** tiene que abrirse una ventana del navegador para autenticarte. Si en vez de eso te
aparece un cuadro pidiendo usuario y contraseña escritos, cancelá y buscá la opción
**"Sign in with your browser"**.

Si no aparece nada de eso:

```bash
git config --global credential.helper manager
```

Y volvé a intentar el `git push`.

Si ya te guardó una credencial equivocada: buscá **Administrador de credenciales** en el menú de
Windows, entrá a *Credenciales de Windows*, borrá la entrada que diga `git:https://github.com` y
probá de nuevo.

---

## Aparecen archivos modificados que no toqué

`git status` te marca archivos enteros como modificados y vos no abriste ninguno.

**Qué pasó:** Windows marca el fin de línea distinto que Linux, y git ve *todas* las líneas como
cambiadas.

**Arreglo:**

```bash
git config --global core.autocrlf true
```

Y verificá que exista un archivo `.gitattributes` en la raíz del repo. Ya viene con el repo, no hay
que crearlo — si no está, avisame.

Para descartar esos cambios falsos:

```bash
git checkout -- .
```

> ⚠️ Ese comando descarta cambios sin commitear. Corroborá antes con `git status` que lo único que
> aparece son los falsos positivos y no trabajo tuyo.

---

## No me deja pushear a main

```
! [remote rejected] main -> main (protected branch hook declined)
```

**No es un error: es a propósito.** `main` está protegida para que nadie la rompa sin querer.

Todo entra a `main` por Pull Request y con aprobación. Volvé a
[02-flujo-de-trabajo.md](02-flujo-de-trabajo.md), paso 3: creá tu rama y de ahí la PR.

Si ya tenías commits hechos sobre `main`, mirá [Trabajé en main sin querer](#trabajé-en-main-sin-querer).

---

## Dice "detached HEAD"

```
You are in 'detached HEAD' state.
```

**Qué pasó:** estás parado en un commit suelto en vez de en una rama. Suele pasar al hacer click en
un commit viejo o al copiar un comando de internet.

Si no hiciste cambios:

```bash
git switch main
```

Si hiciste cambios que querés conservar, primero guardalos en una rama:

```bash
git switch -c rescate
```

---

## Me pidieron cambios en la PR

No hay que hacer nada especial ni abrir nada nuevo. Con estar parado en **la misma rama**:

```bash
git status
git add .
git commit -m "uso EQU para las constantes del display"
git push
```

El `git status` es para confirmar que dice tu rama y no `main`.

**La PR se actualiza sola.** Andá a la PR en GitHub y vas a ver el commit nuevo ahí.

> ⚠️ **No abras una PR nueva.** Es el error más común y ensucia el historial.

---

## Me equivoqué en el mensaje del último commit

**Si todavía no pusheaste:**

```bash
git commit --amend -m "el mensaje correcto"
```

Si además te faltó incluir un archivo:

```bash
git add el-archivo-que-falto.asm
git commit --amend --no-edit
```

`--no-edit` conserva el mensaje que ya tenías.

**Si ya pusheaste**, dejalo así. Corregirlo requiere reescribir historia y no vale la pena por un
mensaje. Ponelo bien en el próximo.

---

## not a git repository

```
fatal: not a git repository (or any of the parent directories): .git
```

**Qué pasó:** estás corriendo git desde una carpeta que no es el repo.

```bash
pwd
cd C:\Users\TuUsuario\Documents\DIGITAL2_Alcachofas
```

`pwd` te dice dónde estás parado ahora.

---

## Si nada de esto sirve

Mandá mensaje con **la salida de estos dos comandos, copiada y pegada como texto**:

```bash
git status
git log --oneline -5
```

Con eso alcanza para entender qué pasó en casi todos los casos. Una captura de pantalla también
sirve, pero el texto es más fácil de leer.

**Dos cosas que no hay que hacer:**

- **No borres la carpeta para volver a clonar.** Perdés todo el trabajo que no hayas pusheado, y
  casi siempre hay arreglo.
- **No copies comandos de internet que no entiendas**, sobre todo si tienen `--force`, `--hard` o
  `rebase`. Esos sí pueden borrar trabajo de verdad. Preguntá primero.
