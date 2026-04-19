# 🦟 Mosquito - Version 1

## 🎮 Controles

Este proyecto simula el control de un mosquito. A continuación se describen los inputs disponibles y su función.

---

### 🔹 Sistema

- **escape** → `ESC`  
  Salir del juego.

- **pause** → `P`  
  Pausar o reanudar la partida.

---

### 🔹 Acciones del mosquito

- **fly** → `SPACE`  
  Permite volar libremente.

- **cling** → `SHIFT`  
  Permite al mosquito agarrarse o pegarse a superficies (como paredes o techo).

- **feed** → `CTRL`  
  Acción de alimentarse (chupar sangre) cuando está sobre un objetivo.

---

### 🔹 Movimiento

- **forward** → `W`  
  Moverse hacia adelante.

- **left** → `A`  
  Moverse a la izquierda.

- **backward** → `S`  
  Moverse hacia atrás.

- **right** → `D`  
  Moverse a la derecha.

---

## ⚙️ Physics Layers

Se utilizan capas de colisión para organizar las interacciones físicas del juego:

- **player**  
  El mosquito controlado por el jugador.

- **environment**  
  Elementos del entorno (paredes, suelo, techo).

- **target**  
  Seres vivos de los que el mosquito puede alimentarse (con sangre).

- **danger**  
  Elementos que pueden matar al mosquito (spray, raqueta, etc).

---

## 📝 Notas

- El comportamiento del mosquito está diseñado para ser simple en esta versión.
- Algunas acciones dependen del contexto (por ejemplo, *feed* solo funciona si hay un objetivo cercano).
- Las capas físicas permiten controlar qué objetos interactúan entre sí.

---