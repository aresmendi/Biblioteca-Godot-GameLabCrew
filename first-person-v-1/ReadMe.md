# First Person Controller (Godot 3D)

## Controles

- W: forward  
- A: left  
- S: backward  
- D: right  
- Space: jump  
- Shift: run  
- Ctrl: crouch  

---

## 3D Physics

Configuración de capas:

- Layer1: player  
- Layer2: environment  

---

## Estructura del nodo

```
first_person_player (CharacterBody3D)
├── standing_collision (CollisionShape3D)
├── running_collision (CollisionShape3D)
├── crouching_collision (CollisionShape3D)
├── head (Node3D)
│   └── camera (Camera3D)
└── raycast (RayCast3D)
```

---

## Explicación de transformaciones

Formato:
Position (x, y, z) | Rotation (x, y, z) | Size (x, y, z)

### first_person_player
Contiene el script del jugador, que controla el movimiento.

(0, 1, 0) | (0, 0, 0) | (null)

### standing_collision
Define el tamaño de la colisión del jugador cuando está de pie.

(0, 0, 0) | (0, 0, 0) | (0.6, 2, 0.4)

### running_collision
Define la colisión cuando el jugador está corriendo, más larga que standing_collision.

(0, 0, 0) | (0, 0, 0) | (0.65, 2, 1.3)

### crouching_collision
Define la colisión cuando el jugador está agachado, más baja que standing_collision.

(-0.5, 0, 0) | (0, 0, 0) | (0.7, 1, 0.9)

### head
Controla el movimiento de la cámara.

(0, 1, 0) | (0, 0, 0) | (null)

---

## Scripts

### copy_mesh_size.gd

Buenas prácticas:  
Cada objeto debería ser hijo de un StaticBody3D que contenga:

- MeshInstance3D  
- CollisionShape3D  

Funcionalidad:

- Este script se aplica al CollisionShape3D  
- Recibe en una variable el nodo hermano MeshInstance3D  
- En _ready():
  - Comprueba si la referencia es null  
  - Si lo es, busca entre los hijos del nodo padre un MeshInstance3D  
  - Copia el size del mesh al collision  

---

### first_person_player.gd

Variables:

- Referencias a:
  - standing_collision  
  - running_collision  
  - crouching_collision  
- Nodo head (control de cámara)  
- RayCast3D  

Funcionalidad:

- Control del ratón:
  - Se activa y desactiva con ESC  
- Estados del jugador:
  - standing  
  - running  
  - crouching  
  → Se desactivan las demás colisiones y se activa solo la correspondiente  
- Salto:
  - No permite cambiar la dirección mientras el jugador está en el aire  
- Movimiento:
  - Detecta la dirección de input y mueve al jugador en consecuencia  

---

## Referencias

- [Godot 4.X : Ultimate First Person Controller Tutorial ( 2023 )](https://www.youtube.com/watch?v=xIKErMgJ1Yk) - Tutorial base seguido para la implementación del controlador en primera persona