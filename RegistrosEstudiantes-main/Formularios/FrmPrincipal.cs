using Microsoft.Data.SqlClient;
using RegistroEstudiantes.Datos;
using RegistroEstudiantes.Formularios;

namespace RegistroEstudiantes
{
    public partial class FrmPrincipal : Form
    {
        private const int MenuExpandido = 220;
        private const int MenuContraido = 60;
        private Form? formularioActivo;
        public FrmPrincipal()
        {
            InitializeComponent();
            WindowState = FormWindowState.Maximized;
            MinimumSize = new Size(900, 600);
        }

        private void AbrirFormulario(Form formulario)
        {
            formularioActivo?.Close();
            formularioActivo = formulario;

            formulario.TopLevel = false;
            formulario.FormBorderStyle = FormBorderStyle.None;
            formulario.Dock = DockStyle.Fill;

            pnlContenido.Controls.Clear();
            pnlContenido.Controls.Add(formulario);
            pnlContenido.Tag = formulario;

            formulario.BringToFront();
            formulario.Show();
        }
        private void btnHamburgues_Click(object sender, EventArgs e)
        {

            pnlMenu.Width = pnlMenu.Width == MenuExpandido
                ? MenuContraido
                : MenuExpandido;

            bool mostrarTexto = pnlMenu.Width == MenuExpandido;

            btnEstudiantes.Text = mostrarTexto ? "  Registrar" : string.Empty;
            btnLista.Text = mostrarTexto ? "  Estudiantes" : string.Empty;
            btnSalir.Text = mostrarTexto ? "  Salir" : string.Empty;
        }

        private void btnEstudiantes_Click(object sender, EventArgs e)
        {
            AbrirFormulario(new FrmRegistroEstudiante());
        }

        private void btnSalir_Click(object sender, EventArgs e)
        {
            DialogResult respuesta = MessageBox.Show(
      "¿Desea cerrar la aplicación?",
      "Confirmación",
      MessageBoxButtons.YesNo,
      MessageBoxIcon.Question);

            if (respuesta == DialogResult.Yes)
                Application.Exit();
        }

        private void btnLista_Click(object sender, EventArgs e)
        {
            AbrirFormulario(new FrmListaEstudiantes());
        }

        
    }
}
