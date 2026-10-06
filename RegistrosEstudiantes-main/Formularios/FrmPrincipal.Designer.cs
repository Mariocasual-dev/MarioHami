namespace RegistroEstudiantes
{
    partial class FrmPrincipal
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            pnlMenu = new Panel();
            btnSalir = new Button();
            btnLista = new Button();
            btnEstudiantes = new Button();
            btnHamburgues = new Button();
            pnlEncabezado = new Panel();
            pnlContenido = new Panel();
            pnlMenu.SuspendLayout();
            SuspendLayout();
            // 
            // pnlMenu
            // 
            pnlMenu.BackColor = SystemColors.AppWorkspace;
            pnlMenu.Controls.Add(btnSalir);
            pnlMenu.Controls.Add(btnLista);
            pnlMenu.Controls.Add(btnEstudiantes);
            pnlMenu.Controls.Add(btnHamburgues);
            pnlMenu.Dock = DockStyle.Left;
            pnlMenu.Location = new Point(0, 0);
            pnlMenu.Name = "pnlMenu";
            pnlMenu.Size = new Size(220, 553);
            pnlMenu.TabIndex = 0;
            // 
            // btnSalir
            // 
            btnSalir.Dock = DockStyle.Top;
            btnSalir.Location = new Point(0, 138);
            btnSalir.Name = "btnSalir";
            btnSalir.Size = new Size(220, 46);
            btnSalir.TabIndex = 3;
            btnSalir.Text = "Salir";
            btnSalir.UseVisualStyleBackColor = true;
            btnSalir.Click += btnSalir_Click;
            // 
            // btnLista
            // 
            btnLista.Dock = DockStyle.Top;
            btnLista.Location = new Point(0, 92);
            btnLista.Name = "btnLista";
            btnLista.Size = new Size(220, 46);
            btnLista.TabIndex = 2;
            btnLista.Text = "Lista de estudiantes";
            btnLista.UseVisualStyleBackColor = true;
            btnLista.Click += btnLista_Click;
            // 
            // btnEstudiantes
            // 
            btnEstudiantes.Dock = DockStyle.Top;
            btnEstudiantes.Location = new Point(0, 46);
            btnEstudiantes.Name = "btnEstudiantes";
            btnEstudiantes.Size = new Size(220, 46);
            btnEstudiantes.TabIndex = 1;
            btnEstudiantes.Text = "Registrar estudiante";
            btnEstudiantes.UseVisualStyleBackColor = true;
            btnEstudiantes.Click += btnEstudiantes_Click;
            // 
            // btnHamburgues
            // 
            btnHamburgues.Dock = DockStyle.Top;
            btnHamburgues.Location = new Point(0, 0);
            btnHamburgues.Name = "btnHamburgues";
            btnHamburgues.Size = new Size(220, 46);
            btnHamburgues.TabIndex = 0;
            btnHamburgues.Text = "☰";
            btnHamburgues.UseVisualStyleBackColor = true;
            btnHamburgues.Click += btnHamburgues_Click;
            // 
            // pnlEncabezado
            // 
            pnlEncabezado.BackColor = SystemColors.AppWorkspace;
            pnlEncabezado.Dock = DockStyle.Top;
            pnlEncabezado.Location = new Point(220, 0);
            pnlEncabezado.Name = "pnlEncabezado";
            pnlEncabezado.Size = new Size(662, 55);
            pnlEncabezado.TabIndex = 1;
            // 
            // pnlContenido
            // 
            pnlContenido.AutoScroll = true;
            pnlContenido.BackColor = SystemColors.ControlLight;
            pnlContenido.Dock = DockStyle.Fill;
            pnlContenido.Location = new Point(220, 55);
            pnlContenido.Name = "pnlContenido";
            pnlContenido.Size = new Size(662, 498);
            pnlContenido.TabIndex = 2;
            // 
            // FrmPrincipal
            // 
            AutoScaleDimensions = new SizeF(120F, 120F);
            AutoScaleMode = AutoScaleMode.Dpi;
            ClientSize = new Size(882, 553);
            Controls.Add(pnlContenido);
            Controls.Add(pnlEncabezado);
            Controls.Add(pnlMenu);
            MinimumSize = new Size(900, 600);
            Name = "FrmPrincipal";
            StartPosition = FormStartPosition.CenterScreen;
            Text = "Principal";
            WindowState = FormWindowState.Maximized;
            pnlMenu.ResumeLayout(false);
            ResumeLayout(false);
        }

        #endregion

        private Panel pnlMenu;
        private Button btnLista;
        private Button btnEstudiantes;
        private Button btnHamburgues;
        private Panel pnlEncabezado;
        private Panel pnlContenido;
        private Button btnSalir;
    }
}
