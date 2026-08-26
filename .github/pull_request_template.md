Closes #

## Qué hice

<!-- Dos o tres oraciones. Qué resuelve esta PR. -->

## Cómo lo probé

<!-- Simulación en MPLAB X / en la placa. Qué verificaste y qué viste. -->

## Checklist

- [ ] Ensambla sin errores ni warnings en MPLAB X
- [ ] Probado y funciona
- [ ] Todo el código comentado (qué hace cada rutina, qué representa cada variable, por qué esos bits en cada registro)
- [ ] Constantes con `EQU` y variables con `cblock`, sin números sueltos
- [ ] `BANKSEL` antes de tocar registros de otro banco
- [ ] `ANSEL` y `ANSELH` en cero para los pines usados como digitales
- [ ] No subí `build/`, `dist/` ni `.hex`

## Dudas o cosas que no me cierran

<!--
Escribí acá lo que no te convence de tu propia solución, lo que hiciste sin estar seguro
de por qué anda, o lo que te gustaría que mire con atención.
Esto no resta nada en la revisión. Al contrario: es la parte más útil de la PR.
-->
