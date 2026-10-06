using Microsoft.Data.SqlClient;
using RegistroEstudiantes.Datos;
using RegistroEstudiantes.Modelos;
using RegistroEstudiantes.ServiciosTemporales;
using System.Diagnostics;

namespace RegistroEstudiantes.Formularios
{
    public partial class FrmListaEstudiantes : Form
    {
        private readonly EstudianteRepository estudianteRepository = new();
        private CancellationTokenSource? cts;

        public FrmListaEstudiantes()
        {
            InitializeComponent();
            ConfigurarGrid();
            btnCancelar.Enabled = false;
        }

        private void ConfigurarGrid()
        {
            dgvEstudiantes.AutoGenerateColumns = false;
            dgvEstudiantes.AllowUserToAddRows = false;
            Carnet.DataPropertyName = "Carnet";
            Nombrecompleto.DataPropertyName = "NombreCompleto";
            Sexo.DataPropertyName = "Sexo";
            Carrera.DataPropertyName = "Carrera";
            Nivel.DataPropertyName = "NivelAcademico";
            Correo.DataPropertyName = "Correo";
            Promedio.DataPropertyName = "Promedio";
        }

        private Estudiante? ObtenerSeleccionado() =>
            dgvEstudiantes.CurrentRow?.DataBoundItem as Estudiante;

        private List<Estudiante> ObtenerEstudiantesVisibles() =>
            dgvEstudiantes.Rows.Cast<DataGridViewRow>()
                .Select(fila => fila.DataBoundItem).OfType<Estudiante>().ToList();

        private void btnVerDetalle_Click(object sender, EventArgs e)
        {
            Estudiante? estudiante = ObtenerSeleccionado();
            if (estudiante is null)
            {
                MessageBox.Show("Seleccione un estudiante.");
                return;
            }
            using FrmDetalleEstudiante detalle = new(estudiante);
            detalle.ShowDialog(this);
        }

        private async void FrmListaEstudiantes_Load(object sender, EventArgs e)
        {
            await EjecutarOperacionAsync("Cargando estudiantes...", CargarEstudiantesAsync);
        }

        private async Task CargarEstudiantesAsync(CancellationToken token)
        {
            List<Estudiante> estudiantes = await estudianteRepository.ListarAsync(token);
            token.ThrowIfCancellationRequested();
            dgvEstudiantes.DataSource = estudiantes;
            lblEstado.Text = $"{estudiantes.Count} estudiantes cargados.";
        }

        private async void btnBuscar_Click(object sender, EventArgs e)
        {
            string texto = txtBuscar.Text.Trim();
            await EjecutarOperacionAsync("Buscando...", async token =>
            {
                if (string.IsNullOrWhiteSpace(texto))
                {
                    await CargarEstudiantesAsync(token);
                    return;
                }
                List<Estudiante> resultados = await estudianteRepository.BuscarAsync(texto, token);
                token.ThrowIfCancellationRequested();
                dgvEstudiantes.DataSource = resultados;
                lblEstado.Text = $"Resultados: {resultados.Count}";
            });
        }

        private async void btnDesactivar_Click(object sender, EventArgs e)
        {
            Estudiante? estudiante = ObtenerSeleccionado();
            if (estudiante is null)
            {
                MessageBox.Show("Seleccione un estudiante para desactivar.");
                return;
            }
            if (MessageBox.Show(
                $"¿Está seguro de desactivar a {estudiante.NombreCompleto}?",
                "Confirmar desactivación", MessageBoxButtons.YesNo,
                MessageBoxIcon.Question) != DialogResult.Yes)
                return;

            await EjecutarOperacionAsync("Desactivando estudiante...", async token =>
            {
                await estudianteRepository.DesactivarAsync(estudiante.Id, token);
                token.ThrowIfCancellationRequested();
                EscribirLog("Estudiante desactivado correctamente.");
                await CargarEstudiantesAsync(token);
            });
        }

