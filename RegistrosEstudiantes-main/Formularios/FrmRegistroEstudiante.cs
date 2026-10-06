using Microsoft.Data.SqlClient;
using RegistroEstudiantes.Datos;
using RegistroEstudiantes.Modelos;
using RegistroEstudiantes.ServiciosTemporales;
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
    public partial class FrmRegistroEstudiante : Form
    {
        private readonly EstudianteRepository estudianteRepository = new();
        private readonly CatalogoRepository catalogoRepository = new();
        private Estudiante? estudianteEnEdicion;
        private readonly CancellationTokenSource vidaFormulario = new();
        private bool cargandoCatalogos;
        private bool catalogosListos;
        private bool guardando;
        private int operacionesPendientes;
        private bool cerrando;
        public FrmRegistroEstudiante()
        {
            InitializeComponent();
            CargarSexos();
            CargarNacionalidades();
            CargarNivelesAcademicos();

            btnGuardar.Enabled = false;
            Load += FrmRegistroEstudiante_Load;

            cboCarrera.DataSource = null;
            cboCarrera.Enabled = false;

            cboMunicipio.DataSource = null;
            cboMunicipio.Enabled = false;

            txtDescripcionDiscapacidad.Enabled = false;

        }

        public FrmRegistroEstudiante(Estudiante estudiante) : this()
        {
            estudianteEnEdicion = estudiante;

        }

        private void CargarDatosEstudiante()
        {
            if (estudianteEnEdicion == null)
                return;

            // Datos personales
            txtCarnet.Text = estudianteEnEdicion.Carnet;
            txtCedula.Text = estudianteEnEdicion.Cedula;
            txtNombres.Text = estudianteEnEdicion.Nombres;
            txtApellidos.Text = estudianteEnEdicion.Apellidos;

            // Sexo
            cboSexo.Text =
                estudianteEnEdicion.Sexo.ToString();

            // Fecha de nacimiento
            dtpFechaNacimiento.Value =
                estudianteEnEdicion.FechaNacimiento;

            // Datos académicos
            cboNacionalidad.Text =
                estudianteEnEdicion.Nacionalidad;

            cboNivelAcademico.Text =
                estudianteEnEdicion.NivelAcademico;

            chkTieneTutor.Checked =
                estudianteEnEdicion.TieneTutor;

            int indiceArea =
     cboArea.FindStringExact(
         estudianteEnEdicion.AreaConocimiento.ToString());

            if (indiceArea >= 0)
            {
                cboArea.SelectedIndex = indiceArea;
            }
            // Carrera
            cboCarrera.SelectedValue =
            estudianteEnEdicion.IdCarrera;

            // Departamento
            int indiceDepartamento =
                cboDepartamento.FindStringExact(
                    estudianteEnEdicion.Departamento);

            if (indiceDepartamento >= 0)
            {
                cboDepartamento.SelectedIndex =
                    indiceDepartamento;
            }

            // IMPORTANTE:
            // al seleccionar Departamento se cargan
            // automáticamente sus municipios.

            cboMunicipio.SelectedValue =
                estudianteEnEdicion.IdMunicipio;

            // Otros datos
            cboEtnia.Text =
                estudianteEnEdicion.Etnia;

            txtCorreo.Text =
                estudianteEnEdicion.Correo;

            nudPromedio.Value =
                estudianteEnEdicion.Promedio;

            chkDiscapacidad.Checked =
                estudianteEnEdicion.TieneDiscapacidadFisica;

            txtDescripcionDiscapacidad.Text =
                estudianteEnEdicion.DescripcionDiscapacidad;

            // El carnet no se modifica durante la edición
            txtCarnet.ReadOnly = true;
        }

        private void CargarNivelesAcademicos()
        {
            cboNivelAcademico.Items.Clear();

            cboNivelAcademico.Items.AddRange(new object[]
            {
        "Secundaria",
        "Técnico",
        "Universitario",
        "Egresado",
        "Posgrado"
            });

            cboNivelAcademico.SelectedIndex = -1;
            cboNivelAcademico.DropDownStyle =
                ComboBoxStyle.DropDownList;
        }
        private void CargarNacionalidades()
        {
            cboNacionalidad.Items.Clear();

            cboNacionalidad.Items.AddRange(new object[]
            {
        "Nicaragüense",
        "Costarricense",
        "Hondureña",
        "Salvadoreña",
        "Guatemalteca",
        "Panameña",
        "Otra"
            });

            cboNacionalidad.DropDownStyle =
                ComboBoxStyle.DropDown;

            cboNacionalidad.AutoCompleteMode =
                AutoCompleteMode.SuggestAppend;

            cboNacionalidad.AutoCompleteSource =
                AutoCompleteSource.ListItems;

            cboNacionalidad.SelectedIndex = -1;
        }
        private void CargarSexos()
        {
            cboSexo.DataSource = Enum.GetValues<Sexo>();
            cboSexo.SelectedIndex = -1;
            cboSexo.DropDownStyle = ComboBoxStyle.DropDownList;
        }

        private async Task CargarCarrerasAsync(int idArea)
        {
            List<OpcionCatalogo> carreras =
                await catalogoRepository.ListarCarrerasAsync(idArea, vidaFormulario.Token);
            vidaFormulario.Token.ThrowIfCancellationRequested();

            cboCarrera.DataSource = null;

            cboCarrera.DisplayMember = "Nombre";
            cboCarrera.ValueMember = "Id";
            cboCarrera.DataSource = carreras;

            cboCarrera.SelectedIndex = -1;

            cboCarrera.Enabled =
                carreras.Count > 0;
        }


        private async Task CargarMunicipiosAsync(int idDepartamento)
        {
            List<OpcionCatalogo> municipios =
                await catalogoRepository.ListarMunicipiosAsync(idDepartamento, vidaFormulario.Token);
            vidaFormulario.Token.ThrowIfCancellationRequested();

            cboMunicipio.DataSource = null;

            cboMunicipio.DisplayMember = "Nombre";
            cboMunicipio.ValueMember = "Id";
            cboMunicipio.DataSource = municipios;

            cboMunicipio.SelectedIndex = -1;

            cboMunicipio.Enabled = municipios.Count > 0;
        }

        private Estudiante ConstruirEstudianteDesdeFormulario()
        {
            Sexo sexo =
                (Sexo)cboSexo.SelectedItem!;

            AreaConocimiento area =
                Enum.Parse<AreaConocimiento>(
                    cboArea.Text,
                    true);

            int idCarrera =
                Convert.ToInt32(
                    cboCarrera.SelectedValue);

            int idMunicipio =
                Convert.ToInt32(
                    cboMunicipio.SelectedValue);

            return new Estudiante
            {
                Carnet = txtCarnet.Text.Trim(),
                Cedula = txtCedula.Text.Trim(),

                Nombres = txtNombres.Text.Trim(),
                Apellidos = txtApellidos.Text.Trim(),

                Sexo = sexo,

                FechaNacimiento =
                    dtpFechaNacimiento.Value.Date,

                Nacionalidad =
                    cboNacionalidad.Text.Trim(),

                NivelAcademico =
                    cboNivelAcademico.Text.Trim(),

                TieneTutor =
                    chkTieneTutor.Checked,

                AreaConocimiento = area,

                IdCarrera = idCarrera,
                Carrera = cboCarrera.Text.Trim(),

                Departamento =
                    cboDepartamento.Text.Trim(),

                IdMunicipio = idMunicipio,
                Municipio =
                    cboMunicipio.Text.Trim(),

                Etnia =
                    cboEtnia.Text.Trim(),

                Correo =
                    txtCorreo.Text.Trim(),

                Promedio =
                    nudPromedio.Value,

                TieneDiscapacidadFisica =
                    chkDiscapacidad.Checked,

                DescripcionDiscapacidad =
                    txtDescripcionDiscapacidad.Text.Trim()
            };
        }
        private bool ValidarFormulario(
     Estudiante estudiante)
        {
            List<string> errores =
                ValidadorEstudiante.Validar(estudiante);

            if (errores.Count == 0)
                return true;

            MessageBox.Show(
                string.Join(
                    Environment.NewLine,
                    errores),
                "Revise la información",
                MessageBoxButtons.OK,
                MessageBoxIcon.Warning);

            return false;
        }

        private bool ValidarControlesFormulario()
        {
            errorProvider1.Clear();

            List<string> errores = new();

            if (string.IsNullOrWhiteSpace(txtCarnet.Text))
            {
                errorProvider1.SetError(
                    txtCarnet,
                    "Ingrese el carnet.");

                errores.Add("Debe ingresar el carnet.");
            }

            if (string.IsNullOrWhiteSpace(txtNombres.Text))
            {
                errorProvider1.SetError(
                    txtNombres,
                    "Ingrese los nombres.");

                errores.Add("Debe ingresar los nombres.");
            }

            if (string.IsNullOrWhiteSpace(txtApellidos.Text))
            {
                errorProvider1.SetError(
                    txtApellidos,
                    "Ingrese los apellidos.");

                errores.Add("Debe ingresar los apellidos.");
            }

            if (cboSexo.SelectedIndex == -1)
            {
                errorProvider1.SetError(
                    cboSexo,
                    "Seleccione el sexo.");

                errores.Add("Debe seleccionar el sexo.");
            }

            if (string.IsNullOrWhiteSpace(cboNacionalidad.Text))
            {
                errorProvider1.SetError(
                    cboNacionalidad,
                    "Ingrese o seleccione la nacionalidad.");

                errores.Add("Debe indicar la nacionalidad.");
            }

            if (cboNivelAcademico.SelectedIndex == -1)
            {
                errorProvider1.SetError(
                    cboNivelAcademico,
                    "Seleccione el nivel académico.");

                errores.Add("Debe seleccionar el nivel académico.");
            }

            if (cboArea.SelectedIndex == -1)
            {
                errorProvider1.SetError(
                    cboArea,
                    "Seleccione un área.");

                errores.Add(
                    "Debe seleccionar un área de conocimiento.");
            }

            if (cboCarrera.SelectedIndex == -1)
            {
                errorProvider1.SetError(
                    cboCarrera,
                    "Seleccione una carrera.");

                errores.Add("Debe seleccionar una carrera.");
            }

            if (cboDepartamento.SelectedIndex == -1)
            {
                errorProvider1.SetError(
                    cboDepartamento,
                    "Seleccione un departamento.");

                errores.Add("Debe seleccionar un departamento.");
            }

            if (cboMunicipio.SelectedIndex == -1)
            {
                errorProvider1.SetError(
                    cboMunicipio,
                    "Seleccione un municipio.");

                errores.Add("Debe seleccionar un municipio.");
            }

            if (errores.Count == 0)
                return true;

            MessageBox.Show(
                string.Join(Environment.NewLine, errores),
                "Revise la información",
                MessageBoxButtons.OK,
                MessageBoxIcon.Warning);

            return false;
        }

        private void chkTieneTutor_CheckedChanged(object sender, EventArgs e)
        {
            // grpTutor.Enabled = chkTieneTutor.Checked;
        }

        private void chkDiscapacidad_CheckedChanged(object sender, EventArgs e)
        {
            txtDescripcionDiscapacidad.Enabled = chkDiscapacidad.Checked;

            if (!chkDiscapacidad.Checked)
                txtDescripcionDiscapacidad.Clear();
        }



        private async void btnGuardar_Click(object sender, EventArgs e)
        {
            if (guardando || !catalogosListos || cerrando)
                return;
            guardando = true;
            operacionesPendientes++;
            Enabled = false;
            UseWaitCursor = true;
            try
            {
                // 1. Validar los controles
                if (!ValidarControlesFormulario())
                    return;

                // 2. Construir el objeto
                Estudiante estudiante =
                    ConstruirEstudianteDesdeFormulario();

                // 3. Validar las reglas del modelo
                if (!ValidarFormulario(estudiante))
                    return;

                // NUEVO ESTUDIANTE
                if (estudianteEnEdicion == null)
                {
                    bool existeCarnet = await estudianteRepository.ExisteCarnetAsync(
                        estudiante.Carnet, vidaFormulario.Token);
                    vidaFormulario.Token.ThrowIfCancellationRequested();
                    if (existeCarnet)
                    {
                        errorProvider1.SetError(
                            txtCarnet,
                            "El carnet ya existe en la base de datos.");

                        return;
                    }

                    await estudianteRepository.InsertarAsync(estudiante, vidaFormulario.Token);
                    vidaFormulario.Token.ThrowIfCancellationRequested();

                    MessageBox.Show(
                        "Estudiante guardado correctamente.",
                        "Registro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Information);

                    LimpiarFormulario();
                }
                else
                {
                    estudiante.Id =
                        estudianteEnEdicion.Id;

                    estudiante.EsInterno =
                        estudianteEnEdicion.EsInterno;

                    estudiante.Activo =
                        estudianteEnEdicion.Activo;

                    await estudianteRepository.ActualizarAsync(estudiante, vidaFormulario.Token);
                    vidaFormulario.Token.ThrowIfCancellationRequested();

                    MessageBox.Show(
                        "Estudiante actualizado correctamente.",
                        "Actualización",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Information);

                    Close();
                }
            }
            catch (OperationCanceledException)
            {
                // El cierre del formulario cancela la espera de forma cooperativa.
            }
            catch (SqlException ex)
            {
                if (IsDisposed) return;
                MessageBox.Show(
                    $"Error de base de datos:\n{ex.Message}",
                    "Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
            catch (Exception ex)
            {
                if (IsDisposed) return;
                MessageBox.Show(
                    ex.Message,
                    "Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
            finally
            {
                guardando = false;
                FinalizarOperacion();
                if (!IsDisposed)
                {
                    Enabled = true;
                    UseWaitCursor = false;
                    btnGuardar.Enabled = catalogosListos;
                }
            }
        }

        private void LimpiarFormulario()
        {
            // Datos personales
            txtCarnet.Clear();
            txtCedula.Clear();
            txtNombres.Clear();
            txtApellidos.Clear();

            cboSexo.SelectedIndex = -1;

            dtpFechaNacimiento.Value =
                DateTime.Today.AddYears(-18);

            // Nacionalidad
            cboNacionalidad.SelectedIndex = -1;
            cboNacionalidad.Text = string.Empty;

            // Nivel académico
            cboNivelAcademico.SelectedIndex = -1;

            // Tutor
            chkTieneTutor.Checked = false;

            // Área y Carrera
            cboArea.SelectedIndex = -1;

            cboCarrera.DataSource = null;
            cboCarrera.Enabled = false;

            // Departamento y Municipio
            cboDepartamento.SelectedIndex = -1;

            cboMunicipio.DataSource = null;
            cboMunicipio.Enabled = false;

            // Etnia
            cboEtnia.SelectedIndex = -1;
            cboEtnia.Text = string.Empty;

            // Datos adicionales
            txtCorreo.Clear();

            nudPromedio.Value =
                nudPromedio.Minimum;

            chkDiscapacidad.Checked = false;

            txtDescripcionDiscapacidad.Clear();
            txtDescripcionDiscapacidad.Enabled = false;

            // Validaciones
            errorProvider1.Clear();

            // Por seguridad, si el método se reutiliza
            txtCarnet.ReadOnly = false;

            txtCarnet.Focus();
        }







        private async void FrmRegistroEstudiante_Load(object? sender, EventArgs e)
        {
            if (cerrando) return;
            operacionesPendientes++;
            cargandoCatalogos = true;
            Enabled = false;
            UseWaitCursor = true;
            try
            {
                await CargarCatalogosInicialesAsync();
                if (estudianteEnEdicion is not null)
                {
                    // Carrera y municipio dependen de las selecciones del estudiante.
                    cboArea.SelectedIndex = cboArea.FindStringExact(
                        estudianteEnEdicion.AreaConocimiento.ToString());
                    cboDepartamento.SelectedIndex = cboDepartamento.FindStringExact(
                        estudianteEnEdicion.Departamento);
                    if (cboArea.SelectedValue is int idArea)
                        await CargarCarrerasAsync(idArea);
                    if (cboDepartamento.SelectedValue is int idDepartamento)
                        await CargarMunicipiosAsync(idDepartamento);
                    vidaFormulario.Token.ThrowIfCancellationRequested();
                    CargarDatosEstudiante();
                }
                catalogosListos = true;
            }
            catch (OperationCanceledException) { }
            catch (SqlException ex)
            {
                if (!IsDisposed)
                    MessageBox.Show(this, $"Error al cargar catálogos:\n{ex.Message}",
                        "Error de base de datos", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            catch (Exception ex)
            {
                if (!IsDisposed)
                    MessageBox.Show(this, ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                cargandoCatalogos = false;
                FinalizarOperacion();
                if (!IsDisposed)
                {
                    Enabled = true;
                    UseWaitCursor = false;
                    btnGuardar.Enabled = catalogosListos;
                }
            }
        }

        // Paso 13: son consultas independientes y cada repositorio abre su conexión.
        private async Task CargarCatalogosInicialesAsync()
        {
            Task<List<OpcionCatalogo>> tareaAreas =
                catalogoRepository.ListarAreasAsync(vidaFormulario.Token);
            Task<List<OpcionCatalogo>> tareaDepartamentos =
                catalogoRepository.ListarDepartamentosAsync(vidaFormulario.Token);
            List<OpcionCatalogo>[] resultados = await Task.WhenAll(tareaAreas, tareaDepartamentos);
            vidaFormulario.Token.ThrowIfCancellationRequested();
            cboArea.DisplayMember = "Nombre";
            cboArea.ValueMember = "Id";
            cboArea.DataSource = resultados[0];
            cboArea.SelectedIndex = -1;
            cboDepartamento.DisplayMember = "Nombre";
            cboDepartamento.ValueMember = "Id";
            cboDepartamento.DataSource = resultados[1];
            cboDepartamento.SelectedIndex = -1;
        }

        private async void cboArea_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (cargandoCatalogos || IsDisposed)
                return;
            await CargarSeleccionDependienteAsync(cboCarrera, async () =>
            {
                if (cboArea.SelectedValue is int idArea)
                    await CargarCarrerasAsync(idArea);
            });
        }

        private async void cboDepartamento_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (cargandoCatalogos || IsDisposed)
                return;
            await CargarSeleccionDependienteAsync(cboMunicipio, async () =>
            {
                if (cboDepartamento.SelectedValue is int idDepartamento)
                    await CargarMunicipiosAsync(idDepartamento);
            });
        }

        private async Task CargarSeleccionDependienteAsync(
            ComboBox destino, Func<Task> cargar)
        {
            if (cerrando) return;
            operacionesPendientes++;
            // Deshabilitar temporalmente evita guardar con una selección incompleta.
            Enabled = false;
            destino.DataSource = null;
            destino.Enabled = false;
            try
            {
                await cargar();
            }
            catch (OperationCanceledException) { }
            catch (SqlException ex)
            {
                if (!IsDisposed)
                    MessageBox.Show(this, $"Error de base de datos:\n{ex.Message}",
                        "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            catch (Exception ex)
            {
                if (!IsDisposed)
                    MessageBox.Show(this, ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                FinalizarOperacion();
                if (!IsDisposed)
                    Enabled = true;
            }
        }

        private void FinalizarOperacion()
        {
            operacionesPendientes--;
            if (cerrando && operacionesPendientes == 0)
                vidaFormulario.Dispose();
        }

        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            base.OnFormClosing(e);
            if (!e.Cancel && !cerrando)
            {
                cerrando = true;
                vidaFormulario.Cancel();
                // Si hay una espera activa, su finally libera el CTS al terminar.
                if (operacionesPendientes == 0)
                    vidaFormulario.Dispose();
            }
        }
    }
}
