using RegistroEstudiantes.Modelos;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace RegistroEstudiantes.Formularios
{
    public partial class FrmDetalleEstudiante : Form
    {
        private readonly Estudiante estudiante;
        public FrmDetalleEstudiante(Modelos.Estudiante estudiante)
        {
            InitializeComponent();
            this.estudiante = estudiante
          ?? throw new ArgumentNullException(nameof(estudiante));
        }

        private void FrmDetalleEstudiante_Load(object sender, EventArgs e)
        {
            lblCarnetValor.Text = estudiante.Carnet;
            lblCedulaValor.Text = estudiante.Cedula;
            lblNombreValor.Text = estudiante.NombreCompleto;
            lblSexoValor.Text = estudiante.Sexo.ToString();
            lblFechaNacimientoValor.Text =
                estudiante.FechaNacimiento.ToString("dd/MM/yyyy");
            lblEdadValor.Text = estudiante.Edad.ToString();
            lblNacionalidadValor.Text = estudiante.Nacionalidad;
            lblAreaValor.Text = estudiante.AreaConocimiento.ToString();
            lblCarreraValor.Text = estudiante.Carrera;
            lblUbicacionValor.Text =
            $"{estudiante.Municipio}, {estudiante.Departamento}";
            lblCorreoValor.Text = estudiante.Correo;
            lblPromedioValor.Text = estudiante.Promedio.ToString("N2");
            lblTutorValor.Text = estudiante.TieneTutor ? "Sí" : "No";
            lblDiscapacidadValor.Text = estudiante.TieneDiscapacidadFisica
            ? estudiante.DescripcionDiscapacidad
            : "No registrada";

        }
    }
}
