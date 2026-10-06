/* Pruebas opcionales, después de RegistroEstudiantesDB_Completa.sql.
   Solo crea y modifica una fila de prueba dentro de una transacción.
   ROLLBACK al terminar: no quedan estudiantes de prueba.
   Ejecutar completo, sin una transacción abierta previamente.
*/
USE RegistroEstudiantesDB;
GO
SET NOCOUNT ON;
SET XACT_ABORT OFF;
IF @@TRANCOUNT <> 0
    THROW 51100, N'Ejecute las pruebas sin una transacción abierta previamente.', 1;

DECLARE @Id uniqueidentifier = NEWID();
DECLARE @Carnet nvarchar(30) = N'PRB-' + LEFT(REPLACE(CONVERT(nvarchar(36), @Id), N'-', N''), 24);
DECLARE @Correo nvarchar(150) = CONVERT(nvarchar(36), @Id) + N'@example.invalid';
DECLARE @Carrera int = (SELECT TOP (1) IdCarrera FROM dbo.Carreras WHERE Activa = 1 ORDER BY IdCarrera);
DECLARE @Municipio int = (SELECT TOP (1) IdMunicipio FROM dbo.Municipios ORDER BY IdMunicipio);
IF @Carrera IS NULL OR @Municipio IS NULL
    THROW 51101, N'Faltan catálogos: ejecute primero el script principal.', 1;
DECLARE @CarreraInexistente int = -1;
WHILE EXISTS (SELECT 1 FROM dbo.Carreras WHERE IdCarrera = @CarreraInexistente)
    SET @CarreraInexistente -= 1;
DECLARE @MunicipioInexistente int = -1;
WHILE EXISTS (SELECT 1 FROM dbo.Municipios WHERE IdMunicipio = @MunicipioInexistente)
    SET @MunicipioInexistente -= 1;

