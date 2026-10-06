using RegistroEstudiantes.Modelos;
using System.Net.Mail;

namespace RegistroEstudiantes.ServiciosTemporales
{
    public static class ValidadorEstudiante
    {
        public static List<string> Validar(Estudiante estudiante)
        {
            List<string> errores = new();

            // Datos personales
            if (string.IsNullOrWhiteSpace(estudiante.Carnet))
                errores.Add("El carnet es obligatorio.");

            if (string.IsNullOrWhiteSpace(estudiante.Nombres))
                errores.Add("Los nombres son obligatorios.");

            if (string.IsNullOrWhiteSpace(estudiante.Apellidos))
                errores.Add("Los apellidos son obligatorios.");

            // Fecha y edad
            if (estudiante.FechaNacimiento.Date >= DateTime.Today)
            {
                errores.Add(
                    "La fecha de nacimiento debe ser anterior a la fecha actual.");
            }
            else if (estudiante.Edad < 15)
            {
                errores.Add(
                    "El estudiante debe tener al menos 15 años.");
            }

            // Información académica
            if (string.IsNullOrWhiteSpace(estudiante.Nacionalidad))
                errores.Add("La nacionalidad es obligatoria.");

            if (string.IsNullOrWhiteSpace(estudiante.NivelAcademico))
                errores.Add("El nivel académico es obligatorio.");

            // Llaves foráneas
            if (estudiante.IdCarrera <= 0)
                errores.Add("Debe seleccionar una carrera válida.");

            if (estudiante.IdMunicipio <= 0)
                errores.Add("Debe seleccionar un municipio válido.");

            // Correo
            if (string.IsNullOrWhiteSpace(estudiante.Correo))
            {
                errores.Add("El correo es obligatorio.");
            }
            else if (!CorreoValido(estudiante.Correo))
            {
                errores.Add("El correo no tiene un formato válido.");
            }

            // Promedio
            if (estudiante.Promedio < 0 ||
                estudiante.Promedio > 100)
            {
                errores.Add(
                    "El promedio debe estar entre 0 y 100.");
            }

            // Discapacidad
            if (estudiante.TieneDiscapacidadFisica &&
                string.IsNullOrWhiteSpace(
                    estudiante.DescripcionDiscapacidad))
            {
                errores.Add(
                    "Debe describir la discapacidad física indicada.");
            }

            return errores;
        }

        private static bool CorreoValido(string correo)
        {
            try
            {
                MailAddress direccion = new(correo);

                return direccion.Address.Equals(
                    correo,
                    StringComparison.OrdinalIgnoreCase);
            }
            catch
            {
                return false;
            }
        }
    }
}