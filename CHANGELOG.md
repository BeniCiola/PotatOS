# PotatOS (Spanish)

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
- Tabla de errores comunes de terminal

### Nuevos archivos
- commands.asm
- command_clear.asm 
- command_help.asm

### Comandos agregados
- "clear" para la limpieza de la terminal
- "help" para visualizar todos los comandos del sistema

### Tabla de errores comunes
- 0x0 = Salida exitosa
- 0x1 = Overflow en el buffer de comandos

## Kernel 0.1.0

### Archivos modificados
- potatounifier.py: Ahora todos los archivos van a extenderse hasta llegar a un múltiplo de 512 bytes (sector)

### Sistema EFS
- Electron File System (EFS) es el nuevo sistema de archivos de PotatOS
- Su nombre es en analogía a los electrones moviendose dentro de una batería de papa con los archivos en el sistema
- Su formato es el clásico 8.3 de DOS: 8 caracteres de nombre, y 3 caracteres sí o sí de formato

### Ramas nuevas
- PotatOS/EFS/: Archivos del sistema Electron File System

### Archivos importantes nuevos
- EFS/bytemap.dat
- EFS/directory.dat
- EFS/efs.asm
- EFS/old_efs.asm (extra)

### Comandos agregados:
- touch archivo: Crea un archivo con nombre y extensión.
- rm archivo: Borra un archivo creado.

### Notas
- Había dejado PotatOS tirado porque había perdido el interés en este proyecto.
- Lo vuelvo a retomar porque encontré de nuevo la inspiración en mi alma, y mi cariño es más poderoso que la frustración.

## Kernel 0.2.0

### Agregado
- Se añadió Onan, un programa que aporta la posibilidad de modificar el contenido de un archivo.
- Compatibilidad de booteo que permite su arranque en hardware real.

### Archivos importantes modificados
- EFS/efs.asm: Nueva forma de diseño con sistema Disk Access Packet.
- lib/print.asm: Nueva función para limpiar la pantalla.
- boot/boot.asm: Modificación para compatibilidad con hardware real.

### Ramas nuevas
- PotatOS/programs/: Programas del sistema.

### Archivos importantes nuevos
- programs/onan.asm: Sistema de edición de texto, dado su nombre por ser una copia barata de Nano, Linux.
- keyboard.asm: Lleva todas las funciones del teclado.

### Comandos nuevos
- onan archivo: Entra a un archivo para modificarlo con el programa Onan.

## Kernel 0.2.1

### Arreglos
- 'touch' ahora limpia el sector antes de otorgarlo al archivo.

### Mejoras
- Onan ahora tiene enter, VAMOOOOOOO.