DECLARE @Pruebas TABLE (Numero int IDENTITY, Nombre nvarchar(100), SqlPrueba nvarchar(max), ErrorEsperado int);
INSERT INTO @Pruebas (Nombre, SqlPrueba, ErrorEsperado) VALUES
(N'Carnet vacío', N'UPDATE dbo.Estudiantes SET Carnet = N'''' WHERE Id = @Id;', 547),
(N'Nombres con espacios', N'UPDATE dbo.Estudiantes SET Nombres = N''   '' WHERE Id = @Id;', 547),
(N'Apellidos con tabulaciones', N'UPDATE dbo.Estudiantes SET Apellidos = NCHAR(9) WHERE Id = @Id;', 547),
(N'Nacionalidad vacía', N'UPDATE dbo.Estudiantes SET Nacionalidad = N'''' WHERE Id = @Id;', 547),
(N'Nivel académico vacío', N'UPDATE dbo.Estudiantes SET NivelAcademico = N'''' WHERE Id = @Id;', 547),
(N'Sexo fuera de M/F', N'UPDATE dbo.Estudiantes SET Sexo = ''X'' WHERE Id = @Id;', 547),
(N'Fecha futura', N'UPDATE dbo.Estudiantes SET FechaNacimiento = DATEADD(DAY,1,CONVERT(date,GETDATE())) WHERE Id = @Id;', 547),
(N'Menor de 15 años', N'UPDATE dbo.Estudiantes SET FechaNacimiento = DATEADD(YEAR,-14,CONVERT(date,GETDATE())) WHERE Id = @Id;', 547),
(N'Promedio negativo', N'UPDATE dbo.Estudiantes SET Promedio = -0.01 WHERE Id = @Id;', 547),
(N'Promedio mayor que 100', N'UPDATE dbo.Estudiantes SET Promedio = 100.01 WHERE Id = @Id;', 547),
(N'Correo sin arroba', N'UPDATE dbo.Estudiantes SET Correo = N''sin-arroba'' WHERE Id = @Id;', 547),
(N'Correo con dos arrobas', N'UPDATE dbo.Estudiantes SET Correo = N''a@@b'' WHERE Id = @Id;', 547),
(N'Correo con espacio', N'UPDATE dbo.Estudiantes SET Correo = N''a b@dominio'' WHERE Id = @Id;', 547),
(N'Discapacidad sin descripción', N'UPDATE dbo.Estudiantes SET TieneDiscapacidadFisica = 1, DescripcionDiscapacidad = NULL WHERE Id = @Id;', 547),
(N'Discapacidad con descripción vacía', N'UPDATE dbo.Estudiantes SET TieneDiscapacidadFisica = 1, DescripcionDiscapacidad = N''  '' WHERE Id = @Id;', 547),
(N'Carrera inexistente', N'UPDATE dbo.Estudiantes SET IdCarrera = @CarreraInexistente WHERE Id = @Id;', 547),
(N'Municipio inexistente', N'UPDATE dbo.Estudiantes SET IdMunicipio = @MunicipioInexistente WHERE Id = @Id;', 547),
(N'Campo obligatorio NULL', N'UPDATE dbo.Estudiantes SET Nombres = NULL WHERE Id = @Id;', 515),
(N'Carnet duplicado', N'INSERT INTO dbo.Estudiantes
    (Id,Carnet,Nombres,Apellidos,Sexo,FechaNacimiento,Nacionalidad,NivelAcademico,IdCarrera,IdMunicipio,Correo)
    SELECT NEWID(),Carnet,Nombres,Apellidos,Sexo,FechaNacimiento,Nacionalidad,NivelAcademico,IdCarrera,IdMunicipio,
        CONVERT(nvarchar(36),NEWID()) + N''@example.invalid'' FROM dbo.Estudiantes WHERE Id = @Id;', 2601),
(N'Correo duplicado', N'INSERT INTO dbo.Estudiantes
    (Id,Carnet,Nombres,Apellidos,Sexo,FechaNacimiento,Nacionalidad,NivelAcademico,IdCarrera,IdMunicipio,Correo)
    SELECT NEWID(),LEFT(CONVERT(nvarchar(36),NEWID()),30),Nombres,Apellidos,Sexo,FechaNacimiento,Nacionalidad,
        NivelAcademico,IdCarrera,IdMunicipio,Correo FROM dbo.Estudiantes WHERE Id = @Id;', 2601);

DECLARE @Resultados TABLE (Prueba nvarchar(100), Correcta bit, Detalle nvarchar(2048));
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO dbo.Estudiantes
        (Id,Carnet,Cedula,Nombres,Apellidos,Sexo,FechaNacimiento,Nacionalidad,NivelAcademico,
         TieneTutor,IdCarrera,IdMunicipio,Etnia,Correo,Promedio,TieneDiscapacidadFisica,
         DescripcionDiscapacidad,EsInterno,Activo)
    VALUES (@Id,@Carnet,NULL,N'Estudiante de prueba',N'Validaciones','M',
        DATEADD(YEAR,-20,CONVERT(date,GETDATE())),N'Nicaragüense',N'Universitario',
        0,@Carrera,@Municipio,NULL,@Correo,85.50,0,NULL,0,1);
    INSERT INTO @Resultados VALUES (N'Inserción equivalente al programa',1,N'La fila válida fue aceptada.');

    UPDATE dbo.Estudiantes SET FechaNacimiento = DATEADD(YEAR,-15,CONVERT(date,GETDATE())), Promedio = 0 WHERE Id = @Id;
    UPDATE dbo.Estudiantes SET Promedio = 100, TieneDiscapacidadFisica = 1,
        DescripcionDiscapacidad = N'Descripción de prueba' WHERE Id = @Id;
    UPDATE dbo.Estudiantes SET TieneDiscapacidadFisica = 0, DescripcionDiscapacidad = NULL, Promedio = 85.50 WHERE Id = @Id;
    INSERT INTO @Resultados VALUES (N'Valores límite válidos',1,N'Edad de 15 años, promedios 0/100 y discapacidad descrita aceptados.');

    DECLARE @Numero int = 1, @Total int = (SELECT COUNT(*) FROM @Pruebas);
    DECLARE @Nombre nvarchar(100), @Sql nvarchar(max), @Error int;
    WHILE @Numero <= @Total
    BEGIN
        SELECT @Nombre = Nombre, @Sql = SqlPrueba, @Error = ErrorEsperado FROM @Pruebas WHERE Numero = @Numero;
        SAVE TRANSACTION AntesDePrueba;
        BEGIN TRY
            EXEC sys.sp_executesql @Sql,
                N'@Id uniqueidentifier, @CarreraInexistente int, @MunicipioInexistente int',
                @Id, @CarreraInexistente, @MunicipioInexistente;
            INSERT INTO @Resultados VALUES (@Nombre,0,N'El dato inválido fue aceptado. Revisar la regla.');
        END TRY
        BEGIN CATCH
            IF XACT_STATE() <> 1 THROW;
            INSERT INTO @Resultados VALUES (@Nombre,
                CASE WHEN ERROR_NUMBER() = @Error OR (@Error = 2601 AND ERROR_NUMBER() = 2627) THEN 1 ELSE 0 END,
                ERROR_MESSAGE());
        END CATCH;
        ROLLBACK TRANSACTION AntesDePrueba;
        SET @Numero += 1;
    END;
    ROLLBACK TRANSACTION;
    SELECT Prueba, CASE WHEN Correcta = 1 THEN N'OK' ELSE N'FALLO' END AS Resultado, Detalle FROM @Resultados;
    IF EXISTS (SELECT 1 FROM @Resultados WHERE Correcta = 0)
        THROW 51102, N'Alguna validación no produjo el resultado esperado. Revise la tabla de resultados.', 1;
    PRINT N'Las 22 comprobaciones terminaron. La fila de prueba fue revertida.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
