# LogiExpress
Motor analítico para la optimización y validación de rutas e itinerarios interurbanos de transporte aéreo desarrollado bajo los paradigmas Lógico (Prolog) y Funcional (Haskell).

## Estructura del Repositorio

```text
LogiExpress/
├── README.md # Instrucciones de compilación, ejecución y estado del proyecto
├── vuelos.txt # Base de datos de prueba
├── .gitignore # Archivos compilados e intermedios (.o, .hi, binarios, etc.)
├── /haskell # Solución en Paradigma Funcional (Módulo Main + CLI)
└── /prolog # Solución en Paradigma Lógico (Módulo Main + CLI)
```
---
## Compilación y Ejecución

### Prerequisitos

- **Haskell**: Glasgow Haskell Compiler (`ghc` v8.10+).
- **Prolog**: SWI-Prolog (`swipl` v8.4+).

---

### Haskell

   ```bash
   cd haskell
   runhghc Main.hs
   ```

### Prolog

   ```bash
   cd prolog
   swipl main.pl
   ```
---
## 📌 Estado del Proyecto

Actualmente, el proyecto se encuentra completamente estructurado y funcional en ambos paradigmas, cumpliendo con la totalidad de los módulos requeridos por la especificación técnica:

- [x] **Módulo 1: Carga Dinámica y Consultas Básicas**
  - Parseo dinámico del archivo de datos.
  - Gestión parametrizada del **Tiempo Mínimo de Conexión (TMC)** global.
  - Consultas rápidas de partidas y llegadas por ciudad.
- [x] **Módulo 2: Búsqueda Avanzada de Rutas**
  - Generación de Rutas Válidas: Dadas dos ciudades (Origen y Destino) y un día de la semana específico, determinar todas las rutas válidas directas o con escalas entre ellas.
    - Cada vuelo de la secuencia debe estar disponible en el día consultado.
    - Para dos vuelos consecutivos y , la hora de salida de debe V1 y V2 la hora de salida de V2 debe ser mayor o igual a la hora de llegada de V1 más el TMC configurado.
    - Evitar visitar la misma ciudad más de una vez en un mismo itinerario.
    - Permitir definir opcionalmente un número máximo de escalas K.
- [ ] **Módulo 3: Optimización y Filtrado de Rutas**
  - Cálculo e identificación de la **Ruta de Costo Económico Mínimo**.
  - Cálculo e identificación de la **Ruta de Menor Tiempo Total de Viaje** (incluyendo la espera en conexiones).
  - Reportes ordenados por precio y por tiempo mediante algoritmos de ordenamiento sobre listas.
- [x] **Interfaces de Usuario CLI**
  - Menú interactivo en consola tanto para GHCi/Haskell como para SWI-Prolog.