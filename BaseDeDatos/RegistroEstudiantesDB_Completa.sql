/* RegistroEstudiantesDB - Unidades I, II y III
   SQL Server 2019 o posterior. Ejecutar completo en SSMS.
   Crea tablas ausentes; conserva filas existentes. No contiene DROP ni DELETE.
   Si los datos existentes incumplen una regla, revierte los cambios dentro
   de la base y muestra el error. Corregir los datos conscientemente y repetir.
   La creación de una base nueva queda fuera de esa transacción.
   Basado en las guías y en BD Guia 2 , Acceso datos.sql del usuario.
*/
USE master;
GO
IF DB_ID(N'RegistroEstudiantesDB') IS NULL
    EXEC(N'CREATE DATABASE RegistroEstudiantesDB;');
GO
USE RegistroEstudiantesDB;
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.AreasConocimiento', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.AreasConocimiento (
    IdArea INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(50) NOT NULL UNIQUE
        );
    END;

    IF OBJECT_ID(N'dbo.Carreras', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Carreras (
    IdCarrera INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(120) NOT NULL,
    IdArea INT NOT NULL,
    Activa BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Carreras_Areas FOREIGN KEY (IdArea) REFERENCES dbo.AreasConocimiento(IdArea)
        );
    END;

    IF OBJECT_ID(N'dbo.Departamentos', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Departamentos (
    IdDepartamento INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(80) NOT NULL UNIQUE
        );
    END;

    IF OBJECT_ID(N'dbo.Municipios', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Municipios (
    IdMunicipio INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    IdDepartamento INT NOT NULL,
    CONSTRAINT FK_Municipios_Departamentos FOREIGN KEY (IdDepartamento) REFERENCES dbo.Departamentos(IdDepartamento)
        );
    END;

    IF OBJECT_ID(N'dbo.Estudiantes', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Estudiantes (
    Id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    Carnet NVARCHAR(30) NOT NULL UNIQUE,
    Cedula NVARCHAR(30) NULL,
    Nombres NVARCHAR(100) NOT NULL,
    Apellidos NVARCHAR(100) NOT NULL,
    Sexo CHAR(1) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    Nacionalidad NVARCHAR(60) NOT NULL,
    NivelAcademico NVARCHAR(60) NOT NULL,
    TieneTutor BIT NOT NULL DEFAULT 0,
    IdCarrera INT NOT NULL,
    IdMunicipio INT NOT NULL,
    Etnia NVARCHAR(60) NULL,
    Correo NVARCHAR(150) NOT NULL UNIQUE,
    Promedio DECIMAL(5,2) NOT NULL DEFAULT 0,
    TieneDiscapacidadFisica BIT NOT NULL DEFAULT 0,
    DescripcionDiscapacidad NVARCHAR(300) NULL,
    EsInterno BIT NOT NULL DEFAULT 0,
    Activo BIT NOT NULL DEFAULT 1,
    FechaRegistro DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT CK_Estudiantes_Sexo CHECK (Sexo IN ('M','F')),
    CONSTRAINT CK_Estudiantes_Promedio CHECK (Promedio BETWEEN 0 AND 100),
    CONSTRAINT FK_Estudiantes_Carreras FOREIGN KEY (IdCarrera) REFERENCES dbo.Carreras(IdCarrera),
    CONSTRAINT FK_Estudiantes_Municipios FOREIGN KEY (IdMunicipio) REFERENCES dbo.Municipios(IdMunicipio)
        );
    END;

    IF OBJECT_ID(N'dbo.Tutores', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Tutores (
    IdTutor INT IDENTITY(1,1) PRIMARY KEY,
    IdEstudiante UNIQUEIDENTIFIER NOT NULL UNIQUE,
    NombreCompleto NVARCHAR(150) NOT NULL,
    Parentesco NVARCHAR(50) NOT NULL,
    Telefono NVARCHAR(30) NULL,
    Correo NVARCHAR(150) NULL,
    CONSTRAINT FK_Tutores_Estudiantes FOREIGN KEY (IdEstudiante) REFERENCES dbo.Estudiantes(Id)
        );
    END;

    IF OBJECT_ID(N'dbo.Roles', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Roles (
    IdRol INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(40) NOT NULL UNIQUE
        );
    END;

    IF OBJECT_ID(N'dbo.Usuarios', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Usuarios (
    IdUsuario INT IDENTITY(1,1) PRIMARY KEY,
    IdEstudiante UNIQUEIDENTIFIER NULL,
    NombreUsuario NVARCHAR(60) NOT NULL UNIQUE,
    ClaveHash VARBINARY(64) NOT NULL,
    ClaveSalt VARBINARY(32) NOT NULL,
    IdRol INT NOT NULL,
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Usuarios_Estudiantes FOREIGN KEY (IdEstudiante) REFERENCES dbo.Estudiantes(Id),
    CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (IdRol) REFERENCES dbo.Roles(IdRol)
        );
    END;

    IF OBJECT_ID(N'dbo.Asignaturas', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Asignaturas (
    IdAsignatura INT IDENTITY(1,1) PRIMARY KEY,
    Codigo NVARCHAR(20) NOT NULL UNIQUE,
    Nombre NVARCHAR(120) NOT NULL,
    Creditos INT NOT NULL DEFAULT 3,
    Activa BIT NOT NULL DEFAULT 1
        );
    END;

    IF OBJECT_ID(N'dbo.Prerrequisitos', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Prerrequisitos (
    IdAsignatura INT NOT NULL,
    IdAsignaturaPrerrequisito INT NOT NULL,
    CONSTRAINT PK_Prerrequisitos PRIMARY KEY (IdAsignatura, IdAsignaturaPrerrequisito),
    CONSTRAINT FK_Prereq_Asignatura FOREIGN KEY (IdAsignatura) REFERENCES dbo.Asignaturas(IdAsignatura),
    CONSTRAINT FK_Prereq_Requisito FOREIGN KEY (IdAsignaturaPrerrequisito) REFERENCES dbo.Asignaturas(IdAsignatura)
        );
    END;

    IF OBJECT_ID(N'dbo.EstudianteAsignaturas', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.EstudianteAsignaturas (
    IdEstudiante UNIQUEIDENTIFIER NOT NULL,
    IdAsignatura INT NOT NULL,
    Nota DECIMAL(5,2) NOT NULL,
    Aprobada BIT NOT NULL,
    CONSTRAINT PK_EstudianteAsignaturas PRIMARY KEY (IdEstudiante, IdAsignatura),
    CONSTRAINT FK_EA_Estudiante FOREIGN KEY (IdEstudiante) REFERENCES dbo.Estudiantes(Id),
    CONSTRAINT FK_EA_Asignatura FOREIGN KEY (IdAsignatura) REFERENCES dbo.Asignaturas(IdAsignatura)
        );
    END;

    -- Detecta un esquema previo incompatible, en lugar de cambiarlo silenciosamente.
    DECLARE @Esquema TABLE
    (Tabla sysname, Columna sysname, Tipo sysname, LongitudMinima int, PermiteNull bit);
    INSERT INTO @Esquema VALUES
        (N'AreasConocimiento', N'Nombre', N'nvarchar', 100, 0),
        (N'Carreras', N'Nombre', N'nvarchar', 240, 0),
        (N'Carreras', N'IdArea', N'int', 0, 0),
        (N'Carreras', N'Activa', N'bit', 0, 0),
        (N'Departamentos', N'Nombre', N'nvarchar', 160, 0),
        (N'Municipios', N'Nombre', N'nvarchar', 200, 0),
        (N'Municipios', N'IdDepartamento', N'int', 0, 0),
        (N'Estudiantes', N'Id', N'uniqueidentifier', 0, 0),
        (N'Estudiantes', N'Carnet', N'nvarchar', 60, 0),
        (N'Estudiantes', N'Cedula', N'nvarchar', 60, 1),
        (N'Estudiantes', N'Nombres', N'nvarchar', 200, 0),
        (N'Estudiantes', N'Apellidos', N'nvarchar', 200, 0),
        (N'Estudiantes', N'Sexo', N'char', 1, 0),
        (N'Estudiantes', N'FechaNacimiento', N'date', 0, 0),
        (N'Estudiantes', N'Nacionalidad', N'nvarchar', 120, 0),
        (N'Estudiantes', N'NivelAcademico', N'nvarchar', 120, 0),
        (N'Estudiantes', N'TieneTutor', N'bit', 0, 0),
        (N'Estudiantes', N'IdCarrera', N'int', 0, 0),
        (N'Estudiantes', N'IdMunicipio', N'int', 0, 0),
        (N'Estudiantes', N'Etnia', N'nvarchar', 120, 1),
        (N'Estudiantes', N'Correo', N'nvarchar', 300, 0),
        (N'Estudiantes', N'Promedio', N'decimal', 0, 0),
        (N'Estudiantes', N'TieneDiscapacidadFisica', N'bit', 0, 0),
        (N'Estudiantes', N'DescripcionDiscapacidad', N'nvarchar', 600, 1),
        (N'Estudiantes', N'EsInterno', N'bit', 0, 0),
        (N'Estudiantes', N'Activo', N'bit', 0, 0),
        (N'Estudiantes', N'FechaRegistro', N'datetime2', 0, 0),
        (N'Tutores', N'IdEstudiante', N'uniqueidentifier', 0, 0),
        (N'Tutores', N'NombreCompleto', N'nvarchar', 300, 0),
        (N'Tutores', N'Parentesco', N'nvarchar', 100, 0),
        (N'Tutores', N'Telefono', N'nvarchar', 60, 1),
        (N'Tutores', N'Correo', N'nvarchar', 300, 1),
        (N'Roles', N'Nombre', N'nvarchar', 80, 0),
        (N'Usuarios', N'IdEstudiante', N'uniqueidentifier', 0, 1),
        (N'Usuarios', N'NombreUsuario', N'nvarchar', 120, 0),
        (N'Usuarios', N'ClaveHash', N'varbinary', 64, 0),
        (N'Usuarios', N'ClaveSalt', N'varbinary', 32, 0),
        (N'Usuarios', N'IdRol', N'int', 0, 0),
        (N'Usuarios', N'Activo', N'bit', 0, 0),
        (N'Usuarios', N'FechaCreacion', N'datetime2', 0, 0),
        (N'Asignaturas', N'Codigo', N'nvarchar', 40, 0),
        (N'Asignaturas', N'Nombre', N'nvarchar', 240, 0),
        (N'Asignaturas', N'Creditos', N'int', 0, 0),
        (N'Asignaturas', N'Activa', N'bit', 0, 0),
        (N'Prerrequisitos', N'IdAsignatura', N'int', 0, 0),
        (N'Prerrequisitos', N'IdAsignaturaPrerrequisito', N'int', 0, 0),
        (N'EstudianteAsignaturas', N'IdEstudiante', N'uniqueidentifier', 0, 0),
        (N'EstudianteAsignaturas', N'IdAsignatura', N'int', 0, 0),
        (N'EstudianteAsignaturas', N'Nota', N'decimal', 0, 0),
        (N'EstudianteAsignaturas', N'Aprobada', N'bit', 0, 0),
        (N'AreasConocimiento', N'IdArea', N'int', 0, 0),
        (N'Carreras', N'IdCarrera', N'int', 0, 0),
        (N'Departamentos', N'IdDepartamento', N'int', 0, 0),
        (N'Municipios', N'IdMunicipio', N'int', 0, 0),
        (N'Tutores', N'IdTutor', N'int', 0, 0),
        (N'Roles', N'IdRol', N'int', 0, 0),
        (N'Usuarios', N'IdUsuario', N'int', 0, 0),
        (N'Asignaturas', N'IdAsignatura', N'int', 0, 0);
    IF EXISTS (
        SELECT 1 FROM @Esquema e
        LEFT JOIN sys.columns c ON c.object_id = OBJECT_ID(N'dbo.' + e.Tabla)
            AND c.name = e.Columna
        LEFT JOIN sys.types t ON t.user_type_id = c.user_type_id
        WHERE c.column_id IS NULL OR t.name <> e.Tipo
            OR (e.LongitudMinima > 0 AND c.max_length <> -1 AND c.max_length < e.LongitudMinima)
            OR (e.PermiteNull = 0 AND c.is_nullable = 1)
    )
        THROW 51001, N'El esquema existente no coincide con las columnas y tipos de la guía. No se modificaron datos. Revise las tablas antes de repetir.', 1;

    IF EXISTS (SELECT 1 FROM sys.columns WHERE
        (object_id = OBJECT_ID(N'dbo.Estudiantes') AND name = N'Promedio'
         OR object_id = OBJECT_ID(N'dbo.EstudianteAsignaturas') AND name = N'Nota')
        AND (precision < 5 OR scale <> 2))
        THROW 51002, N'Promedio y Nota deben admitir DECIMAL(5,2). Revise el esquema existente.', 1;

    IF NOT EXISTS (SELECT 1 FROM sys.default_constraints dc
        JOIN sys.columns c ON c.object_id = dc.parent_object_id AND c.column_id = dc.parent_column_id
        WHERE dc.parent_object_id = OBJECT_ID(N'dbo.Estudiantes') AND c.name = N'Id')
        ALTER TABLE dbo.Estudiantes ADD CONSTRAINT DF_RE_Estudiantes_Id DEFAULT NEWID() FOR Id;

    IF OBJECT_ID(N'dbo.FK_Carreras_Areas', N'F') IS NULL
        ALTER TABLE dbo.Carreras WITH CHECK ADD CONSTRAINT FK_Carreras_Areas FOREIGN KEY (IdArea) REFERENCES dbo.AreasConocimiento(IdArea);
    ALTER TABLE dbo.Carreras WITH CHECK CHECK CONSTRAINT FK_Carreras_Areas;

    IF OBJECT_ID(N'dbo.FK_Municipios_Departamentos', N'F') IS NULL
        ALTER TABLE dbo.Municipios WITH CHECK ADD CONSTRAINT FK_Municipios_Departamentos FOREIGN KEY (IdDepartamento) REFERENCES dbo.Departamentos(IdDepartamento);
    ALTER TABLE dbo.Municipios WITH CHECK CHECK CONSTRAINT FK_Municipios_Departamentos;

    IF OBJECT_ID(N'dbo.CK_Estudiantes_Sexo', N'C') IS NULL
        ALTER TABLE dbo.Estudiantes WITH CHECK ADD CONSTRAINT CK_Estudiantes_Sexo CHECK (Sexo IN ('M','F'));
    ALTER TABLE dbo.Estudiantes WITH CHECK CHECK CONSTRAINT CK_Estudiantes_Sexo;

    IF OBJECT_ID(N'dbo.CK_Estudiantes_Promedio', N'C') IS NULL
        ALTER TABLE dbo.Estudiantes WITH CHECK ADD CONSTRAINT CK_Estudiantes_Promedio CHECK (Promedio BETWEEN 0 AND 100);
    ALTER TABLE dbo.Estudiantes WITH CHECK CHECK CONSTRAINT CK_Estudiantes_Promedio;

    IF OBJECT_ID(N'dbo.FK_Estudiantes_Carreras', N'F') IS NULL
        ALTER TABLE dbo.Estudiantes WITH CHECK ADD CONSTRAINT FK_Estudiantes_Carreras FOREIGN KEY (IdCarrera) REFERENCES dbo.Carreras(IdCarrera);
    ALTER TABLE dbo.Estudiantes WITH CHECK CHECK CONSTRAINT FK_Estudiantes_Carreras;

    IF OBJECT_ID(N'dbo.FK_Estudiantes_Municipios', N'F') IS NULL
        ALTER TABLE dbo.Estudiantes WITH CHECK ADD CONSTRAINT FK_Estudiantes_Municipios FOREIGN KEY (IdMunicipio) REFERENCES dbo.Municipios(IdMunicipio);
    ALTER TABLE dbo.Estudiantes WITH CHECK CHECK CONSTRAINT FK_Estudiantes_Municipios;

    IF OBJECT_ID(N'dbo.FK_Tutores_Estudiantes', N'F') IS NULL
        ALTER TABLE dbo.Tutores WITH CHECK ADD CONSTRAINT FK_Tutores_Estudiantes FOREIGN KEY (IdEstudiante) REFERENCES dbo.Estudiantes(Id);
    ALTER TABLE dbo.Tutores WITH CHECK CHECK CONSTRAINT FK_Tutores_Estudiantes;

    IF OBJECT_ID(N'dbo.FK_Usuarios_Estudiantes', N'F') IS NULL
        ALTER TABLE dbo.Usuarios WITH CHECK ADD CONSTRAINT FK_Usuarios_Estudiantes FOREIGN KEY (IdEstudiante) REFERENCES dbo.Estudiantes(Id);
    ALTER TABLE dbo.Usuarios WITH CHECK CHECK CONSTRAINT FK_Usuarios_Estudiantes;

    IF OBJECT_ID(N'dbo.FK_Usuarios_Roles', N'F') IS NULL
        ALTER TABLE dbo.Usuarios WITH CHECK ADD CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (IdRol) REFERENCES dbo.Roles(IdRol);
    ALTER TABLE dbo.Usuarios WITH CHECK CHECK CONSTRAINT FK_Usuarios_Roles;

    IF OBJECT_ID(N'dbo.FK_Prereq_Asignatura', N'F') IS NULL
        ALTER TABLE dbo.Prerrequisitos WITH CHECK ADD CONSTRAINT FK_Prereq_Asignatura FOREIGN KEY (IdAsignatura) REFERENCES dbo.Asignaturas(IdAsignatura);
    ALTER TABLE dbo.Prerrequisitos WITH CHECK CHECK CONSTRAINT FK_Prereq_Asignatura;

    IF OBJECT_ID(N'dbo.FK_Prereq_Requisito', N'F') IS NULL
        ALTER TABLE dbo.Prerrequisitos WITH CHECK ADD CONSTRAINT FK_Prereq_Requisito FOREIGN KEY (IdAsignaturaPrerrequisito) REFERENCES dbo.Asignaturas(IdAsignatura);
    ALTER TABLE dbo.Prerrequisitos WITH CHECK CHECK CONSTRAINT FK_Prereq_Requisito;

    IF OBJECT_ID(N'dbo.FK_EA_Estudiante', N'F') IS NULL
        ALTER TABLE dbo.EstudianteAsignaturas WITH CHECK ADD CONSTRAINT FK_EA_Estudiante FOREIGN KEY (IdEstudiante) REFERENCES dbo.Estudiantes(Id);
    ALTER TABLE dbo.EstudianteAsignaturas WITH CHECK CHECK CONSTRAINT FK_EA_Estudiante;

    IF OBJECT_ID(N'dbo.FK_EA_Asignatura', N'F') IS NULL
        ALTER TABLE dbo.EstudianteAsignaturas WITH CHECK ADD CONSTRAINT FK_EA_Asignatura FOREIGN KEY (IdAsignatura) REFERENCES dbo.Asignaturas(IdAsignatura);
    ALTER TABLE dbo.EstudianteAsignaturas WITH CHECK CHECK CONSTRAINT FK_EA_Asignatura;

    -- Reglas de contenido equivalentes a la validación del formulario.

    IF OBJECT_ID(N'dbo.CK_RE_Estudiantes_Carnet_Contenido', N'C') IS NULL
        ALTER TABLE dbo.Estudiantes WITH CHECK ADD CONSTRAINT CK_RE_Estudiantes_Carnet_Contenido CHECK (LEN(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(Carnet, NCHAR(9), N''), NCHAR(10), N''), NCHAR(13), N''), NCHAR(160), N'')))) > 0);
    ALTER TABLE dbo.Estudiantes WITH CHECK CHECK CONSTRAINT CK_RE_Estudiantes_Carnet_Contenido;

    IF OBJECT_ID(N'dbo.CK_RE_Estudiantes_Nombres_Contenido', N'C') IS NULL
        ALTER TABLE dbo.Estudiantes WITH CHECK ADD CONSTRAINT CK_RE_Estudiantes_Nombres_Contenido CHECK (LEN(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(Nombres, NCHAR(9), N''), NCHAR(10), N''), NCHAR(13), N''), NCHAR(160), N'')))) > 0);
    ALTER TABLE dbo.Estudiantes WITH CHECK CHECK CONSTRAINT CK_RE_Estudiantes_Nombres_Contenido;

    IF OBJECT_ID(N'dbo.CK_RE_Estudiantes_Apellidos_Contenido', N'C') IS NULL
        ALTER TABLE dbo.Estudiantes WITH CHECK ADD CONSTRAINT CK_RE_Estudiantes_Apellidos_Contenido CHECK (LEN(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(Apellidos, NCHAR(9), N''), NCHAR(10), N''), NCHAR(13), N''), NCHAR(160), N'')))) > 0);
    ALTER TABLE dbo.Estudiantes WITH CHECK CHECK CONSTRAINT CK_RE_Estudiantes_Apellidos_Contenido;

    IF OBJECT_ID(N'dbo.CK_RE_Estudiantes_Nacionalidad_Contenido', N'C') IS NULL
        ALTER TABLE dbo.Estudiantes WITH CHECK ADD CONSTRAINT CK_RE_Estudiantes_Nacionalidad_Contenido CHECK (LEN(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(Nacionalidad, NCHAR(9), N''), NCHAR(10), N''), NCHAR(13), N''), NCHAR(160), N'')))) > 0);
    ALTER TABLE dbo.Estudiantes WITH CHECK CHECK CONSTRAINT CK_RE_Estudiantes_Nacionalidad_Contenido;

    IF OBJECT_ID(N'dbo.CK_RE_Estudiantes_NivelAcademico_Contenido', N'C') IS NULL
        ALTER TABLE dbo.Estudiantes WITH CHECK ADD CONSTRAINT CK_RE_Estudiantes_NivelAcademico_Contenido CHECK (LEN(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(NivelAcademico, NCHAR(9), N''), NCHAR(10), N''), NCHAR(13), N''), NCHAR(160), N'')))) > 0);
    ALTER TABLE dbo.Estudiantes WITH CHECK CHECK CONSTRAINT CK_RE_Estudiantes_NivelAcademico_Contenido;

    IF OBJECT_ID(N'dbo.CK_RE_Estudiantes_Correo_Contenido', N'C') IS NULL
        ALTER TABLE dbo.Estudiantes WITH CHECK ADD CONSTRAINT CK_RE_Estudiantes_Correo_Contenido CHECK (LEN(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(Correo, NCHAR(9), N''), NCHAR(10), N''), NCHAR(13), N''), NCHAR(160), N'')))) > 0);
    ALTER TABLE dbo.Estudiantes WITH CHECK CHECK CONSTRAINT CK_RE_Estudiantes_Correo_Contenido;

    IF OBJECT_ID(N'dbo.CK_RE_AreasConocimiento_Nombre_Contenido', N'C') IS NULL
        ALTER TABLE dbo.AreasConocimiento WITH CHECK ADD CONSTRAINT CK_RE_AreasConocimiento_Nombre_Contenido CHECK (LEN(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(Nombre, NCHAR(9), N''), NCHAR(10), N''), NCHAR(13), N''), NCHAR(160), N'')))) > 0);
    ALTER TABLE dbo.AreasConocimiento WITH CHECK CHECK CONSTRAINT CK_RE_AreasConocimiento_Nombre_Contenido;

    IF OBJECT_ID(N'dbo.CK_RE_Carreras_Nombre_Contenido', N'C') IS NULL
        ALTER TABLE dbo.Carreras WITH CHECK ADD CONSTRAINT CK_RE_Carreras_Nombre_Contenido CHECK (LEN(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(Nombre, NCHAR(9), N''), NCHAR(10), N''), NCHAR(13), N''), NCHAR(160), N'')))) > 0);
    ALTER TABLE dbo.Carreras WITH CHECK CHECK CONSTRAINT CK_RE_Carreras_Nombre_Contenido;

    IF OBJECT_ID(N'dbo.CK_RE_Departamentos_Nombre_Contenido', N'C') IS NULL
        ALTER TABLE dbo.Departamentos WITH CHECK ADD CONSTRAINT CK_RE_Departamentos_Nombre_Contenido CHECK (LEN(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(Nombre, NCHAR(9), N''), NCHAR(10), N''), NCHAR(13), N''), NCHAR(160), N'')))) > 0);
    ALTER TABLE dbo.Departamentos WITH CHECK CHECK CONSTRAINT CK_RE_Departamentos_Nombre_Contenido;

    IF OBJECT_ID(N'dbo.CK_RE_Municipios_Nombre_Contenido', N'C') IS NULL
        ALTER TABLE dbo.Municipios WITH CHECK ADD CONSTRAINT CK_RE_Municipios_Nombre_Contenido CHECK (LEN(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(Nombre, NCHAR(9), N''), NCHAR(10), N''), NCHAR(13), N''), NCHAR(160), N'')))) > 0);
    ALTER TABLE dbo.Municipios WITH CHECK CHECK CONSTRAINT CK_RE_Municipios_Nombre_Contenido;

    IF OBJECT_ID(N'dbo.CK_RE_Roles_Nombre_Contenido', N'C') IS NULL
        ALTER TABLE dbo.Roles WITH CHECK ADD CONSTRAINT CK_RE_Roles_Nombre_Contenido CHECK (LEN(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(Nombre, NCHAR(9), N''), NCHAR(10), N''), NCHAR(13), N''), NCHAR(160), N'')))) > 0);
    ALTER TABLE dbo.Roles WITH CHECK CHECK CONSTRAINT CK_RE_Roles_Nombre_Contenido;

    IF OBJECT_ID(N'dbo.CK_RE_Usuarios_NombreUsuario_Contenido', N'C') IS NULL
        ALTER TABLE dbo.Usuarios WITH CHECK ADD CONSTRAINT CK_RE_Usuarios_NombreUsuario_Contenido CHECK (LEN(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(NombreUsuario, NCHAR(9), N''), NCHAR(10), N''), NCHAR(13), N''), NCHAR(160), N'')))) > 0);
    ALTER TABLE dbo.Usuarios WITH CHECK CHECK CONSTRAINT CK_RE_Usuarios_NombreUsuario_Contenido;

    IF OBJECT_ID(N'dbo.CK_RE_Tutores_NombreCompleto_Contenido', N'C') IS NULL
        ALTER TABLE dbo.Tutores WITH CHECK ADD CONSTRAINT CK_RE_Tutores_NombreCompleto_Contenido CHECK (LEN(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(NombreCompleto, NCHAR(9), N''), NCHAR(10), N''), NCHAR(13), N''), NCHAR(160), N'')))) > 0);
    ALTER TABLE dbo.Tutores WITH CHECK CHECK CONSTRAINT CK_RE_Tutores_NombreCompleto_Contenido;

    IF OBJECT_ID(N'dbo.CK_RE_Tutores_Parentesco_Contenido', N'C') IS NULL
        ALTER TABLE dbo.Tutores WITH CHECK ADD CONSTRAINT CK_RE_Tutores_Parentesco_Contenido CHECK (LEN(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(Parentesco, NCHAR(9), N''), NCHAR(10), N''), NCHAR(13), N''), NCHAR(160), N'')))) > 0);
    ALTER TABLE dbo.Tutores WITH CHECK CHECK CONSTRAINT CK_RE_Tutores_Parentesco_Contenido;

    IF OBJECT_ID(N'dbo.CK_RE_Asignaturas_Codigo_Contenido', N'C') IS NULL
        ALTER TABLE dbo.Asignaturas WITH CHECK ADD CONSTRAINT CK_RE_Asignaturas_Codigo_Contenido CHECK (LEN(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(Codigo, NCHAR(9), N''), NCHAR(10), N''), NCHAR(13), N''), NCHAR(160), N'')))) > 0);
    ALTER TABLE dbo.Asignaturas WITH CHECK CHECK CONSTRAINT CK_RE_Asignaturas_Codigo_Contenido;

    IF OBJECT_ID(N'dbo.CK_RE_Asignaturas_Nombre_Contenido', N'C') IS NULL
        ALTER TABLE dbo.Asignaturas WITH CHECK ADD CONSTRAINT CK_RE_Asignaturas_Nombre_Contenido CHECK (LEN(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(Nombre, NCHAR(9), N''), NCHAR(10), N''), NCHAR(13), N''), NCHAR(160), N'')))) > 0);
    ALTER TABLE dbo.Asignaturas WITH CHECK CHECK CONSTRAINT CK_RE_Asignaturas_Nombre_Contenido;

    IF OBJECT_ID(N'dbo.CK_RE_Estudiantes_EdadMinima', N'C') IS NULL
        ALTER TABLE dbo.Estudiantes WITH CHECK ADD CONSTRAINT CK_RE_Estudiantes_EdadMinima CHECK (FechaNacimiento <= DATEADD(YEAR, -15, CONVERT(date, GETDATE())));
    ALTER TABLE dbo.Estudiantes WITH CHECK CHECK CONSTRAINT CK_RE_Estudiantes_EdadMinima;

    IF OBJECT_ID(N'dbo.CK_RE_Estudiantes_Correo_FormatoBasico', N'C') IS NULL
        ALTER TABLE dbo.Estudiantes WITH CHECK ADD CONSTRAINT CK_RE_Estudiantes_Correo_FormatoBasico CHECK (Correo LIKE N'%_@_%' AND LEN(Correo) - LEN(REPLACE(Correo, N'@', N'')) = 1 AND CHARINDEX(N' ', Correo) = 0 AND CHARINDEX(NCHAR(9), Correo) = 0 AND CHARINDEX(NCHAR(10), Correo) = 0 AND CHARINDEX(NCHAR(13), Correo) = 0);
    ALTER TABLE dbo.Estudiantes WITH CHECK CHECK CONSTRAINT CK_RE_Estudiantes_Correo_FormatoBasico;

    IF OBJECT_ID(N'dbo.CK_RE_Estudiantes_Discapacidad', N'C') IS NULL
        ALTER TABLE dbo.Estudiantes WITH CHECK ADD CONSTRAINT CK_RE_Estudiantes_Discapacidad CHECK (TieneDiscapacidadFisica = 0 OR (DescripcionDiscapacidad IS NOT NULL AND LEN(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(DescripcionDiscapacidad, NCHAR(9), N''), NCHAR(10), N''), NCHAR(13), N''), NCHAR(160), N'')))) > 0));
    ALTER TABLE dbo.Estudiantes WITH CHECK CHECK CONSTRAINT CK_RE_Estudiantes_Discapacidad;

    IF OBJECT_ID(N'dbo.CK_RE_Usuarios_HashSalt', N'C') IS NULL
        ALTER TABLE dbo.Usuarios WITH CHECK ADD CONSTRAINT CK_RE_Usuarios_HashSalt CHECK (DATALENGTH(ClaveHash) = 64 AND DATALENGTH(ClaveSalt) = 32);
    ALTER TABLE dbo.Usuarios WITH CHECK CHECK CONSTRAINT CK_RE_Usuarios_HashSalt;

    IF OBJECT_ID(N'dbo.CK_RE_Asignaturas_Creditos', N'C') IS NULL
        ALTER TABLE dbo.Asignaturas WITH CHECK ADD CONSTRAINT CK_RE_Asignaturas_Creditos CHECK (Creditos > 0);
    ALTER TABLE dbo.Asignaturas WITH CHECK CHECK CONSTRAINT CK_RE_Asignaturas_Creditos;

    IF OBJECT_ID(N'dbo.CK_RE_Prerrequisitos_NoAutorreferencia', N'C') IS NULL
        ALTER TABLE dbo.Prerrequisitos WITH CHECK ADD CONSTRAINT CK_RE_Prerrequisitos_NoAutorreferencia CHECK (IdAsignatura <> IdAsignaturaPrerrequisito);
    ALTER TABLE dbo.Prerrequisitos WITH CHECK CHECK CONSTRAINT CK_RE_Prerrequisitos_NoAutorreferencia;

    IF OBJECT_ID(N'dbo.CK_RE_EstudianteAsignaturas_Nota', N'C') IS NULL
        ALTER TABLE dbo.EstudianteAsignaturas WITH CHECK ADD CONSTRAINT CK_RE_EstudianteAsignaturas_Nota CHECK (Nota BETWEEN 0 AND 100);
    ALTER TABLE dbo.EstudianteAsignaturas WITH CHECK CHECK CONSTRAINT CK_RE_EstudianteAsignaturas_Nota;

    IF OBJECT_ID(N'dbo.CK_RE_Tutores_Correo', N'C') IS NULL
        ALTER TABLE dbo.Tutores WITH CHECK ADD CONSTRAINT CK_RE_Tutores_Correo CHECK (Correo IS NULL OR (Correo LIKE N'%_@_%' AND LEN(Correo) - LEN(REPLACE(Correo, N'@', N'')) = 1 AND CHARINDEX(N' ', Correo) = 0 AND CHARINDEX(NCHAR(9), Correo) = 0 AND CHARINDEX(NCHAR(10), Correo) = 0 AND CHARINDEX(NCHAR(13), Correo) = 0));
    ALTER TABLE dbo.Tutores WITH CHECK CHECK CONSTRAINT CK_RE_Tutores_Correo;

    IF NOT EXISTS (
        SELECT i.index_id FROM sys.indexes i
        JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.key_ordinal > 0
        JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
        WHERE i.object_id = OBJECT_ID(N'dbo.Estudiantes') AND i.is_unique = 1 AND i.is_disabled = 0 AND i.has_filter = 0
        GROUP BY i.index_id
        HAVING COUNT(*) = 1 AND SUM(CASE WHEN c.name IN (N'Carnet') THEN 1 ELSE 0 END) = 1
    )
        CREATE UNIQUE INDEX UX_RE_Estudiantes_Carnet ON dbo.Estudiantes (Carnet);

    IF NOT EXISTS (
        SELECT i.index_id FROM sys.indexes i
        JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.key_ordinal > 0
        JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
        WHERE i.object_id = OBJECT_ID(N'dbo.Estudiantes') AND i.is_unique = 1 AND i.is_disabled = 0 AND i.has_filter = 0
        GROUP BY i.index_id
        HAVING COUNT(*) = 1 AND SUM(CASE WHEN c.name IN (N'Correo') THEN 1 ELSE 0 END) = 1
    )
        CREATE UNIQUE INDEX UX_RE_Estudiantes_Correo ON dbo.Estudiantes (Correo);

    IF NOT EXISTS (
        SELECT i.index_id FROM sys.indexes i
        JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.key_ordinal > 0
        JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
        WHERE i.object_id = OBJECT_ID(N'dbo.AreasConocimiento') AND i.is_unique = 1 AND i.is_disabled = 0 AND i.has_filter = 0
        GROUP BY i.index_id
        HAVING COUNT(*) = 1 AND SUM(CASE WHEN c.name IN (N'Nombre') THEN 1 ELSE 0 END) = 1
    )
        CREATE UNIQUE INDEX UX_RE_Areas_Nombre ON dbo.AreasConocimiento (Nombre);

    IF NOT EXISTS (
        SELECT i.index_id FROM sys.indexes i
        JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.key_ordinal > 0
        JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
        WHERE i.object_id = OBJECT_ID(N'dbo.Departamentos') AND i.is_unique = 1 AND i.is_disabled = 0 AND i.has_filter = 0
        GROUP BY i.index_id
        HAVING COUNT(*) = 1 AND SUM(CASE WHEN c.name IN (N'Nombre') THEN 1 ELSE 0 END) = 1
    )
        CREATE UNIQUE INDEX UX_RE_Departamentos_Nombre ON dbo.Departamentos (Nombre);

    IF NOT EXISTS (
        SELECT i.index_id FROM sys.indexes i
        JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.key_ordinal > 0
        JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
        WHERE i.object_id = OBJECT_ID(N'dbo.Roles') AND i.is_unique = 1 AND i.is_disabled = 0 AND i.has_filter = 0
        GROUP BY i.index_id
        HAVING COUNT(*) = 1 AND SUM(CASE WHEN c.name IN (N'Nombre') THEN 1 ELSE 0 END) = 1
    )
        CREATE UNIQUE INDEX UX_RE_Roles_Nombre ON dbo.Roles (Nombre);

    IF NOT EXISTS (
        SELECT i.index_id FROM sys.indexes i
        JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.key_ordinal > 0
        JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
        WHERE i.object_id = OBJECT_ID(N'dbo.Usuarios') AND i.is_unique = 1 AND i.is_disabled = 0 AND i.has_filter = 0
        GROUP BY i.index_id
        HAVING COUNT(*) = 1 AND SUM(CASE WHEN c.name IN (N'NombreUsuario') THEN 1 ELSE 0 END) = 1
    )
        CREATE UNIQUE INDEX UX_RE_Usuarios_Nombre ON dbo.Usuarios (NombreUsuario);

    IF NOT EXISTS (
        SELECT i.index_id FROM sys.indexes i
        JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.key_ordinal > 0
        JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
        WHERE i.object_id = OBJECT_ID(N'dbo.Tutores') AND i.is_unique = 1 AND i.is_disabled = 0 AND i.has_filter = 0
        GROUP BY i.index_id
        HAVING COUNT(*) = 1 AND SUM(CASE WHEN c.name IN (N'IdEstudiante') THEN 1 ELSE 0 END) = 1
    )
        CREATE UNIQUE INDEX UX_RE_Tutores_Estudiante ON dbo.Tutores (IdEstudiante);

    IF NOT EXISTS (
        SELECT i.index_id FROM sys.indexes i
        JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.key_ordinal > 0
        JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
        WHERE i.object_id = OBJECT_ID(N'dbo.Asignaturas') AND i.is_unique = 1 AND i.is_disabled = 0 AND i.has_filter = 0
        GROUP BY i.index_id
        HAVING COUNT(*) = 1 AND SUM(CASE WHEN c.name IN (N'Codigo') THEN 1 ELSE 0 END) = 1
    )
        CREATE UNIQUE INDEX UX_RE_Asignaturas_Codigo ON dbo.Asignaturas (Codigo);

    IF NOT EXISTS (
        SELECT i.index_id FROM sys.indexes i
        JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.key_ordinal > 0
        JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
        WHERE i.object_id = OBJECT_ID(N'dbo.Carreras') AND i.is_unique = 1 AND i.is_disabled = 0 AND i.has_filter = 0
        GROUP BY i.index_id
        HAVING COUNT(*) = 2 AND SUM(CASE WHEN c.name IN (N'IdArea', N'Nombre') THEN 1 ELSE 0 END) = 2
    )
        CREATE UNIQUE INDEX UX_RE_Carreras_AreaNombre ON dbo.Carreras (IdArea, Nombre);

    IF NOT EXISTS (
        SELECT i.index_id FROM sys.indexes i
        JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.key_ordinal > 0
        JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
        WHERE i.object_id = OBJECT_ID(N'dbo.Municipios') AND i.is_unique = 1 AND i.is_disabled = 0 AND i.has_filter = 0
        GROUP BY i.index_id
        HAVING COUNT(*) = 2 AND SUM(CASE WHEN c.name IN (N'IdDepartamento', N'Nombre') THEN 1 ELSE 0 END) = 2
    )
        CREATE UNIQUE INDEX UX_RE_Municipios_DepartamentoNombre ON dbo.Municipios (IdDepartamento, Nombre);

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Estudiantes') AND name = N'IX_RE_Estudiantes_ActivosApellido')
        CREATE INDEX IX_RE_Estudiantes_ActivosApellido ON dbo.Estudiantes (Apellidos, Nombres)
            INCLUDE (Carnet, IdCarrera, IdMunicipio) WHERE Activo = 1;

    -- Catálogos de práctica tomados de la guía. Se enlazan por nombre, no por IDs supuestos.
    INSERT INTO dbo.AreasConocimiento (Nombre)
    SELECT v.Nombre FROM (VALUES (N'DACTIC'), (N'DACA'), (N'DACIP'), (N'Otra')) v(Nombre)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.AreasConocimiento a WHERE a.Nombre = v.Nombre);
    INSERT INTO dbo.Roles (Nombre)
    SELECT v.Nombre FROM (VALUES (N'Administrador'), (N'Registro'), (N'Consulta')) v(Nombre)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Roles r WHERE r.Nombre = v.Nombre);
    INSERT INTO dbo.Departamentos (Nombre)
    SELECT v.Nombre FROM (VALUES (N'Managua'), (N'Masaya'), (N'Granada')) v(Nombre)
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Departamentos d WHERE d.Nombre = v.Nombre);
    INSERT INTO dbo.Municipios (Nombre, IdDepartamento)
    SELECT v.Municipio, d.IdDepartamento
    FROM (VALUES (N'Managua', N'Managua'), (N'Ciudad Sandino', N'Managua'),
        (N'Masaya', N'Masaya'), (N'Granada', N'Granada')) v(Municipio, Departamento)
    JOIN dbo.Departamentos d ON d.Nombre = v.Departamento
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Municipios m
        WHERE m.Nombre = v.Municipio AND m.IdDepartamento = d.IdDepartamento);
    INSERT INTO dbo.Carreras (Nombre, IdArea)
    SELECT v.Carrera, a.IdArea FROM (VALUES
        (N'Ingeniería de Sistemas', N'DACTIC'), (N'Ingeniería en Computación', N'DACTIC')) v(Carrera, Area)
    JOIN dbo.AreasConocimiento a ON a.Nombre = v.Area
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Carreras c WHERE c.Nombre = v.Carrera AND c.IdArea = a.IdArea);

    -- Cada EXEC crea el procedimiento en su propio lote, dentro de la transacción.

    EXEC(N'CREATE OR ALTER PROCEDURE dbo.usp_ListarEstudiantesActivos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.Id, e.Carnet, e.Cedula, e.Nombres, e.Apellidos,
        e.Sexo, e.FechaNacimiento, e.Nacionalidad, e.NivelAcademico, e.TieneTutor,
        e.IdCarrera, c.Nombre AS Carrera, a.Nombre AS Area,
        e.IdMunicipio, m.Nombre AS Municipio, d.Nombre AS Departamento,
        e.Etnia, e.Correo, e.Promedio, e.TieneDiscapacidadFisica,
        e.DescripcionDiscapacidad, e.EsInterno, e.Activo, e.FechaRegistro
    FROM dbo.Estudiantes e
    INNER JOIN dbo.Carreras c ON c.IdCarrera = e.IdCarrera
    INNER JOIN dbo.AreasConocimiento a ON a.IdArea = c.IdArea
    INNER JOIN dbo.Municipios m ON m.IdMunicipio = e.IdMunicipio
    INNER JOIN dbo.Departamentos d ON d.IdDepartamento = m.IdDepartamento
    WHERE e.Activo = 1
    ORDER BY e.Apellidos, e.Nombres;
END;');

    EXEC(N'CREATE OR ALTER PROCEDURE dbo.sp_Estudiantes_ListarActivos
AS
BEGIN
    SET NOCOUNT ON;
    -- Nombre conservado para los ejercicios anteriores. Mismo resultado con alias Area.
    EXEC dbo.usp_ListarEstudiantesActivos;
END;');

    EXEC(N'CREATE OR ALTER PROCEDURE dbo.usp_ListarAsignaturasAprobadas
    @IdEstudiante uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    SELECT a.Codigo, a.Nombre, ea.Nota
    FROM dbo.EstudianteAsignaturas ea
    INNER JOIN dbo.Asignaturas a ON a.IdAsignatura = ea.IdAsignatura
    WHERE ea.IdEstudiante = @IdEstudiante AND ea.Aprobada = 1
    ORDER BY a.Nombre;
END;');

    EXEC(N'CREATE OR ALTER PROCEDURE dbo.usp_ListarCursosDisponibles
    @IdEstudiante uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    SELECT a.IdAsignatura, a.Codigo, a.Nombre, a.Creditos
    FROM dbo.Asignaturas a
    WHERE a.Activa = 1
      AND NOT EXISTS (SELECT 1 FROM dbo.EstudianteAsignaturas ea
          WHERE ea.IdEstudiante = @IdEstudiante AND ea.IdAsignatura = a.IdAsignatura AND ea.Aprobada = 1)
      AND NOT EXISTS (
          SELECT 1 FROM dbo.Prerrequisitos p WHERE p.IdAsignatura = a.IdAsignatura
          AND NOT EXISTS (SELECT 1 FROM dbo.EstudianteAsignaturas ea
              WHERE ea.IdEstudiante = @IdEstudiante
                AND ea.IdAsignatura = p.IdAsignaturaPrerrequisito AND ea.Aprobada = 1))
    ORDER BY a.Nombre;
END;');

    COMMIT TRANSACTION;
    PRINT N'RegistroEstudiantesDB preparada. Tablas, catálogos, reglas y procedimientos listos.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    PRINT N'No se completó la preparación. Se revirtieron los cambios en la base. Revise el error siguiente.';
    THROW;
END CATCH;
GO

-- Comprobación de catálogos y nombres utilizados por el programa.
SELECT N'Áreas' AS Catalogo, COUNT(*) AS Cantidad FROM dbo.AreasConocimiento
UNION ALL SELECT N'Carreras', COUNT(*) FROM dbo.Carreras
UNION ALL SELECT N'Departamentos', COUNT(*) FROM dbo.Departamentos
UNION ALL SELECT N'Municipios', COUNT(*) FROM dbo.Municipios
UNION ALL SELECT N'Roles', COUNT(*) FROM dbo.Roles;
EXEC dbo.usp_ListarEstudiantesActivos;
GO
