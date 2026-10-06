# Base de datos compatible con RegistroEstudiantes

## Archivos y orden de ejecución

1. Abra `RegistroEstudiantesDB_Completa.sql` en SQL Server Management Studio (SSMS), conectado a su instancia real, y ejecute el archivo completo. El script crea `RegistroEstudiantesDB` si falta y utiliza esa base.
2. Si termina correctamente, puede ejecutar `Pruebas_Validaciones.sql`. Contiene 22 comprobaciones de inserción, actualización, restricciones y duplicados; la fila sintética se revierte al finalizar. No ejecute fragmentos aislados ni lo ejecute dentro de otra transacción.
3. Configure `Server` en `RegistrosEstudiantes-main/Datos/ConexionBD.cs` con el mismo servidor al que se conectó en SSMS. Conserve `Database=RegistroEstudiantesDB`. El script de base de datos no cambia la conexión de C#.

No se ejecutó la instalación sobre su base real. Se revisó la sintaxis de ambos archivos y de los lotes internos de procedimientos con el analizador T-SQL disponible, sin errores. Para esa revisión de los cuerpos se normalizó `CREATE OR ALTER PROCEDURE` a `CREATE PROCEDURE`, porque el analizador disponible corresponde a una versión antigua; los archivos entregados usan `CREATE OR ALTER`, compatible con SQL Server 2019. La compilación, las reglas y las pruebas de ejecución todavía requieren un servidor accesible.

## Qué se conserva y qué se completa

El script parte de su `BD Guia 2 , Acceso datos.sql`; conserva nombres y tipos utilizados por las guías y por los repositorios actuales. Puede ejecutarse nuevamente sobre el esquema de esa guía: crea tablas ausentes, agrega reglas que faltan y no duplica catálogos. No borra ni reinserta estudiantes existentes. Los procedimientos indicados se crean o actualizan.

Los cambios dentro de la base se realizan en una transacción. Si algún dato existente infringe una regla o hay un esquema incompatible, se revierte esa preparación y se informa el error; no se corrigen ni se eliminan registros automáticamente. Si el script creó una base nueva antes de esa transacción, la base vacía puede quedar creada aunque la preparación falle.

El script verifica 58 columnas y los tipos básicos del esquema existente. Está diseñado para el esquema de su script anterior, no para convertir automáticamente cualquier otro diseño de tablas. Si una tabla fue personalizada, revise el error y su definición antes de repetir.

## Tablas

| Tabla | Uso |
| --- | --- |
| AreasConocimiento | Áreas DACTIC, DACA, DACIP y Otra. |
| Carreras | Carrera asociada a un área y su estado activo. |
| Departamentos | Catálogo de departamentos. |
| Municipios | Municipio asociado a un departamento. |
| Estudiantes | Datos personales y académicos, claves de carrera y municipio, estado activo. |
| Tutores | Un tutor como máximo por estudiante. |
| Roles | Administrador, Registro y Consulta. |
| Usuarios | Usuario, hash y salt, rol y estudiante opcional. |
| Asignaturas | Código, nombre, créditos y estado. |
| Prerrequisitos | Relaciones entre asignaturas, sin autorreferencia directa. |
| EstudianteAsignaturas | Nota y aprobación por estudiante y asignatura. |

Área y departamento se obtienen mediante JOIN, igual que en su programa. No se guardan duplicados en Estudiantes. El ID del estudiante es `uniqueidentifier`, compatible con `Guid` de C#; se agrega `NEWID()` como valor predeterminado para permitir también inserciones manuales.

## Validaciones incluidas

- Carnet y correo únicos, incluso para estudiantes desactivados, como en la guía.
- Campos obligatorios no NULL y con contenido: carnet, nombres, apellidos, nacionalidad, nivel académico y correo. Se rechazan también cadenas compuestas solo por espacios, tabulaciones, saltos de línea o espacios no separables.
- Sexo M o F y promedio entre 0 y 100 con dos decimales.
- Edad mínima de 15 años: nacimiento igual o anterior a la fecha actual menos 15 años. La fecha de referencia es la del servidor SQL; conviene que servidor y aplicación tengan la misma fecha local.
- Descripción obligatoria cuando se marca discapacidad física; una descripción NULL no evade el CHECK.
- Validación básica del correo: un único `@`, contenido antes y después, sin espacios ni tabulaciones/saltos de línea. La validación completa del formato continúa en `ValidadorEstudiante` mediante `MailAddress`; un CHECK SQL sencillo no sustituye esa validación.
- Claves foráneas de carrera, municipio, tutores, usuarios, roles y asignaturas.
- Nombres de carrera únicos dentro de cada área; nombres de municipio únicos dentro de cada departamento.
- Nombres, códigos y usuarios obligatorios con contenido en sus respectivos catálogos.
- Hash de contraseña de 64 bytes y salt de 32 bytes, compatibles con el ejemplo PBKDF2 de la guía. No se crean usuarios con contraseñas inventadas.
- Créditos positivos, notas entre 0 y 100 y rechazo de una asignatura como prerrequisito de sí misma.