        private async void btnEditar_Click(object sender, EventArgs e)
        {
            Estudiante? estudiante = ObtenerSeleccionado();
            if (estudiante is null)
            {
                MessageBox.Show("Seleccione un estudiante para editar.");
                return;
            }
            await EjecutarOperacionAsync("Editando estudiante...", async token =>
            {
                using FrmRegistroEstudiante formulario = new(estudiante);
                formulario.ShowDialog(this);
                token.ThrowIfCancellationRequested();
                await CargarEstudiantesAsync(token);
            });
        }

        // Paso 1: bloqueo deliberado para comparar con el procesamiento asíncrono.
        private void btnProcesarBloqueante_Click(object sender, EventArgs e)
        {
            List<Estudiante> estudiantes = ObtenerEstudiantesVisibles();
            if (estudiantes.Count == 0)
            {
                MessageBox.Show("No hay estudiantes para procesar.");
                return;
            }
            for (int i = 0; i < estudiantes.Count; i++)
            {
                Thread.Sleep(300);
                lblEstado.Text = $"Procesando {i + 1} de {estudiantes.Count}";
            }
            lblEstado.Text = "Proceso bloqueante finalizado.";
            MessageBox.Show("Proceso finalizado.");
        }

        private static void ProcesarEnSegundoPlano(
            IReadOnlyList<Estudiante> estudiantes,
            IProgress<ProgresoTarea> progreso, CancellationToken token)
        {
            for (int i = 0; i < estudiantes.Count; i++)
            {
                token.ThrowIfCancellationRequested();
                // Simula trabajo bloqueante; la señal permite cancelar durante la espera.
                if (token.WaitHandle.WaitOne(250))
                    token.ThrowIfCancellationRequested();
                Estudiante estudiante = estudiantes[i];
                progreso.Report(new ProgresoTarea(i + 1, estudiantes.Count,
                    $"Procesado: {estudiante.Carnet} - {estudiante.NombreCompleto}"));
            }
        }

        private async void btnProcesar_Click(object sender, EventArgs e)
        {
            List<Estudiante> estudiantes = ObtenerEstudiantesVisibles();
            if (estudiantes.Count == 0)
            {
                MessageBox.Show("No hay estudiantes para procesar.");
                return;
            }
            await EjecutarOperacionAsync("Iniciando proceso...", async token =>
            {
                prgProceso.Style = ProgressBarStyle.Blocks;
                prgProceso.Maximum = estudiantes.Count;
                // Creado en el hilo UI: los reportes vuelven a ese contexto.
                Progress<ProgresoTarea> progreso = new(p =>
                {
                    if (IsDisposed || token.IsCancellationRequested || cts is null || cts.Token != token)
                        return;
                    prgProceso.Value = p.Actual;
                    lblEstado.Text = $"Procesando {p.Actual} de {p.Total}";
                    EscribirLog(p.Mensaje);
                });
                await Task.Run(() => ProcesarEnSegundoPlano(estudiantes, progreso, token), token);
                token.ThrowIfCancellationRequested();
                lblEstado.Text = "Proceso finalizado correctamente.";
                EscribirLog("La tarea terminó correctamente.");
            });
        }

        // Paso 15: resumen de los estudiantes visibles, en una tabla independiente.
        private async void btnResumen_Click(object sender, EventArgs e)
        {
            List<Estudiante> estudiantes = ObtenerEstudiantesVisibles();
            if (estudiantes.Count == 0)
            {
                MessageBox.Show("No hay estudiantes para resumir.");
                return;
            }
            await EjecutarOperacionAsync("Calculando resumen por carrera...", async token =>
            {
                Stopwatch reloj = Stopwatch.StartNew();
                List<ResumenCarrera> resumen =
                    await AnalisisEstudiantes.CrearResumenPorCarreraAsync(estudiantes, token);
                reloj.Stop();
                token.ThrowIfCancellationRequested();
                lblEstado.Text = $"Resumen: {resumen.Count} carreras.";
                EscribirLog($"PLINQ: {estudiantes.Count} estudiantes, {reloj.ElapsedMilliseconds} ms.");
                foreach (ResumenCarrera fila in resumen)
                    EscribirLog($"{fila.Carrera}: {fila.Cantidad} estudiantes, promedio {fila.Promedio:N2}.");
                using Form ventana = new()
                {
                    Text = "Resumen por carrera (PLINQ)", Size = new Size(650, 400),
                    StartPosition = FormStartPosition.CenterParent
                };
                DataGridView tabla = new()
                {
                    Dock = DockStyle.Fill, ReadOnly = true, AllowUserToAddRows = false,
                    AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
                    DataSource = resumen
                };
                tabla.Columns[nameof(ResumenCarrera.Promedio)].DefaultCellStyle.Format = "N2";
                ventana.Controls.Add(tabla);
                ventana.ShowDialog(this);
            });
        }

