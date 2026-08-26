# 01 — Instalación y configuración

Esto se hace **una sola vez**. Después no lo tocás más.

- [Instalar git](#1-instalar-git)
- [Abrir la terminal donde corresponde](#2-abrir-la-terminal-donde-corresponde)
- [Configurar git](#3-configurar-git)
- [Clonar el repositorio](#4-clonar-el-repositorio)
- [La primera vez que subas algo](#5-la-primera-vez-que-subas-algo)
- [Verificar que quedó todo bien](#6-verificar-que-quedó-todo-bien)

---

## 1. Instalar git

**Windows** — abrí PowerShell y pegá:

```bash
winget install --id Git.Git -e
```

Si `winget` no existe en tu máquina, bajá el instalador de [git-scm.com](https://git-scm.com/download/win)
y dale siguiente a todo. Las opciones por defecto están bien.

**Linux**: `sudo apt install git` · **macOS**: `xcode-select --install`

Cerrá la terminal y abrila de nuevo. Para verificar:

```bash
git --version
```

Tiene que responder algo como `git version 2.47.0`. Si dice "no se reconoce el comando",
cerrá y abrí la terminal otra vez — recién instalado a veces no la toma hasta reiniciarla.

**No hay que instalar nada más.** MPLAB X ya lo tenés de la materia.

---

## 2. Abrir la terminal donde corresponde

Los comandos de git se ejecutan **parado dentro de la carpeta del repositorio**. Si los corrés en
otro lado, git te va a decir `not a git repository` y tiene razón.

Dos formas de pararte donde va:

**Click derecho** sobre la carpeta → *Open Git Bash here* (o *Abrir en Terminal*).

**O a mano**, con `cd`:

```bash
cd C:\Users\TuUsuario\Documents\DIGITAL2_Alcachofas
```

Para saber dónde estás parado ahora mismo: `pwd`.

---

## 3. Configurar git

Git necesita saber quién sos para firmar tus commits. Pegá estos cinco comandos cambiando el nombre
y el mail por los tuyos:

```bash
git config --global user.name "Nombre Apellido"
git config --global user.email "tumail@mi.unc.edu.ar"
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global core.autocrlf true
```

Qué hace cada uno:

| Línea | Para qué |
|---|---|
| `user.name` / `user.email` | Es lo que aparece como autor de cada commit. Usá el mismo mail de tu cuenta de GitHub así te reconoce |
| `init.defaultBranch main` | La rama principal se llama `main`, no `master` |
| `pull.rebase true` | Evita que se llene de commits basura tipo *"Merge branch main into main"* cada vez que sincronizás |
| `core.autocrlf true` | Windows y Linux marcan el fin de línea distinto. Sin esto vas a ver **archivos enteros marcados como modificados sin haberlos tocado** |

Para revisar que quedó bien:

```bash
git config --global --list
```

---

## 4. Clonar el repositorio

Clonar es bajarte una copia completa del repo a tu máquina.

Primero pararte donde quieras que quede la carpeta (por ejemplo, Documentos):

```bash
cd C:\Users\TuUsuario\Documents
git clone https://github.com/juanignaciopineda-dot/DIGITAL2_Alcachofas.git
cd DIGITAL2_Alcachofas
```

Esa URL sale también del botón verde **Code** en la página del repo, pestaña **HTTPS**.

Ojo: `git clone` **crea la carpeta**. No la crees vos antes ni te metas adentro de una carpeta
vacía a clonar ahí.

---

## 5. La primera vez que subas algo

La primera vez que hagas `git push`, git te va a pedir que te identifiques. Se abre solo el
navegador con una ventana de GitHub. Iniciás sesión, le das permiso, y listo: **no te lo vuelve a
pedir nunca más**.

Dos cosas importantes:

- Si te aparece un cuadro pidiendo **usuario y contraseña escritos en la terminal**, tu contraseña
  de GitHub **no va a funcionar** — GitHub no las acepta desde 2021. Cancelá y buscá la opción de
  iniciar sesión por navegador.
- No hace falta generar claves SSH ni tokens ni nada raro. Solo seguir la ventana del navegador.

Si igual se complica, está en [04-problemas-comunes.md](04-problemas-comunes.md).

---

## 6. Verificar que quedó todo bien

Parado dentro de la carpeta del repo:

```bash
git status
```

Tiene que responder algo así:

```
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

Eso significa: estás en la rama `main`, tenés lo último, y no tenés nada sin guardar.
**Todo bien.**

Ya podés seguir con [02-flujo-de-trabajo.md](02-flujo-de-trabajo.md).