Cédula, etnia y descripción de discapacidad cuando no está marcada son opcionales, como en su programa. No se impone un patrón de carnet o de cédula que las guías no definan. Tampoco se inventa una nota mínima de aprobación: `Aprobada` se conserva como la bandera de la guía. La restricción de autorreferencia no detecta ciclos indirectos de prerrequisitos; esa sería una regla adicional.

Las tablas de tutores, usuarios y asignaturas quedan preparadas, pero su proyecto actual no contiene todavía formularios/repositorios para gestionar esos módulos. Crear tablas no implementa inicio de sesión ni permisos. No se exige una fila de tutor al marcar `TieneTutor`, porque el formulario actual solo guarda la bandera y no captura datos de tutor; cuando incorpore ese formulario, use la transacción estudiante+tutor de la guía.

## Catálogos iniciales

Los datos se toman de la Unidad II: cuatro áreas, dos carreras de DACTIC, tres departamentos, cuatro municipios y tres roles. Se insertan enlazando los nombres, sin suponer que los IDs empiezan en 1. Se utilizan literales Unicode para conservar tildes y la ñ.

Estos son catálogos de práctica, no el catálogo nacional ni el oficial de la universidad. DACA, DACIP y Otra quedan sin carreras hasta que se agreguen las correspondientes. No se cargan estudiantes ficticios automáticamente.

## Procedimientos

- `dbo.usp_ListarEstudiantesActivos`: devuelve las columnas del mapeador de C#, incluidos `Carrera`, `Area`, `Municipio` y `Departamento`.
- `dbo.sp_Estudiantes_ListarActivos`: conserva el nombre utilizado en la guía anterior y devuelve el mismo resultado.
- `dbo.usp_ListarAsignaturasAprobadas @IdEstudiante`: consulta las asignaturas aprobadas.
- `dbo.usp_ListarCursosDisponibles @IdEstudiante`: consulta asignaturas activas aún no aprobadas cuyos prerrequisitos ya fueron aprobados. El llamador debe pasar el ID de un estudiante existente.

Se corrigió el alias anterior `AreaConocimiento` a `Area`, porque `MapearEstudiante` busca precisamente ese nombre. Las consultas parametrizadas del CRUD actual siguen funcionando aunque no llame a los procedimientos; también pueden usarse desde ADO.NET asíncrono con `CommandType.StoredProcedure`.

## Si falla por datos antiguos

El mensaje indicará el nombre de la restricción. Ejemplos:

| Restricción | Qué revisar |
| --- | --- |
| CK_RE_Estudiantes_EdadMinima | Fecha de nacimiento y edad del estudiante. |
| CK_RE_Estudiantes_Discapacidad | Discapacidad marcada sin descripción válida. |
| CK_RE_Estudiantes_Correo_FormatoBasico | Correo sin `@`, con varios `@` o espacios. |
| CK_RE_Estudiantes_Nombres_Contenido | Nombres vacíos o con solo espacios. |
| UX_RE_Carreras_AreaNombre | Carreras repetidas dentro de la misma área. |
| UX_RE_Municipios_DepartamentoNombre | Municipios repetidos dentro del mismo departamento. |

Para localizar los casos más habituales sin modificar registros:

```sql
USE RegistroEstudiantesDB;
SELECT Id, Carnet, FechaNacimiento
FROM dbo.Estudiantes
WHERE FechaNacimiento > DATEADD(YEAR,-15,CONVERT(date,GETDATE()));

SELECT Id, Carnet, DescripcionDiscapacidad
FROM dbo.Estudiantes
WHERE TieneDiscapacidadFisica = 1
  AND (DescripcionDiscapacidad IS NULL
       OR LEN(LTRIM(RTRIM(DescripcionDiscapacidad))) = 0);

SELECT IdArea, Nombre, COUNT(*) AS Repeticiones
FROM dbo.Carreras
GROUP BY IdArea, Nombre HAVING COUNT(*) > 1;
```

Revise y corrija conscientemente los registros afectados, luego vuelva a ejecutar el script completo.

## Fuentes utilizadas

- Unidad I: validaciones del modelo y formulario, páginas 12-13.
- Unidad II, Acceso a Datos: esquema completo, catálogos, transacciones, roles y asignaturas, páginas 2-4 y 10-12.
- Unidad II, Puente a Unidad III: nombres de columnas del programa y procedimiento con alias `Area`, página 17.
- Unidad III: conservación del SQL del CRUD, ejecución ADO.NET asíncrona y conexiones independientes.
- Su script anterior y los archivos actuales `EstudianteRepository`, `CatalogoRepository`, `Estudiante` y `ValidadorEstudiante`.

Las copias numeradas de cada guía aportada tienen el mismo contenido de texto; se comprobaron para evitar tratar cada copia como un esquema distinto.
