namespace USARSimMetricTool
{
    partial class frmViewer
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
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
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.mnuConfig = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItem2 = new System.Windows.Forms.ToolStripSeparator();
            this.mnuExit = new System.Windows.Forms.ToolStripMenuItem();
            this.controllerToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItem3 = new System.Windows.Forms.ToolStripSeparator();
            this.mnuLoadMap = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItem1 = new System.Windows.Forms.ToolStripSeparator();
            this.mnuConnect = new System.Windows.Forms.ToolStripMenuItem();
            this.mnuStart = new System.Windows.Forms.ToolStripMenuItem();
            this.mnuStop = new System.Windows.Forms.ToolStripMenuItem();
            this.loggerToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItem4 = new System.Windows.Forms.ToolStripSeparator();
            this.mnuLoadLog = new System.Windows.Forms.ToolStripMenuItem();
            this.mnuPlayLog = new System.Windows.Forms.ToolStripMenuItem();
            this.lblTeamName = new System.Windows.Forms.Label();
            this.btnSaveTeamName = new System.Windows.Forms.Button();
            this.txtTeamName = new System.Windows.Forms.TextBox();
            this.lblMessage = new System.Windows.Forms.Label();
            this.lblLogFileName = new System.Windows.Forms.Label();
            this.toolTip1 = new System.Windows.Forms.ToolTip(this.components);
            this.timLogDraw = new System.Windows.Forms.Timer(this.components);
            this.timTimer = new System.Windows.Forms.Timer(this.components);
            this.timOnlineDraw = new System.Windows.Forms.Timer(this.components);
            this.cb_realTimeDraw = new System.Windows.Forms.CheckBox();
            this.cb_leaveTrace = new System.Windows.Forms.CheckBox();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.lbl_ServerTime = new System.Windows.Forms.Label();
            this.lblMatchTime = new System.Windows.Forms.Label();
            this.b_matchStart = new System.Windows.Forms.Button();
            this.numUD_Y = new System.Windows.Forms.NumericUpDown();
            this.numUD_X = new System.Windows.Forms.NumericUpDown();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.panel1 = new System.Windows.Forms.Panel();
            this.panel2 = new System.Windows.Forms.Panel();
            this.numUD_scaleY = new System.Windows.Forms.NumericUpDown();
            this.numUD_scaleX = new System.Windows.Forms.NumericUpDown();
            this.label6 = new System.Windows.Forms.Label();
            this.label7 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.panel3 = new System.Windows.Forms.Panel();
            this.panel5 = new System.Windows.Forms.Panel();
            this.label8 = new System.Windows.Forms.Label();
            this.scroll_speed = new System.Windows.Forms.HScrollBar();
            this.scroll_logTime = new System.Windows.Forms.HScrollBar();
            this.rb_manualPlay = new System.Windows.Forms.RadioButton();
            this.rb_autoPlay = new System.Windows.Forms.RadioButton();
            this.b_play = new System.Windows.Forms.Button();
            this.cb_autoReplay = new System.Windows.Forms.CheckBox();
            this.numUD_distanceThreshold = new System.Windows.Forms.NumericUpDown();
            this.label9 = new System.Windows.Forms.Label();
            this.label10 = new System.Windows.Forms.Label();
            this.label11 = new System.Windows.Forms.Label();
            this.lb_detectedVictims = new System.Windows.Forms.Label();
            this.txt_lastRobotPositions = new System.Windows.Forms.TextBox();
            this.b_retrieveRobotLocations = new System.Windows.Forms.Button();
            this.numUD_score_mCoeff = new System.Windows.Forms.NumericUpDown();
            this.label12 = new System.Windows.Forms.Label();
            this.lbl_score_m = new System.Windows.Forms.Label();
            this.label14 = new System.Windows.Forms.Label();
            this.lbl_score_t = new System.Windows.Forms.Label();
            this.label15 = new System.Windows.Forms.Label();
            this.numUD_score_T = new System.Windows.Forms.NumericUpDown();
            this.label16 = new System.Windows.Forms.Label();
            this.label17 = new System.Windows.Forms.Label();
            this.label18 = new System.Windows.Forms.Label();
            this.label20 = new System.Windows.Forms.Label();
            this.label19 = new System.Windows.Forms.Label();
            this.lbl_score_result = new System.Windows.Forms.Label();
            this.lv_distance = new USARSimMetricTool.MyListView();
            this.Robot = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.Distance = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.Victim = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.picViewer = new USARSimMetricTool.MyPictureBox();
            this.menuStrip1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numUD_Y)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numUD_X)).BeginInit();
            this.panel1.SuspendLayout();
            this.panel2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numUD_scaleY)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numUD_scaleX)).BeginInit();
            this.panel3.SuspendLayout();
            this.panel5.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numUD_distanceThreshold)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numUD_score_mCoeff)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numUD_score_T)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.picViewer)).BeginInit();
            this.SuspendLayout();
            // 
            // menuStrip1
            // 
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem,
            this.controllerToolStripMenuItem,
            this.loggerToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(989, 24);
            this.menuStrip1.TabIndex = 1;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // fileToolStripMenuItem
            // 
            this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.mnuConfig,
            this.toolStripMenuItem2,
            this.mnuExit});
            this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
            this.fileToolStripMenuItem.Size = new System.Drawing.Size(62, 20);
            this.fileToolStripMenuItem.Text = "Toolbox";
            // 
            // mnuConfig
            // 
            this.mnuConfig.Name = "mnuConfig";
            this.mnuConfig.ShortcutKeys = System.Windows.Forms.Keys.F2;
            this.mnuConfig.Size = new System.Drawing.Size(129, 22);
            this.mnuConfig.Text = "Config";
            this.mnuConfig.Click += new System.EventHandler(this.mnuConfig_Click);
            // 
            // toolStripMenuItem2
            // 
            this.toolStripMenuItem2.Name = "toolStripMenuItem2";
            this.toolStripMenuItem2.Size = new System.Drawing.Size(126, 6);
            // 
            // mnuExit
            // 
            this.mnuExit.Name = "mnuExit";
            this.mnuExit.Size = new System.Drawing.Size(129, 22);
            this.mnuExit.Text = "Exit";
            this.mnuExit.Click += new System.EventHandler(this.mnuExit_Click);
            // 
            // controllerToolStripMenuItem
            // 
            this.controllerToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItem3,
            this.mnuLoadMap,
            this.toolStripMenuItem1,
            this.mnuConnect,
            this.mnuStart,
            this.mnuStop});
            this.controllerToolStripMenuItem.Name = "controllerToolStripMenuItem";
            this.controllerToolStripMenuItem.Size = new System.Drawing.Size(72, 20);
            this.controllerToolStripMenuItem.Text = "Controller";
            // 
            // toolStripMenuItem3
            // 
            this.toolStripMenuItem3.Name = "toolStripMenuItem3";
            this.toolStripMenuItem3.Size = new System.Drawing.Size(200, 6);
            // 
            // mnuLoadMap
            // 
            this.mnuLoadMap.Name = "mnuLoadMap";
            this.mnuLoadMap.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.M)));
            this.mnuLoadMap.Size = new System.Drawing.Size(203, 22);
            this.mnuLoadMap.Text = "Load Map";
            this.mnuLoadMap.Click += new System.EventHandler(this.mnuLoadMap_Click);
            // 
            // toolStripMenuItem1
            // 
            this.toolStripMenuItem1.Name = "toolStripMenuItem1";
            this.toolStripMenuItem1.Size = new System.Drawing.Size(200, 6);
            // 
            // mnuConnect
            // 
            this.mnuConnect.Name = "mnuConnect";
            this.mnuConnect.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.D)));
            this.mnuConnect.Size = new System.Drawing.Size(203, 22);
            this.mnuConnect.Text = "Connet to server";
            this.mnuConnect.Click += new System.EventHandler(this.mnuConnet_Click);
            // 
            // mnuStart
            // 
            this.mnuStart.Enabled = false;
            this.mnuStart.Name = "mnuStart";
            this.mnuStart.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.S)));
            this.mnuStart.Size = new System.Drawing.Size(203, 22);
            this.mnuStart.Text = "Start ";
            this.mnuStart.Click += new System.EventHandler(this.mnuStart_Click);
            // 
            // mnuStop
            // 
            this.mnuStop.Enabled = false;
            this.mnuStop.Name = "mnuStop";
            this.mnuStop.ShortcutKeys = ((System.Windows.Forms.Keys)(((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.Shift)
                        | System.Windows.Forms.Keys.S)));
            this.mnuStop.Size = new System.Drawing.Size(203, 22);
            this.mnuStop.Text = "Pause";
            this.mnuStop.Click += new System.EventHandler(this.mnuStop_Click);
            // 
            // loggerToolStripMenuItem
            // 
            this.loggerToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItem4,
            this.mnuLoadLog,
            this.mnuPlayLog});
            this.loggerToolStripMenuItem.Name = "loggerToolStripMenuItem";
            this.loggerToolStripMenuItem.Size = new System.Drawing.Size(56, 20);
            this.loggerToolStripMenuItem.Text = "Logger";
            this.loggerToolStripMenuItem.Click += new System.EventHandler(this.loggerToolStripMenuItem_Click);
            // 
            // toolStripMenuItem4
            // 
            this.toolStripMenuItem4.Name = "toolStripMenuItem4";
            this.toolStripMenuItem4.Size = new System.Drawing.Size(163, 6);
            // 
            // mnuLoadLog
            // 
            this.mnuLoadLog.Name = "mnuLoadLog";
            this.mnuLoadLog.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.O)));
            this.mnuLoadLog.Size = new System.Drawing.Size(166, 22);
            this.mnuLoadLog.Text = "Load Log";
            this.mnuLoadLog.Click += new System.EventHandler(this.mnuLoadLog_Click);
            // 
            // mnuPlayLog
            // 
            this.mnuPlayLog.Name = "mnuPlayLog";
            this.mnuPlayLog.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.P)));
            this.mnuPlayLog.Size = new System.Drawing.Size(166, 22);
            this.mnuPlayLog.Text = "Play Log";
            this.mnuPlayLog.Click += new System.EventHandler(this.mnuPlayLog_Click);
            // 
            // lblTeamName
            // 
            this.lblTeamName.Font = new System.Drawing.Font("Arial", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblTeamName.ForeColor = System.Drawing.Color.Blue;
            this.lblTeamName.Location = new System.Drawing.Point(12, 24);
            this.lblTeamName.Name = "lblTeamName";
            this.lblTeamName.Size = new System.Drawing.Size(358, 40);
            this.lblTeamName.TabIndex = 2;
            this.lblTeamName.Text = "Team Name (Click to change)";
            this.lblTeamName.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.toolTip1.SetToolTip(this.lblTeamName, "Team Name");
            this.lblTeamName.Click += new System.EventHandler(this.lblTeamName_Click);
            // 
            // btnSaveTeamName
            // 
            this.btnSaveTeamName.Location = new System.Drawing.Point(184, 36);
            this.btnSaveTeamName.Name = "btnSaveTeamName";
            this.btnSaveTeamName.Size = new System.Drawing.Size(56, 23);
            this.btnSaveTeamName.TabIndex = 3;
            this.btnSaveTeamName.Text = "Save";
            this.btnSaveTeamName.UseVisualStyleBackColor = true;
            this.btnSaveTeamName.Visible = false;
            this.btnSaveTeamName.Click += new System.EventHandler(this.btnSaveTeamName_Click);
            // 
            // txtTeamName
            // 
            this.txtTeamName.Font = new System.Drawing.Font("Arial Narrow", 14F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.txtTeamName.ForeColor = System.Drawing.Color.Blue;
            this.txtTeamName.Location = new System.Drawing.Point(16, 31);
            this.txtTeamName.Name = "txtTeamName";
            this.txtTeamName.Size = new System.Drawing.Size(161, 29);
            this.txtTeamName.TabIndex = 4;
            this.txtTeamName.Visible = false;
            this.txtTeamName.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtTeamName_KeyPress);
            // 
            // lblMessage
            // 
            this.lblMessage.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.lblMessage.AutoSize = true;
            this.lblMessage.Font = new System.Drawing.Font("Arial", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblMessage.Location = new System.Drawing.Point(12, 670);
            this.lblMessage.Name = "lblMessage";
            this.lblMessage.Size = new System.Drawing.Size(54, 19);
            this.lblMessage.TabIndex = 5;
            this.lblMessage.Text = "label1";
            this.lblMessage.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.toolTip1.SetToolTip(this.lblMessage, "Messages");
            // 
            // lblLogFileName
            // 
            this.lblLogFileName.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.lblLogFileName.Font = new System.Drawing.Font("Arial", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblLogFileName.ForeColor = System.Drawing.Color.Blue;
            this.lblLogFileName.Location = new System.Drawing.Point(729, 671);
            this.lblLogFileName.Name = "lblLogFileName";
            this.lblLogFileName.Size = new System.Drawing.Size(248, 23);
            this.lblLogFileName.TabIndex = 6;
            this.lblLogFileName.Tag = "salam";
            this.lblLogFileName.Text = "Test.txt";
            this.lblLogFileName.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.toolTip1.SetToolTip(this.lblLogFileName, "Log File Name");
            // 
            // timLogDraw
            // 
            this.timLogDraw.Interval = 1;
            this.timLogDraw.Tick += new System.EventHandler(this.timPlay_Tick);
            // 
            // timTimer
            // 
            this.timTimer.Interval = 1000;
            this.timTimer.Tick += new System.EventHandler(this.timTimer_Tick);
            // 
            // timOnlineDraw
            // 
            this.timOnlineDraw.Tick += new System.EventHandler(this.timOnlineDraw_Tick);
            // 
            // cb_realTimeDraw
            // 
            this.cb_realTimeDraw.AutoSize = true;
            this.cb_realTimeDraw.Location = new System.Drawing.Point(3, 29);
            this.cb_realTimeDraw.Name = "cb_realTimeDraw";
            this.cb_realTimeDraw.Size = new System.Drawing.Size(92, 17);
            this.cb_realTimeDraw.TabIndex = 7;
            this.cb_realTimeDraw.Text = "RealtimeDraw";
            this.cb_realTimeDraw.UseVisualStyleBackColor = true;
            this.cb_realTimeDraw.CheckedChanged += new System.EventHandler(this.cb_realTimeDraw_CheckedChanged);
            // 
            // cb_leaveTrace
            // 
            this.cb_leaveTrace.AutoSize = true;
            this.cb_leaveTrace.Location = new System.Drawing.Point(3, 12);
            this.cb_leaveTrace.Name = "cb_leaveTrace";
            this.cb_leaveTrace.Size = new System.Drawing.Size(84, 17);
            this.cb_leaveTrace.TabIndex = 8;
            this.cb_leaveTrace.Text = "LeaveTrace";
            this.cb_leaveTrace.UseVisualStyleBackColor = true;
            this.cb_leaveTrace.CheckedChanged += new System.EventHandler(this.cb_leaveTrace_CheckedChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(3, 27);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(61, 13);
            this.label1.TabIndex = 9;
            this.label1.Text = "ServerTime";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(4, 45);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(60, 13);
            this.label2.TabIndex = 10;
            this.label2.Text = "MatchTime";
            // 
            // lbl_ServerTime
            // 
            this.lbl_ServerTime.AutoSize = true;
            this.lbl_ServerTime.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lbl_ServerTime.Location = new System.Drawing.Point(70, 27);
            this.lbl_ServerTime.Name = "lbl_ServerTime";
            this.lbl_ServerTime.Size = new System.Drawing.Size(39, 13);
            this.lbl_ServerTime.TabIndex = 11;
            this.lbl_ServerTime.Text = "00:00";
            // 
            // lblMatchTime
            // 
            this.lblMatchTime.AutoSize = true;
            this.lblMatchTime.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblMatchTime.Location = new System.Drawing.Point(70, 45);
            this.lblMatchTime.Name = "lblMatchTime";
            this.lblMatchTime.Size = new System.Drawing.Size(39, 13);
            this.lblMatchTime.TabIndex = 12;
            this.lblMatchTime.Text = "00:00";
            // 
            // b_matchStart
            // 
            this.b_matchStart.Location = new System.Drawing.Point(20, 4);
            this.b_matchStart.Name = "b_matchStart";
            this.b_matchStart.Size = new System.Drawing.Size(75, 20);
            this.b_matchStart.TabIndex = 13;
            this.b_matchStart.Text = "StartMatch";
            this.b_matchStart.UseVisualStyleBackColor = true;
            this.b_matchStart.Click += new System.EventHandler(this.b_matchStart_Click);
            // 
            // numUD_Y
            // 
            this.numUD_Y.Location = new System.Drawing.Point(70, 37);
            this.numUD_Y.Maximum = new decimal(new int[] {
            1000,
            0,
            0,
            0});
            this.numUD_Y.Minimum = new decimal(new int[] {
            1000,
            0,
            0,
            -2147483648});
            this.numUD_Y.Name = "numUD_Y";
            this.numUD_Y.Size = new System.Drawing.Size(45, 20);
            this.numUD_Y.TabIndex = 14;
            this.numUD_Y.ValueChanged += new System.EventHandler(this.numUD_y_ValueChanged);
            // 
            // numUD_X
            // 
            this.numUD_X.Location = new System.Drawing.Point(70, 16);
            this.numUD_X.Maximum = new decimal(new int[] {
            1000,
            0,
            0,
            0});
            this.numUD_X.Minimum = new decimal(new int[] {
            1000,
            0,
            0,
            -2147483648});
            this.numUD_X.Name = "numUD_X";
            this.numUD_X.Size = new System.Drawing.Size(45, 20);
            this.numUD_X.TabIndex = 15;
            this.numUD_X.ValueChanged += new System.EventHandler(this.numUD_X_ValueChanged);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(6, 19);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(64, 13);
            this.label3.TabIndex = 16;
            this.label3.Text = "Dislocate(X)";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(6, 39);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(64, 13);
            this.label4.TabIndex = 17;
            this.label4.Text = "Dislocate(Y)";
            // 
            // panel1
            // 
            this.panel1.Controls.Add(this.b_matchStart);
            this.panel1.Controls.Add(this.label1);
            this.panel1.Controls.Add(this.label2);
            this.panel1.Controls.Add(this.lbl_ServerTime);
            this.panel1.Controls.Add(this.lblMatchTime);
            this.panel1.Location = new System.Drawing.Point(242, 36);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(113, 63);
            this.panel1.TabIndex = 20;
            // 
            // panel2
            // 
            this.panel2.Controls.Add(this.numUD_scaleY);
            this.panel2.Controls.Add(this.numUD_scaleX);
            this.panel2.Controls.Add(this.label6);
            this.panel2.Controls.Add(this.label7);
            this.panel2.Controls.Add(this.label5);
            this.panel2.Controls.Add(this.numUD_Y);
            this.panel2.Controls.Add(this.numUD_X);
            this.panel2.Controls.Add(this.label3);
            this.panel2.Controls.Add(this.label4);
            this.panel2.Location = new System.Drawing.Point(361, 36);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(238, 63);
            this.panel2.TabIndex = 21;
            // 
            // numUD_scaleY
            // 
            this.numUD_scaleY.Location = new System.Drawing.Point(182, 34);
            this.numUD_scaleY.Maximum = new decimal(new int[] {
            1000,
            0,
            0,
            0});
            this.numUD_scaleY.Minimum = new decimal(new int[] {
            100,
            0,
            0,
            -2147483648});
            this.numUD_scaleY.Name = "numUD_scaleY";
            this.numUD_scaleY.Size = new System.Drawing.Size(53, 20);
            this.numUD_scaleY.TabIndex = 19;
            this.numUD_scaleY.Value = new decimal(new int[] {
            600,
            0,
            0,
            0});
            this.numUD_scaleY.ValueChanged += new System.EventHandler(this.numUD_scaleY_ValueChanged);
            // 
            // numUD_scaleX
            // 
            this.numUD_scaleX.Location = new System.Drawing.Point(182, 13);
            this.numUD_scaleX.Maximum = new decimal(new int[] {
            1000,
            0,
            0,
            0});
            this.numUD_scaleX.Minimum = new decimal(new int[] {
            100,
            0,
            0,
            -2147483648});
            this.numUD_scaleX.Name = "numUD_scaleX";
            this.numUD_scaleX.Size = new System.Drawing.Size(53, 20);
            this.numUD_scaleX.TabIndex = 20;
            this.numUD_scaleX.Value = new decimal(new int[] {
            800,
            0,
            0,
            0});
            this.numUD_scaleX.ValueChanged += new System.EventHandler(this.numericUpDown2_ValueChanged);
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(126, 16);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(47, 13);
            this.label6.TabIndex = 21;
            this.label6.Text = "Scale(X)";
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(126, 36);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(47, 13);
            this.label7.TabIndex = 22;
            this.label7.Text = "Scale(Y)";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(21, 3);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(68, 13);
            this.label5.TabIndex = 18;
            this.label5.Text = "Map Aligners";
            // 
            // panel3
            // 
            this.panel3.Controls.Add(this.cb_leaveTrace);
            this.panel3.Controls.Add(this.cb_realTimeDraw);
            this.panel3.Location = new System.Drawing.Point(602, 36);
            this.panel3.Name = "panel3";
            this.panel3.Size = new System.Drawing.Size(97, 63);
            this.panel3.TabIndex = 22;
            // 
            // panel5
            // 
            this.panel5.Controls.Add(this.label8);
            this.panel5.Controls.Add(this.scroll_speed);
            this.panel5.Location = new System.Drawing.Point(703, 36);
            this.panel5.Name = "panel5";
            this.panel5.Size = new System.Drawing.Size(224, 63);
            this.panel5.TabIndex = 24;
            // 
            // label8
            // 
            this.label8.AutoSize = true;
            this.label8.Location = new System.Drawing.Point(93, 4);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(38, 13);
            this.label8.TabIndex = 1;
            this.label8.Text = "Speed";
            // 
            // scroll_speed
            // 
            this.scroll_speed.Location = new System.Drawing.Point(3, 30);
            this.scroll_speed.Maximum = 209;
            this.scroll_speed.Minimum = 1;
            this.scroll_speed.Name = "scroll_speed";
            this.scroll_speed.Size = new System.Drawing.Size(221, 16);
            this.scroll_speed.TabIndex = 0;
            this.scroll_speed.Value = 11;
            this.scroll_speed.Scroll += new System.Windows.Forms.ScrollEventHandler(this.scroll_speed_Scroll);
            // 
            // scroll_logTime
            // 
            this.scroll_logTime.Location = new System.Drawing.Point(84, 99);
            this.scroll_logTime.Maximum = 10000;
            this.scroll_logTime.Name = "scroll_logTime";
            this.scroll_logTime.Size = new System.Drawing.Size(843, 20);
            this.scroll_logTime.TabIndex = 19;
            this.scroll_logTime.Scroll += new System.Windows.Forms.ScrollEventHandler(this.scroll_logTime_Scroll);
            // 
            // rb_manualPlay
            // 
            this.rb_manualPlay.AutoSize = true;
            this.rb_manualPlay.Location = new System.Drawing.Point(11, 102);
            this.rb_manualPlay.Name = "rb_manualPlay";
            this.rb_manualPlay.Size = new System.Drawing.Size(60, 17);
            this.rb_manualPlay.TabIndex = 20;
            this.rb_manualPlay.Text = "Manual";
            this.rb_manualPlay.UseVisualStyleBackColor = true;
            this.rb_manualPlay.CheckedChanged += new System.EventHandler(this.rb_manualPlay_CheckedChanged);
            // 
            // rb_autoPlay
            // 
            this.rb_autoPlay.AutoSize = true;
            this.rb_autoPlay.Checked = true;
            this.rb_autoPlay.Location = new System.Drawing.Point(11, 82);
            this.rb_autoPlay.Name = "rb_autoPlay";
            this.rb_autoPlay.Size = new System.Drawing.Size(67, 17);
            this.rb_autoPlay.TabIndex = 21;
            this.rb_autoPlay.TabStop = true;
            this.rb_autoPlay.Text = "AutoPlay";
            this.rb_autoPlay.UseVisualStyleBackColor = true;
            this.rb_autoPlay.CheckedChanged += new System.EventHandler(this.rb_autoPlay_CheckedChanged);
            // 
            // b_play
            // 
            this.b_play.Enabled = false;
            this.b_play.Location = new System.Drawing.Point(84, 77);
            this.b_play.Name = "b_play";
            this.b_play.Size = new System.Drawing.Size(55, 21);
            this.b_play.TabIndex = 22;
            this.b_play.Text = "Play";
            this.b_play.UseVisualStyleBackColor = true;
            this.b_play.Click += new System.EventHandler(this.mnuPlayLog_Click);
            // 
            // cb_autoReplay
            // 
            this.cb_autoReplay.AutoSize = true;
            this.cb_autoReplay.Enabled = false;
            this.cb_autoReplay.Location = new System.Drawing.Point(145, 79);
            this.cb_autoReplay.Name = "cb_autoReplay";
            this.cb_autoReplay.Size = new System.Drawing.Size(81, 17);
            this.cb_autoReplay.TabIndex = 25;
            this.cb_autoReplay.Text = "AutoReplay";
            this.cb_autoReplay.UseVisualStyleBackColor = true;
            this.cb_autoReplay.CheckedChanged += new System.EventHandler(this.cb_autoReplay_CheckedChanged);
            // 
            // numUD_distanceThreshold
            // 
            this.numUD_distanceThreshold.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.numUD_distanceThreshold.Location = new System.Drawing.Point(858, 387);
            this.numUD_distanceThreshold.Name = "numUD_distanceThreshold";
            this.numUD_distanceThreshold.Size = new System.Drawing.Size(49, 20);
            this.numUD_distanceThreshold.TabIndex = 28;
            this.numUD_distanceThreshold.ValueChanged += new System.EventHandler(this.numUD_distanceThreshold_ValueChanged);
            // 
            // label9
            // 
            this.label9.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.label9.AutoSize = true;
            this.label9.Location = new System.Drawing.Point(796, 392);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(54, 13);
            this.label9.TabIndex = 30;
            this.label9.Text = "Threshold";
            // 
            // label10
            // 
            this.label10.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.label10.AutoSize = true;
            this.label10.Location = new System.Drawing.Point(908, 391);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(38, 13);
            this.label10.TabIndex = 31;
            this.label10.Text = "meters";
            // 
            // label11
            // 
            this.label11.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.label11.AutoSize = true;
            this.label11.Font = new System.Drawing.Font("Viner Hand ITC", 15F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label11.Location = new System.Drawing.Point(763, 327);
            this.label11.Name = "label11";
            this.label11.Size = new System.Drawing.Size(174, 32);
            this.label11.TabIndex = 32;
            this.label11.Text = "Detected Victims:";
            // 
            // lb_detectedVictims
            // 
            this.lb_detectedVictims.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.lb_detectedVictims.AutoSize = true;
            this.lb_detectedVictims.Font = new System.Drawing.Font("Modern No. 20", 15F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lb_detectedVictims.Location = new System.Drawing.Point(933, 329);
            this.lb_detectedVictims.Name = "lb_detectedVictims";
            this.lb_detectedVictims.Size = new System.Drawing.Size(19, 22);
            this.lb_detectedVictims.TabIndex = 33;
            this.lb_detectedVictims.Text = "0";
            // 
            // txt_lastRobotPositions
            // 
            this.txt_lastRobotPositions.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.txt_lastRobotPositions.Location = new System.Drawing.Point(866, 125);
            this.txt_lastRobotPositions.Name = "txt_lastRobotPositions";
            this.txt_lastRobotPositions.Size = new System.Drawing.Size(119, 20);
            this.txt_lastRobotPositions.TabIndex = 34;
            // 
            // b_retrieveRobotLocations
            // 
            this.b_retrieveRobotLocations.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.b_retrieveRobotLocations.Location = new System.Drawing.Point(766, 122);
            this.b_retrieveRobotLocations.Name = "b_retrieveRobotLocations";
            this.b_retrieveRobotLocations.Size = new System.Drawing.Size(97, 33);
            this.b_retrieveRobotLocations.TabIndex = 35;
            this.b_retrieveRobotLocations.Text = "Robot Locations";
            this.b_retrieveRobotLocations.UseVisualStyleBackColor = true;
            this.b_retrieveRobotLocations.Click += new System.EventHandler(this.button1_Click);
            // 
            // numUD_score_mCoeff
            // 
            this.numUD_score_mCoeff.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.numUD_score_mCoeff.Location = new System.Drawing.Point(773, 247);
            this.numUD_score_mCoeff.Name = "numUD_score_mCoeff";
            this.numUD_score_mCoeff.Size = new System.Drawing.Size(33, 20);
            this.numUD_score_mCoeff.TabIndex = 36;
            this.numUD_score_mCoeff.Value = new decimal(new int[] {
            10,
            0,
            0,
            0});
            this.numUD_score_mCoeff.Visible = false;
            // 
            // label12
            // 
            this.label12.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.label12.AutoSize = true;
            this.label12.Font = new System.Drawing.Font("Microsoft Sans Serif", 13F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label12.Location = new System.Drawing.Point(803, 248);
            this.label12.Name = "label12";
            this.label12.Size = new System.Drawing.Size(17, 22);
            this.label12.TabIndex = 37;
            this.label12.Text = "*";
            this.label12.Visible = false;
            // 
            // lbl_score_m
            // 
            this.lbl_score_m.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.lbl_score_m.AutoSize = true;
            this.lbl_score_m.Font = new System.Drawing.Font("Microsoft Sans Serif", 13F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lbl_score_m.Location = new System.Drawing.Point(813, 246);
            this.lbl_score_m.Name = "lbl_score_m";
            this.lbl_score_m.Size = new System.Drawing.Size(20, 22);
            this.lbl_score_m.TabIndex = 38;
            this.lbl_score_m.Text = "0";
            this.lbl_score_m.Visible = false;
            // 
            // label14
            // 
            this.label14.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.label14.AutoSize = true;
            this.label14.Font = new System.Drawing.Font("Microsoft Sans Serif", 13F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label14.Location = new System.Drawing.Point(827, 247);
            this.label14.Name = "label14";
            this.label14.Size = new System.Drawing.Size(49, 22);
            this.label14.TabIndex = 39;
            this.label14.Text = "+(1-(";
            this.label14.Visible = false;
            // 
            // lbl_score_t
            // 
            this.lbl_score_t.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.lbl_score_t.AutoSize = true;
            this.lbl_score_t.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lbl_score_t.Location = new System.Drawing.Point(868, 254);
            this.lbl_score_t.Name = "lbl_score_t";
            this.lbl_score_t.Size = new System.Drawing.Size(39, 13);
            this.lbl_score_t.TabIndex = 14;
            this.lbl_score_t.Text = "00:00";
            this.lbl_score_t.Visible = false;
            // 
            // label15
            // 
            this.label15.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.label15.AutoSize = true;
            this.label15.Font = new System.Drawing.Font("Microsoft Sans Serif", 13F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label15.Location = new System.Drawing.Point(902, 249);
            this.label15.Name = "label15";
            this.label15.Size = new System.Drawing.Size(15, 22);
            this.label15.TabIndex = 40;
            this.label15.Text = "/";
            this.label15.Visible = false;
            // 
            // numUD_score_T
            // 
            this.numUD_score_T.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.numUD_score_T.Location = new System.Drawing.Point(912, 251);
            this.numUD_score_T.Name = "numUD_score_T";
            this.numUD_score_T.Size = new System.Drawing.Size(33, 20);
            this.numUD_score_T.TabIndex = 41;
            this.numUD_score_T.Value = new decimal(new int[] {
            20,
            0,
            0,
            0});
            this.numUD_score_T.Visible = false;
            // 
            // label16
            // 
            this.label16.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.label16.AutoSize = true;
            this.label16.Font = new System.Drawing.Font("Microsoft Sans Serif", 13F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label16.Location = new System.Drawing.Point(941, 249);
            this.label16.Name = "label16";
            this.label16.Size = new System.Drawing.Size(16, 22);
            this.label16.TabIndex = 42;
            this.label16.Text = ")";
            this.label16.Visible = false;
            // 
            // label17
            // 
            this.label17.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.label17.AutoSize = true;
            this.label17.BackColor = System.Drawing.Color.Transparent;
            this.label17.Font = new System.Drawing.Font("Microsoft Sans Serif", 25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label17.Location = new System.Drawing.Point(946, 238);
            this.label17.Name = "label17";
            this.label17.Size = new System.Drawing.Size(26, 39);
            this.label17.TabIndex = 43;
            this.label17.Text = "]";
            this.label17.Visible = false;
            // 
            // label18
            // 
            this.label18.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.label18.AutoSize = true;
            this.label18.BackColor = System.Drawing.Color.Transparent;
            this.label18.Font = new System.Drawing.Font("Microsoft Sans Serif", 25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label18.Location = new System.Drawing.Point(757, 234);
            this.label18.Name = "label18";
            this.label18.Size = new System.Drawing.Size(26, 39);
            this.label18.TabIndex = 44;
            this.label18.Text = "[";
            this.label18.Visible = false;
            // 
            // label20
            // 
            this.label20.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.label20.AutoSize = true;
            this.label20.Font = new System.Drawing.Font("Viner Hand ITC", 15F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label20.Location = new System.Drawing.Point(961, 245);
            this.label20.Name = "label20";
            this.label20.Size = new System.Drawing.Size(32, 32);
            this.label20.TabIndex = 46;
            this.label20.Text = "=";
            this.label20.Visible = false;
            // 
            // label19
            // 
            this.label19.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.label19.AutoSize = true;
            this.label19.Font = new System.Drawing.Font("Viner Hand ITC", 15F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label19.Location = new System.Drawing.Point(769, 210);
            this.label19.Name = "label19";
            this.label19.Size = new System.Drawing.Size(85, 32);
            this.label19.TabIndex = 45;
            this.label19.Text = "Score =";
            this.label19.Visible = false;
            // 
            // lbl_score_result
            // 
            this.lbl_score_result.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.lbl_score_result.AutoSize = true;
            this.lbl_score_result.Font = new System.Drawing.Font("Viner Hand ITC", 15F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lbl_score_result.Location = new System.Drawing.Point(933, 281);
            this.lbl_score_result.Name = "lbl_score_result";
            this.lbl_score_result.Size = new System.Drawing.Size(39, 32);
            this.lbl_score_result.TabIndex = 47;
            this.lbl_score_result.Text = "0.0";
            this.lbl_score_result.Visible = false;
            // 
            // lv_distance
            // 
            this.lv_distance.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.lv_distance.Columns.AddRange(new System.Windows.Forms.ColumnHeader[] {
            this.Robot,
            this.Distance,
            this.Victim});
            this.lv_distance.Location = new System.Drawing.Point(763, 408);
            this.lv_distance.Name = "lv_distance";
            this.lv_distance.Size = new System.Drawing.Size(181, 259);
            this.lv_distance.TabIndex = 29;
            this.lv_distance.UseCompatibleStateImageBehavior = false;
            this.lv_distance.View = System.Windows.Forms.View.Details;
            // 
            // Robot
            // 
            this.Robot.Text = "Robot";
            this.Robot.Width = 67;
            // 
            // Distance
            // 
            this.Distance.Text = "Dist";
            this.Distance.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.Distance.Width = 52;
            // 
            // Victim
            // 
            this.Victim.Text = "Victim";
            this.Victim.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.Victim.Width = 40;
            // 
            // picViewer
            // 
            this.picViewer.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.picViewer.BackColor = System.Drawing.Color.White;
            this.picViewer.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.picViewer.Location = new System.Drawing.Point(12, 120);
            this.picViewer.Name = "picViewer";
            this.picViewer.Size = new System.Drawing.Size(745, 547);
            this.picViewer.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.picViewer.TabIndex = 0;
            this.picViewer.TabStop = false;
            this.picViewer.SizeChanged += new System.EventHandler(this.picViewer_SizeChanged);
            this.picViewer.MouseDown += new System.Windows.Forms.MouseEventHandler(this.picViewer_MouseDown);
            this.picViewer.MouseMove += new System.Windows.Forms.MouseEventHandler(this.picViewer_MouseMove);
            this.picViewer.MouseUp += new System.Windows.Forms.MouseEventHandler(this.picViewer_MouseUp);
            this.picViewer.Resize += new System.EventHandler(this.picViewer_Resize);
            // 
            // frmViewer
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(989, 695);
            this.Controls.Add(this.lbl_score_result);
            this.Controls.Add(this.label20);
            this.Controls.Add(this.label19);
            this.Controls.Add(this.numUD_score_mCoeff);
            this.Controls.Add(this.lbl_score_t);
            this.Controls.Add(this.numUD_score_T);
            this.Controls.Add(this.label16);
            this.Controls.Add(this.label18);
            this.Controls.Add(this.label17);
            this.Controls.Add(this.label15);
            this.Controls.Add(this.label14);
            this.Controls.Add(this.lbl_score_m);
            this.Controls.Add(this.label12);
            this.Controls.Add(this.b_retrieveRobotLocations);
            this.Controls.Add(this.txt_lastRobotPositions);
            this.Controls.Add(this.lb_detectedVictims);
            this.Controls.Add(this.label11);
            this.Controls.Add(this.label10);
            this.Controls.Add(this.label9);
            this.Controls.Add(this.lv_distance);
            this.Controls.Add(this.numUD_distanceThreshold);
            this.Controls.Add(this.cb_autoReplay);
            this.Controls.Add(this.b_play);
            this.Controls.Add(this.rb_autoPlay);
            this.Controls.Add(this.panel5);
            this.Controls.Add(this.rb_manualPlay);
            this.Controls.Add(this.scroll_logTime);
            this.Controls.Add(this.panel3);
            this.Controls.Add(this.panel2);
            this.Controls.Add(this.panel1);
            this.Controls.Add(this.lblLogFileName);
            this.Controls.Add(this.lblMessage);
            this.Controls.Add(this.txtTeamName);
            this.Controls.Add(this.btnSaveTeamName);
            this.Controls.Add(this.lblTeamName);
            this.Controls.Add(this.menuStrip1);
            this.Controls.Add(this.picViewer);
            this.DoubleBuffered = true;
            this.KeyPreview = true;
            this.MainMenuStrip = this.menuStrip1;
            this.MinimumSize = new System.Drawing.Size(955, 726);
            this.Name = "frmViewer";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Viewer";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.frmViewer_FormClosing);
            this.Load += new System.EventHandler(this.frmViewer_Load);
            this.Click += new System.EventHandler(this.mnuPlayLog_Click);
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numUD_Y)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numUD_X)).EndInit();
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            this.panel2.ResumeLayout(false);
            this.panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numUD_scaleY)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numUD_scaleX)).EndInit();
            this.panel3.ResumeLayout(false);
            this.panel3.PerformLayout();
            this.panel5.ResumeLayout(false);
            this.panel5.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numUD_distanceThreshold)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numUD_score_mCoeff)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numUD_score_T)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.picViewer)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }



        #endregion

        public MyPictureBox picViewer;
        public System.Windows.Forms.MenuStrip menuStrip1;
        public System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem;
        public System.Windows.Forms.ToolStripMenuItem loggerToolStripMenuItem;
        public System.Windows.Forms.ToolStripMenuItem mnuConfig;
        public System.Windows.Forms.ToolStripSeparator toolStripMenuItem2;
        public System.Windows.Forms.ToolStripMenuItem mnuExit;
        public System.Windows.Forms.Label lblTeamName;
        public System.Windows.Forms.Button btnSaveTeamName;
        public System.Windows.Forms.TextBox txtTeamName;
        public System.Windows.Forms.ToolStripMenuItem controllerToolStripMenuItem;
        public System.Windows.Forms.ToolStripSeparator toolStripMenuItem3;
        public System.Windows.Forms.ToolStripMenuItem mnuConnect;
        public System.Windows.Forms.ToolStripMenuItem mnuLoadLog;
        public System.Windows.Forms.ToolStripSeparator toolStripMenuItem4;
        public System.Windows.Forms.ToolStripMenuItem mnuPlayLog;
        public System.Windows.Forms.ToolStripMenuItem mnuStart;
        public System.Windows.Forms.ToolStripMenuItem mnuStop;
        public System.Windows.Forms.ToolStripMenuItem mnuLoadMap;
        public System.Windows.Forms.ToolStripSeparator toolStripMenuItem1;
        public System.Windows.Forms.Label lblMessage;
        public System.Windows.Forms.Label lblLogFileName;
        public System.Windows.Forms.ToolTip toolTip1;
        public System.Windows.Forms.Timer timLogDraw;
        private System.Windows.Forms.Timer timTimer;
        private System.Windows.Forms.Timer timOnlineDraw;
        private System.Windows.Forms.CheckBox cb_realTimeDraw;
        private System.Windows.Forms.CheckBox cb_leaveTrace;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label lbl_ServerTime;
        private System.Windows.Forms.Label lblMatchTime;
        private System.Windows.Forms.Button b_matchStart;
        private System.Windows.Forms.NumericUpDown numUD_Y;
        private System.Windows.Forms.NumericUpDown numUD_X;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Panel panel3;
        private System.Windows.Forms.NumericUpDown numUD_scaleY;
        private System.Windows.Forms.NumericUpDown numUD_scaleX;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Panel panel5;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.HScrollBar scroll_speed;
        private System.Windows.Forms.HScrollBar scroll_logTime;
        private System.Windows.Forms.RadioButton rb_manualPlay;
        private System.Windows.Forms.RadioButton rb_autoPlay;
        private System.Windows.Forms.Button b_play;
        private System.Windows.Forms.CheckBox cb_autoReplay;
        private System.Windows.Forms.NumericUpDown numUD_distanceThreshold;
        private USARSimMetricTool.MyListView lv_distance;
        private System.Windows.Forms.ColumnHeader Robot;
        private System.Windows.Forms.ColumnHeader Distance;
        private System.Windows.Forms.ColumnHeader Victim;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.Label label10;
        private System.Windows.Forms.Label label11;
        private System.Windows.Forms.Label lb_detectedVictims;
        private System.Windows.Forms.TextBox txt_lastRobotPositions;
        private System.Windows.Forms.Button b_retrieveRobotLocations;
        private System.Windows.Forms.NumericUpDown numUD_score_mCoeff;
        private System.Windows.Forms.Label label12;
        private System.Windows.Forms.Label lbl_score_m;
        private System.Windows.Forms.Label label14;
        private System.Windows.Forms.Label lbl_score_t;
        private System.Windows.Forms.Label label15;
        private System.Windows.Forms.NumericUpDown numUD_score_T;
        private System.Windows.Forms.Label label16;
        private System.Windows.Forms.Label label17;
        private System.Windows.Forms.Label label18;
        private System.Windows.Forms.Label label20;
        private System.Windows.Forms.Label label19;
        private System.Windows.Forms.Label lbl_score_result;


    }
}