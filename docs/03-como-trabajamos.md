# 03 — Cómo trabajamos

Media página de proceso y una checklist. El resto del tiempo, a hacer assembler.

- [SCRUM en dos párrafos](#scrum-en-dos-párrafos)
- [Los roles](#los-roles)
- [Cómo se traduce a GitHub](#cómo-se-traduce-a-github)
- [Cómo nos comunicamos](#cómo-nos-comunicamos)
- [Definition of Done](#definition-of-done)
- [Labels](#labels)
- [Dónde va cada archivo](#dónde-va-cada-archivo)
- [Qué no se sube y por qué](#qué-no-se-sube-y-por-qué)

---

## SCRUM en dos párrafos

SCRUM es una forma de organizar trabajo en equipo. La idea de fondo: en vez de planificar todo al
principio y descubrir al final que estaba mal, se trabaja en ciclos cortos llamados **sprints**,
y al final de cada uno tiene que haber **algo que funcione y se pueda mostrar**.

Toda la lista de cosas por hacer se llama **backlog**. Al empezar el sprint se elige un pedazo del
backlog para ese ciclo. Eso es todo lo que hay que saber para arrancar.

---

## Los roles

| Rol | Quién | Qué hace |
|---|---|---|
| **Product Owner** | La cátedra / el enunciado del TP | Define qué hay que construir y con qué prioridad |
| **Scrum Master** | Yo | Armo los issues, reviso las PR, destrabo lo que se trabe |
| **Developers** | Ustedes | Resuelven los issues |

Aclaración que importa: **el Scrum Master no es el jefe.** Mi trabajo es sacar obstáculos del
camino, no repartir órdenes. Si algo del proceso les está haciendo perder tiempo en vez de
ayudarlos, díganmelo y lo cambiamos.

---

## Cómo se traduce a GitHub

No hace falta ninguna herramienta aparte. Todo vive en el repo:

| En SCRUM se llama | En GitHub es |
|---|---|
| Product Backlog | Todos los issues abiertos |
| Sprint Backlog | Los issues del **milestone activo** |
| Sprint | Un **milestone**, con su fecha de cierre |
| Tarea en curso | Un issue **asignado** a alguien |
| Incremento | Lo que está integrado en `main` |

Las fechas de cada sprint las aviso yo y quedan como fecha de cierre del milestone.
Para ver qué entra en el sprint actual: **Issues → Milestones → el que esté abierto**.

---

## Cómo nos comunicamos

**Por mensaje, en el día a día.** Ese es el canal principal.

**Una reunión semanal, y solo si hace falta.** La convoco yo cuando hay algo que realmente
necesita hablarse en vivo. No hay daily, no hay planning, no hay retro formal: son cuatro personas
haciendo un TP, no una empresa.

**Por ahora no estimamos tareas.** No te preocupes por cuánto "vale" un issue. Agarrá uno y
terminalo.

**WIP: un issue asignado por persona a la vez.** Tener cinco cosas empezadas y ninguna terminada
es peor que tener una sola andando.

### Si estás trabado

Dos cosas, las dos:

1. **Avisá por mensaje.** Es lo que destraba rápido.
2. **Dejá un comentario en el issue** contando qué probaste y qué pasó.

El comentario no es para pedir permiso ni para justificarte: es para que quede registro. Dentro de
dos semanas, cuando alguien se choque con lo mismo, ese comentario le ahorra la tarde.

Si vas a estar trabado un rato largo, ponele la label `bloqueado` al issue.

**Estar trabado es parte de aprender esto. Estar trabado en silencio tres días, no.**

---

## Definition of Done

Una tarea no está terminada cuando "anda en mi máquina". Está terminada cuando cumple **todo** esto:

- [ ] **Ensambla sin errores ni warnings** en MPLAB X
- [ ] **Probado** en simulación o en la placa, y funciona
- [ ] **Todo el código comentado**
- [ ] **Constantes con `EQU`** y variables con `cblock`, en vez de números sueltos en el código
- [ ] **`BANKSEL` antes de tocar registros de otro banco**
- [ ] **`ANSEL` y `ANSELH` en cero** para los pines que uses como digitales
- [ ] **La PR está aprobada**

Esta checklist viene cargada en la plantilla de la PR. Es literalmente lo que voy a revisar.

### Sobre comentar el código

Es el punto que más peso tiene, así que va aparte.

**Qué sí:**
- Un encabezado en cada archivo: qué hace, quién lo escribió.
- Arriba de cada rutina: qué hace, qué espera recibir y qué deja como resultado.
- Al declarar cada variable: qué representa.
- **Al configurar un registro: por qué esos bits.** Este es el más importante de todos.

**Qué no hace falta:** comentar instrucción por instrucción. `movlw 0x00 ; cargo 0 en W` no le
sirve a nadie — eso ya lo dice la instrucción.

La prueba: **si alguien que no escribió ese código lo lee, ¿entiende qué está pasando?**

Ejemplo de la diferencia:

```asm
; ✗ no aporta nada
    banksel ANSEL
    clrf    ANSEL       ; limpio ANSEL

; ✓ esto sí
    banksel ANSEL
    clrf    ANSEL       ; el 16F887 arranca con los pines analógicos: hay que
    clrf    ANSELH      ; ponerlos en digital o las lecturas del puerto dan 0
```

En esta materia el código se lee más veces de las que se escribe. Los comentarios no son un
requisito burocrático: son la mitad del trabajo.

---

## Labels

| Label | Cuándo |
|---|---|
| `tp1`, `tp2` | A qué trabajo práctico pertenece |
| `bug` | Algo que ya está integrado y anda mal |
| `documentación` | Informe, esquemáticos, comentarios |
| `bloqueado` | No se puede avanzar hasta que se resuelva otra cosa |
| `hardware` | Necesita la placa, no alcanza con simular |
| `buena-primera-tarea` | Chica y autocontenida, buena para arrancar |

No hay labels de esfuerzo ni de prioridad: la prioridad la marca el milestone.

---

## Dónde va cada archivo

```
tp1/
├── src/        ← los .asm y los .inc
└── TP1.X/      ← el proyecto de MPLAB X
```

Los fuentes van en `src/` y **no** adentro de la carpeta `.X`. La razón es práctica: la carpeta
`.X` está casi entera en el `.gitignore`, así que si dejáramos el código ahí adentro se mezclaría
con archivos que git ignora y sería un lío.

Para que MPLAB X vea los fuentes en `src/`: click derecho sobre **Source Files** en el árbol del
proyecto → **Add Existing Item...** → elegí el archivo → y marcá la opción de agregarlo con
**ruta relativa** (*relative path*), no absoluta. Si lo agrega con ruta absoluta, en la máquina de
otro no va a compilar porque esa ruta no existe.

### ⚠️ Sobre `nbproject/configurations.xml`

Es un archivo XML que MPLAB X genera solo, y **da conflictos horribles** cuando dos personas lo
tocan a la vez. Se modifica cada vez que agregás o sacás un archivo del proyecto.

Regla práctica: **si vas a agregar un archivo nuevo al proyecto de MPLAB, avisá por mensaje.**
Que no lo hagan dos personas el mismo día y nos ahorramos el problema.

---

## Qué no se sube y por qué

Estos archivos están en el `.gitignore` y no se suben:

| Qué | Por qué |
|---|---|
| `build/`, `dist/` | Los crea MPLAB X al ensamblar |
| `*.hex` | Es la salida compilada. Se regenera ensamblando |
| `*.lst`, `*.map`, `*.cod`, `*.err` | Reportes que genera MPASM |
| `nbproject/private/` | Configuración de tu máquina: rutas y preferencias tuyas |

La lógica es siempre la misma: **si se regenera solo, no va al repo.** Ocupan lugar, cambian en
cada compilada y generan conflictos constantes sin aportar nada.

Si la cátedra pide el `.hex` para la entrega, va adjunto donde lo pidan, no versionado acá.

Si alguna vez subiste algo de esto sin querer, está el arreglo en
[04-problemas-comunes.md](04-problemas-comunes.md).
