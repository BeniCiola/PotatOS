# PotatOS

## Kernel 0.0.1

### Agregado
- Primer Kernel funcional
- Sistema de impresión mediante BIOS
- Mensaje de inicio
- Bucle indefinido provisional

### Cambios
- Se ha eliminado Stage 2 al igual que el Linker
- El Bootloader carga directamente al Kernel en memoria

### Nuevos archivos
- kernel.asm

### Archivos borrados
- stage2.asm
- link.ld


## Kernel 0.0.2

### Agregado
- Terminal funcional
- Sistema de escritura
- Buffer de comandos
- Protección contra Overflow
- Bucle de escritura e impresión en terminal

### Nuevos Archivos
- keyboard.asm


## Kernel 0.0.3

### Agregado
- Sistema de comandos
- Tabla de errores comúnes de terminal

### Nuevos archivos
- commands.asm
- command_clear.asm 

### Comandos agregados
- "clear" para la limpieza de la terminal
- "help" para visualizar todos los comandos del sistema

### Tabla de errores comúnes
- 0x0 = Salida exitosa
- 0x1 = Overflow en el buffer de comandos