        // Paso 16: cálculo numérico independiente de SQL Server.
        private async void btnCalculoParalelo_Click(object sender, EventArgs e)
        {
            await EjecutarOperacionAsync("Ejecutando cálculo paralelo...", async token =>
            {
                Stopwatch reloj = Stopwatch.StartNew();
                double[] resultados = await AnalisisEstudiantes.CalcularEnParaleloAsync(token: token);
                reloj.Stop();
                token.ThrowIfCancellationRequested();
                lblEstado.Text = "Cálculo paralelo finalizado.";
                EscribirLog($"Parallel.For: {resultados.Length:N0} resultados en {reloj.ElapsedMilliseconds} ms.");
                EscribirLog($"Primer resultado: {resultados[0]:N6}; último: {resultados[^1]:N6}.");
            });
        }

        private void EscribirLog(string mensaje) =>
            txtLog.AppendText($"[{DateTime.Now:HH:mm:ss}] {mensaje}{Environment.NewLine}");

        private void CambiarEstadoBotones(bool ocupado)
        {
            btnBuscar.Enabled = !ocupado;
            btnEditar.Enabled = !ocupado;
            btnDesactivar.Enabled = !ocupado;
            btnProcesar.Enabled = !ocupado;
            btnProcesarBloqueante.Enabled = !ocupado;
            btnResumen.Enabled = !ocupado;
            btnCalculoParalelo.Enabled = !ocupado;
            btnCancelar.Enabled = ocupado;
        }

        // Pasos 17 y 18: un único ciclo de vida para errores, cancelación y limpieza.
        private async Task EjecutarOperacionAsync(
            string estado, Func<CancellationToken, Task> operacion)
        {
            if (cts is not null || IsDisposed)
                return;
            CancellationTokenSource fuente = new();
            cts = fuente;
            CambiarEstadoBotones(true);
            UseWaitCursor = true;
            prgProceso.Value = 0;
            prgProceso.Style = ProgressBarStyle.Marquee;
            lblEstado.Text = estado;
            try
            {
                await operacion(fuente.Token);
            }
            catch (OperationCanceledException)
            {
                if (!IsDisposed)
                {
                    lblEstado.Text = "Operación cancelada.";
                    EscribirLog("La operación fue cancelada. Si era una escritura SQL, recargue para comprobar su estado.");
                }
            }
            catch (SqlException ex)
            {
                if (!IsDisposed)
                {
                    lblEstado.Text = "Error de base de datos.";
                    EscribirLog(ex.Message);
                    MessageBox.Show(this, $"Error de base de datos:\n{ex.Message}",
                        "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
            catch (Exception ex)
            {
                if (!IsDisposed)
                {
                    lblEstado.Text = "No se pudo completar la operación.";
                    EscribirLog(ex.Message);
                    MessageBox.Show(this, ex.Message, "Error",
                        MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
            finally
            {
                cts = null;
                fuente.Dispose(); // Se libera después de finalizar la tarea.
                if (!IsDisposed)
                {
                    prgProceso.Style = ProgressBarStyle.Blocks;
                    UseWaitCursor = false;
                    CambiarEstadoBotones(false);
                }
            }
        }

        private void btnCancelar_Click(object sender, EventArgs e)
        {
            cts?.Cancel();
            btnCancelar.Enabled = false;
        }

        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            base.OnFormClosing(e);
            if (!e.Cancel)
                cts?.Cancel();
        }
    }
}
