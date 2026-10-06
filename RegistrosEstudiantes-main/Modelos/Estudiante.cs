using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RegistroEstudiantes.Modelos
{


    public enum Sexo
    {
        M,
        F
    }

    public enum AreaConocimiento
    {
        DACTIC,
        DACA,
        DACIP,
        Otra
    }

    public class Estudiante
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        // Atributos privados 

        private string carnet = string.Empty;
        private string cedula = string.Empty;
        private string nombres = string.Empty;
        private string apellidos = string.Empty;
        private Sexo sexo;
        private DateTime fechaNacimiento;
        private string nacionalidad = string.Empty;
        private string nivelAcademico = string.Empty;
        private bool tieneTutor;
        private AreaConocimiento areaConocimiento;
        private string carrera = string.Empty;
        private string departamento = string.Empty;
        private string municipio = string.Empty;
        private string etnia = string.Empty;
        private string correo = string.Empty;
        private decimal promedio;
        private bool tieneDiscapacidadFisica;
        private string descripcionDiscapacidad = string.Empty;

        private bool esInterno;
        private bool activo = true;

        public bool EsInterno
        {
            get { return esInterno; }
            set { esInterno = value; }
        }

        public bool Activo
        {
            get { return activo; }
            set { activo = value; }
        }

        public int IdCarrera { get; set; }
        public int IdMunicipio { get; set; }


        // Propiedades públicas 

       

        public string Carnet
        {
            get { return carnet; }
            set
            {
                carnet = value.Trim().ToUpperInvariant();
            }
        }

        public string Cedula
        {
            get { return cedula; }
            set
            {
                cedula = value.Trim();
            }
        }

        public string Nombres
        {
            get { return nombres; }
            set
            {
                nombres = value.Trim();
            }
        }
        public string Apellidos
        {
            get { return apellidos; }
            set
            {
                apellidos = value.Trim();
            }
        }

        public string NombreCompleto
        {
            get
            {
                return $"{nombres} {apellidos}".Trim();
            }
        }

        public Sexo Sexo
        {
            get { return sexo; }
            set { sexo = value; }
        }

        public DateTime FechaNacimiento
        {
            get { return fechaNacimiento; }
            set
            {
                if (value <= DateTime.Today)
                {
                    fechaNacimiento = value;
                }
                else
                {
                    throw new ArgumentException(
                        "La fecha de nacimiento no puede ser una fecha futura.");
                }
            }
        }

        public string Nacionalidad
        {
            get { return nacionalidad; }
            set
            {
                nacionalidad = value.Trim();
            }
        }

        public string NivelAcademico
        {
            get { return nivelAcademico; }
            set
            {
                nivelAcademico = value.Trim();
            }
        }

        public bool TieneTutor
        {
            get { return tieneTutor; }
            set { tieneTutor = value; }
        }
        
 
    public AreaConocimiento AreaConocimiento
        {
            get { return areaConocimiento; }
            set { areaConocimiento = value; }
        }

        public string Carrera
        {
            get { return carrera; }
            set
            {
                carrera = value.Trim();
            }
        }

        public string Departamento
        {
            get { return departamento; }
            set
            {
                departamento = value.Trim();
            }
        }

        public string Municipio
        {
            get { return municipio; }
            set
            {
                municipio = value.Trim();
            }
        }

        public string Etnia
        {
            get { return etnia; }
            set
            {
                etnia = value.Trim();
            }
        }

        public string Correo
        {
            get { return correo; }
            set
            {
                correo = value.Trim().ToLowerInvariant();
            }
        }

        public decimal Promedio
        {
            get { return promedio; }
            set
            {
                if (value >= 0 && value <= 100)
                {
                    promedio = value;
                }
                else
                {
                    throw new ArgumentException(
                        "El promedio debe estar entre 0 y 100.");
                }
            }
        }

        public bool TieneDiscapacidadFisica
        {
            get { return tieneDiscapacidadFisica; }
            set
            {
                tieneDiscapacidadFisica = value;
            }
        }

        public string DescripcionDiscapacidad
        {
            get { return descripcionDiscapacidad; }
            set
            {
                descripcionDiscapacidad = value.Trim();
            }
        }


        // Propiedad calculada 
        public int Edad
        {
            get
            {
                DateTime hoy = DateTime.Today;

                int edad = hoy.Year - fechaNacimiento.Year;

                if (fechaNacimiento.Date > hoy.AddYears(-edad))
                {
                    edad--;
                }

                return edad;
            }
        }
    }
}