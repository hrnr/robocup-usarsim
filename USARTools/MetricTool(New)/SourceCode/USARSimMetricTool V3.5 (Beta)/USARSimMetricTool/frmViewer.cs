using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using USARSimMetricTool.USARSim;
using System.IO;
using USARSimMetricTool.Common;

namespace USARSimMetricTool
{
    public partial class frmViewer : Form
    {
        public frmViewer()
        {
            InitializeComponent();
        }

        //private Image bmp = null;
        private Image mainMap = null;                
        
        int currentTime = 0;
        bool manualDraw = false;
        bool logLoadSuccess;
        bool logIsPlaying = false;
        
        private int RobotIndicatorSizeWhileLeavingTrace = 2;
        private int RobotIndicatorSizeWhileNotLeavingTrace = 5;
        private int VictimIndicatorSize = 6;
        private int logger_startIndex = 0;
        private Manager manager;
        private bool EditMapMode = false;
        private bool IsMouseDown = false;
        private Point MouseDownLocation;
        private Point MouseDownDrawPointLocation;
        private bool canModifyField = true;
        private int totalTime = 0;
        private int matchTime = 0;
        private bool matchStart = false;
        private float firstRobotInitiatedTime = 0;
        private bool firstRobotInitiated = false;
        private Font MapInfoFont = new Font("tahoma", 9);
        private Brush MapInfoBrush = new SolidBrush(Color.White);

        public void mnuExit_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show("Do you exit?", "Quit", MessageBoxButtons.YesNo) == System.Windows.Forms.DialogResult.Yes)
                Application.Exit();
        }
        
        public void mnuConfig_Click(object sender, EventArgs e)
        {
            frmConfig frm = new frmConfig();
            frm.ShowDialog();
        }
        public void mnuLoadLog_Click(object sender, EventArgs e)
        {            
            if (string.IsNullOrEmpty(Commons.CurrentMapName))
            {
                MessageBox.Show("Map not loaded.");
                mnuLoadMap_Click(null, null);
                //AHA
                //return;
            }
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Title = "Loading log file";
            ofd.Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*";
            if (ofd.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                reset();
                string fileName = ofd.FileName;
                //FileInfo f = new FileInfo(fileName);
                lblLogFileName.Text = ofd.SafeFileName;
                reset();
                if (Commons.World.LoadFromFile(fileName))
                    scroll_logTime.Maximum = Commons.World.FinalTime() - 1;
                string[] teamName = ofd.SafeFileName.Split("-".ToCharArray());
                if (teamName.Length > 0)
                    lblTeamName.Text = teamName[0];
                mnuPlayLog.Visible = true;
                b_play.Enabled = true;
                cb_autoReplay.Enabled = true;
                lblMessage.Text = "Log File Loaded successfully.";
                lblMessage.ForeColor = Color.Green;
            }
            
            //if (File.Exists(Commons.Config.Default_Map))
            //    mainMap = new Bitmap(Commons.Config.Default_Map);
            DrawMap();

            
            logLoadSuccess = true;
        }
        public void mnuPlayLog_Click(object sender, EventArgs e)
        {
            if (manualDraw)
                switchToAutoPlay();

            if (mainMap == null || !logLoadSuccess)
                return;
            
            if (!logIsPlaying)
            {
                startPlayLog();
            }
            else
                stopPlayLog();
        }

        private void startPlayLog()
        {            
            mnuPlayLog.Text = "Pause Log";
            lblMessage.Text = "Playing.";
            mnuLoadLog.Enabled = false;            
            canModifyField = false;
            b_play.Text = "Pause";
                       
            timLogDraw.Enabled = true;
            lblMessage.ForeColor = Color.Green;

            logIsPlaying = true;
        }

        private void stopPlayLog()
        {
            mnuPlayLog.Text = "Play Log";
            lblMessage.Text = "Pause.";
            mnuLoadLog.Enabled = true;
            canModifyField = true;
            b_play.Text = "Play";

            timLogDraw.Enabled = false;

            logIsPlaying = false;
        }

        public void mnuLoadMap_Click(object sender, EventArgs e)
        {            
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Title = "Loading map file.";
            ofd.Filter = "Png files (*.png)|*.png";
            if (ofd.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                //reset();
                //Commons.Config.Default_Map = ofd.FileName;
                string temp = Commons.CurrentMapName;
                Commons.CurrentMapName = ofd.SafeFileName;
                if (Commons.Config.addMapConfig(Commons.CurrentMapName))
                {
                    frmMapConfig frm = new frmMapConfig();
                    if (frm.ShowDialog() == System.Windows.Forms.DialogResult.OK)
                    {
                        Commons.Config.getMapConfig(ofd.SafeFileName).MapHeight =
                            int.Parse(frm.txtMapHeight.Text);
                        Commons.Config.getMapConfig(ofd.SafeFileName).MapWidth =
                            int.Parse(frm.txtMapWidth.Text);

                    }
                    else
                    {
                        Commons.CurrentMapName = temp;
                        Commons.Config.removeMapConfig(ofd.SafeFileName);
                        return;
                    }
                }
                Commons.Config.getMapConfig(ofd.SafeFileName).MapFullPath =
                       ofd.FileName;
                //AHA
                Commons.currentMapWidth = Commons.Config.getMapConfig(ofd.SafeFileName).MapWidth;
                Commons.currentMapHeight = Commons.Config.getMapConfig(ofd.SafeFileName).MapHeight;

                if (File.Exists(ofd.FileName))
                    mainMap = new Bitmap(ofd.FileName);
                picViewer.Image = mainMap;                
                picViewer.Invalidate();
            }
            
        }

        private void frmViewer_Load(object sender, EventArgs e)
        {
            Commons.Form_Viewer = this;
            if (Commons.Config.Viewer_Size.Height != 0)
            {
                this.Size = Commons.Config.Viewer_Size;                
            }
            Commons.Config.Viewer_Size = this.Size;
            this.Location = Commons.Config.Viewer_Location;
            lblMessage.ForeColor = Color.Red;
            lblMessage.Text = "Connection is not avalible";

            cb_realTimeDraw.Checked = Commons.Config.Viewer_OnlineDraw;
            cb_leaveTrace.Checked = Commons.Config.Viewer_LeaveTrace;

            numUD_X.Value = (Decimal)Commons.Config.dislocateX;
            numUD_Y.Value = (Decimal)Commons.Config.dislocateY;
            numUD_scaleX.Value = (Decimal)Commons.Config.scaleX;
            numUD_scaleY.Value = (Decimal)Commons.Config.scaleY;

            lblTeamName.Text = Commons.Config.TeamName;

            scroll_speed.Value = Commons.Config.speed;
            cb_autoReplay.Checked = Commons.Config.autoReplay;

            numUD_distanceThreshold.DecimalPlaces = 2;
            numUD_distanceThreshold.Increment = 0.1M;
            numUD_distanceThreshold.Value = (decimal)Commons.Config.distanceThreshold;        

            reset();
        }
        private void frmViewer_FormClosing(object sender, System.Windows.Forms.FormClosingEventArgs e)
        {
            Commons.Config.Viewer_Size = this.Size;
            Commons.Config.Viewer_Location = this.Location;
            Commons.Config.Drawer_Size = picViewer.Size;
            Commons.Config.SaveConfig();
        }
        private void lblTeamName_Click(object sender, EventArgs e)
        {
            if (!canModifyField)
            {
                setMessage("Modifying team name is not avalible.", MessageType.Error);
                return;
            }
            lblTeamName.Visible = false;
            txtTeamName.Visible = true;
            btnSaveTeamName.Visible = true;
            if (!lblTeamName.Text.ToLower().Contains("click to change"))
                txtTeamName.Text = lblTeamName.Text;
            txtTeamName.Focus();
        }
        private void btnSaveTeamName_Click(object sender, EventArgs e)
        {            
                saveTeamName();            
        }

        private void saveTeamName()
        {
            if (string.IsNullOrEmpty(txtTeamName.Text))
            {
                MessageBox.Show("Enter a team Name.");
                return;
            }
            else
            {
                lblTeamName.Visible = true;
                txtTeamName.Visible = false;
                btnSaveTeamName.Visible = false;
                lblTeamName.Text = txtTeamName.Text;

                Commons.Config.TeamName = txtTeamName.Text;
            }
        }

        private void picViewer_Resize(object sender, EventArgs e)
        {
            picViewer.Invalidate();
            //lblTime.Text = picViewer.Size.Width.ToString() + " - " + picViewer.Size.Height.ToString();
            //lblTime.Text += this.Size.Width.ToString() + " - " + this.Size.Height.ToString();

            //backbuffer = new Bitmap(picViewer.Width, picViewer.Height);
            //forebuffer = new Bitmap(picViewer.Width, picViewer.Height);
            //backbufferG = Graphics.FromImage(backbuffer);
        }

        Bitmap backbuffer;
        Bitmap forebuffer;
        Graphics backbufferG;
        Graphics forebufferG;

        bool mapDrawnOnBackBuffer = false;
        private void DrawMap()
        {
            if (mainMap == null)
            {
                stopPlayLog();
                timOnlineDraw.Stop();
                return;
            }
            forebufferG = picViewer.CreateGraphics();
            
            if (string.IsNullOrEmpty(Commons.CurrentMapName))
            {
                MessageBox.Show("Map not loaded.");
                mnuLoadMap_Click(null, null);
                //AHA
                //return;
            }

            //if (mainMap == null)
                //mainMap = new Bitmap(Commons.Config.Default_Map);
            if (backbuffer == null)
                backbuffer = new Bitmap(800, 600);
            if (backbufferG == null)
                backbufferG = Graphics.FromImage(backbuffer);

            
            if (!mapDrawnOnBackBuffer)
            {
                backbufferG.DrawImage(mainMap, 0, 0, 800, 600);
                mapDrawnOnBackBuffer = true;
            }

            if (manualDraw)
            {
                backbufferG.DrawImage(mainMap, 0, 0, 800, 600); //Leaves Trace
            }
            else
            {
                if (!Commons.Config.Viewer_LeaveTrace)
                    backbufferG.DrawImage(mainMap, 0, 0, 800, 600);
            }

            
            List<Robot> robots = Commons.World.getUSARRobots().Values.ToList();

            int count = robots.Count;            
            for (int i = 0; i < count; i++)
            {
                DrawRobot(backbufferG, robots[i]);
            }
            count = Commons.World.getUSARVictims().Count;
            List<USARItem> victims = (List<USARItem>)Commons.World.getUSARVictims().Values.ToList();            
            for (int i = 0; i < count ; ++i)
            {
                
                DrawVictims(backbufferG, victims[i]);
            }


            if (robots.Count > 0)
            {
                if (!firstRobotInitiated)
                {
                    firstRobotInitiatedTime = float.Parse(robots[0].Time);
                    firstRobotInitiated = true;
                }
                float currentTime = float.Parse(robots[0].Time) - firstRobotInitiatedTime;
                //backbufferG.DrawString("ServerTime:" + robots[0].Time, MapInfoFont, MapInfoBrush, new PointF(5, 10));

                lbl_ServerTime.Text = Commons.getTimeString((int)currentTime);
                //UpdateScore();
            }

            picViewer.Image = backbuffer;
            picViewer.Invalidate();


            lv_distance.BeginUpdate();
            UpdateRobotNamesAndDistances();
            lv_distance.EndUpdate();
        }

        private void UpdateRobotNamesAndDistances()
        {
            List<Robot> robots = Commons.World.getUSARRobots().Values.ToList();
            if (robots.Count > 0)
            {
                UpdateRobotNames();
                UpdateDistances();
            }
            else
                lv_distance.Items.Clear();
        }

        public void UpdateRobotNames()
        {
            List<Robot> robots = Commons.World.getUSARRobots().Values.ToList();

            if (robots.Count > 0)
            {                
                for (int i = 0; i < robots.Count; i++)
                {
                    if (i >= lv_distance.Items.Count)
                        lv_distance.Items.Add(robots[i].Name);
                    else
                        lv_distance.Items[i].SubItems[0].Text = (robots[i].Name);

                    lv_distance.Items[i].ForeColor = Commons.DEFAULT_COLORS[i];
                }
            }            
        }

        private void UpdateScore()
        {
            lbl_score_m.Text = lb_detectedVictims.Text;
            lbl_score_t.Text = lbl_ServerTime.Text;

            float s = (int)numUD_score_mCoeff.Value * int.Parse(lbl_score_m.Text) + (1 - (000 / (int)numUD_score_T.Value * 60)) * 50;
            lbl_score_result.Text = s.ToString("00.00");
        }

        private void UpdateDistances()
        {
            //lv_distance.BeginUpdate();
            List<Robot> robots = Commons.World.getUSARRobots().Values.ToList();
            List<USARItem> victims = (List<USARItem>)Commons.World.getUSARVictims().Values.ToList();
            List<int> detectedVictims = new List<int>();                

            for (int r = 0; r < robots.Count; ++r)
            {
                double min = double.MaxValue;
                int minIndex = -1;

                for (int v = 0; v < victims.Count; ++v)
                {
                    double d = robots[r].Location[robots[r].Location.Count - 1].Distance(victims[v].Location);
                    if (d < min)
                    {
                        min = d;
                        minIndex = v;
                    }
                }

                if (lv_distance.Items[r].SubItems.Count < 2)
                    lv_distance.Items[r].SubItems.Add(min.ToString("0.00"));
                else
                    lv_distance.Items[r].SubItems[1].Text = min.ToString("0.00");


                if (lv_distance.Items[r].SubItems.Count < 3)
                    lv_distance.Items[r].SubItems.Add(minIndex.ToString());
                else
                    lv_distance.Items[r].SubItems[2].Text = minIndex.ToString();



                if (min < Commons.Config.distanceThreshold && !detectedVictims.Contains(minIndex))
                {
                    lv_distance.Items[r].BackColor = Color.GreenYellow;
                    detectedVictims.Add(minIndex);
                }
                else
                    lv_distance.Items[r].BackColor = Color.White;

                lb_detectedVictims.Text = detectedVictims.Count.ToString();
            }
            //lv_distance.EndUpdate();            
            
            
        }
    
        


        public void DrawRobot(Graphics g, Robot r)
        {


            int count = r.Location.Count;
            Color drawColor = Color.Black;
            int robotDrawSize;
            if (Commons.Config.Viewer_LeaveTrace)
                robotDrawSize = RobotIndicatorSizeWhileLeavingTrace;
            else
                robotDrawSize = RobotIndicatorSizeWhileNotLeavingTrace;

            for (int i = r.LastLocationIndex; i < count; i++)
            {
                if (!Commons.Config.Viewer_DrawBlack)
                    drawColor = r.DrawColor;
                int xDrawPos = (int)((r.Location[i].X+ (Commons.currentMapWidth / 2))  * (Commons.Config.scaleX / Commons.currentMapWidth) + Commons.Config.dislocateX);
                int yDrawPos = 600 - (int)((r.Location[i].Y+(Commons.currentMapHeight / 2))  * (Commons.Config.scaleY / Commons.currentMapHeight) + Commons.Config.dislocateY);
                switch (r.ItemClass)
                {
                    case "P3AT":
                    case "Kenaf":
                        g.DrawRectangle(new Pen(new SolidBrush(drawColor), robotDrawSize),
                            new Rectangle(xDrawPos, yDrawPos , robotDrawSize, robotDrawSize));
                            break;                    
                    case "AirRobot":
                            g.DrawEllipse(new Pen(new SolidBrush(drawColor), robotDrawSize),
                        new Rectangle(xDrawPos, yDrawPos, robotDrawSize, robotDrawSize));
                        break;
                }
            }
            r.LastLocationIndex = count;

        }
        public void DrawVictims(Graphics g, USARItem v)
        {
            int xDrawPos = (int)((v.Location.X+(Commons.currentMapWidth / 2)) * (Commons.Config.scaleX / Commons.currentMapWidth) + Commons.Config.dislocateX);
            int yDrawPos = 600 - (int)((v.Location.Y + (Commons.currentMapHeight / 2)) * (Commons.Config.scaleY / Commons.currentMapHeight) + Commons.Config.dislocateY);

            g.DrawRectangle(new Pen(new SolidBrush(Color.Red), VictimIndicatorSize),
                new Rectangle(xDrawPos - VictimIndicatorSize / 2,
                    yDrawPos - VictimIndicatorSize / 2,
                    VictimIndicatorSize, VictimIndicatorSize));
        }        


        public void reset()
        {
            //bmp_map_AHA = null;            
            //bmp = null;
            logger_startIndex = 0;
            Commons.World.reset();
            //picViewer.Image = null;
    
            mapDrawnOnBackBuffer = false;
            
            //mainMap = new Bitmap(Commons.Config.Default_Map);            
            backbuffer = new Bitmap(800, 600);            
            backbufferG = Graphics.FromImage(backbuffer);

            firstRobotInitiated = false;
            logLoadSuccess = false;

            manager = null;

            lv_distance.Items.Clear();
        }
        private void timPlay_Tick(object sender, EventArgs e)
        {
            if (201 - Commons.Config.speed > 0)
                timLogDraw.Interval = 201 - Commons.Config.speed;
            else
            {                
                timLogDraw.Interval = 1;
            }
            

            int temp = Commons.World.UpdateWorld(logger_startIndex);
            if (temp == logger_startIndex) //end
            {
                if (!Commons.Config.autoReplay)
                {
                    stopPlayLog();
                }
                else
                {
                    //Clear map
                    backbufferG.DrawImage(mainMap, 0, 0, 800, 600);
                    logger_startIndex = 0;
                }
            }            
            else
                logger_startIndex = temp;
            //List<Robot> robots = Commons.World.getUSARRobots().Values.ToList();
            currentTime = Commons.World.CurrentTime(logger_startIndex);
            if (currentTime <= scroll_logTime.Maximum)
                scroll_logTime.Value = currentTime;
            DrawMap();
        }


        private void timOnlineDraw_Tick(object sender, EventArgs e)
        {
            DrawMap();

            //RetrieveLastRobotPositions();
        }

        private void RetrieveLastRobotPositions()
        {
            List<Robot> robots = Commons.World.getUSARRobots().Values.ToList();
            if (robots.Count > 0)
            {
                txt_lastRobotPositions.Text = "";
                for (int r = 0; r < robots.Count; ++r)
                {
                    txt_lastRobotPositions.Text += robots[r].Name + ":" +
                    robots[r].Location[robots[r].LastLocationIndex - 1].X + "," +
                    robots[r].Location[robots[r].LastLocationIndex - 1].Y + "," +
                        robots[r].Location[robots[r].LastLocationIndex - 1].Z + "," +
                        robots[r].Rotation[robots[r].LastLocationIndex - 1].X + "," +
                        robots[r].Rotation[robots[r].LastLocationIndex - 1].Y + "," +
                        robots[r].Rotation[robots[r].LastLocationIndex - 1].Z + " ";
                }
            }
        }

        private void picViewer_SizeChanged(object sender, EventArgs e)
        {
            //backbuffer = new Bitmap(picViewer.Width, picViewer.Height);
            //forebuffer = new Bitmap(picViewer.Width, picViewer.Height);
            //backbufferG = Graphics.FromImage(backbuffer);
        }

        public void mnuConnet_Click(object sender, EventArgs e)
        {
            reset();
            
            if (String.IsNullOrEmpty(Commons.Config.ServerIp) || Commons.Config.ServerPort == 0)
            {
                MessageBox.Show("Configuration is invalid");
                mnuConfig_Click(null, null);
                return;
            }
            if (txtTeamName.Visible == true)
            {
                MessageBox.Show("Enter Team name.");
                //mnuConfig_Click(null, null);
                return;
            }
            reset();
            //Commons.Config.TeamName = lblTeamName.Text;
            if (string.IsNullOrEmpty(Commons.Config.TeamName))
                Commons.Config.TeamName = "Test";            

            bool isConnecting = mnuConnect.Text.ToLower() == "connet to server";
            //txtTeamName.Enabled = !isConnecting;
            //txtIpAddress.Enabled = !isConnecting;
            //txtPort.Enabled = !isConnecting;

            if (isConnecting)
            {
                manager = new Manager(Commons.Config.ServerIp, Commons.Config.ServerPort,
                    Commons.Config.TeamName);
                try
                {
                    if (manager.connect())
                    {
                        lblLogFileName.Text = manager.FileName;
                        setMessage("Successfully connected to server.", MessageType.Message);

                        mnuStart.Enabled = isConnecting;
                        mnuLoadLog.Enabled = !isConnecting;
                        //btnStop.Enabled = isConnecting;
                        //btnReset.Enabled = isConnecting;

                        manualDraw = false;
                        rb_manualPlay.Enabled = false;
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Connection failed");
                    setMessage("Connection failed.", MessageType.Error);
                    return;
                }

                mnuConnect.Text = "Disconnect from Server";
            }
            else
            {
                if (manager != null)
                    manager.disconnect();
                manager = null;
                setMessage("Successfully disconnected from server.", MessageType.Message);

                rb_manualPlay.Enabled = true;

                mnuConnect.Text = "Connect to server";

            }
            
        }

        
        public void SetEditMapMode(bool state)
        {
            EditMapMode = state;
            if (EditMapMode)
            {

            }
            else
            { }

        }

        private void picViewer_MouseDown(object sender, MouseEventArgs e)
        {
            if (!EditMapMode || IsMouseDown)
                return;
            MouseDownLocation = e.Location;
            MouseDownDrawPointLocation = Commons.Config.Viewer_DrawPoint;
            IsMouseDown = true;
        }

        private void picViewer_MouseMove(object sender, MouseEventArgs e)
        {
            if (EditMapMode && IsMouseDown)
            {
                Commons.Config.Viewer_DrawPoint = new Point(
                    MouseDownDrawPointLocation.X + e.X - MouseDownLocation.X,
                    MouseDownDrawPointLocation.Y + e.Y - MouseDownLocation.Y
                    );

                DrawMap();
            }
        }

        private void picViewer_MouseUp(object sender, MouseEventArgs e)
        {
            IsMouseDown = false;
        }

        public void mnuStart_Click(object sender, EventArgs e)
        {
            mnuStart.Enabled = false;
            mnuConnect.Enabled = false;
            mnuStop.Enabled = true;
            manager.start();
            timTimer.Enabled = true;            
            setMessage("Receiving data from server.", MessageType.Message);

            //AHA
            if (Commons.Config.Viewer_OnlineDraw)
            {
                timOnlineDraw.Start();                
            }
            cb_realTimeDraw.Enabled = false;
            //cb_leaveTrace.Enabled = false;
            //
                        
            
        }

        public void mnuStop_Click(object sender, EventArgs e)
        {
            mnuStart.Enabled = true;
            mnuConnect.Enabled = true;
            mnuStop.Enabled = false;
            manager.stop();
            timTimer.Enabled = false;
            matchStart = false;
            setMessage("Stop Receiving data from server.", MessageType.Warning);
            //AHA
            if (Commons.Config.Viewer_OnlineDraw)
                timOnlineDraw.Stop();
            cb_realTimeDraw.Enabled = true;
            cb_leaveTrace.Enabled = true;
            //
            
        }

        private void setMessage(string message, MessageType type)
        {
            lblMessage.Text = message;
            switch (type)
            {
                case MessageType.Message:
                    lblMessage.ForeColor = Color.Green;
                    break;

                case MessageType.Warning:
                    lblMessage.ForeColor = Color.GreenYellow;
                    break;

                case MessageType.Error:
                    lblMessage.ForeColor = Color.Red;
                    break;
            }

        }
        
        private void timTimer_Tick(object sender, EventArgs e)
        {
            totalTime++;
            if (matchStart)
                matchTime++;
            //lblServerTime.Text = Commons.getTimeString(totalTime);
            lblMatchTime.Text = Commons.getTimeString(matchTime);

            if (manager != null)
                lblLogFileName.Text = manager.FileName + "(" + Commons.getFileSize(manager.FileSize) + ")";
        }
        
        private void loggerToolStripMenuItem_Click(object sender, EventArgs e)
        {

        }

        private void cb_leaveTrace_CheckedChanged(object sender, EventArgs e)
        {
            Commons.Config.Viewer_LeaveTrace = cb_leaveTrace.Checked;
            
        }

        private void cb_realTimeDraw_CheckedChanged(object sender, EventArgs e)
        {
            Commons.Config.Viewer_OnlineDraw = cb_realTimeDraw.Checked;
            
        }

        private void b_matchStart_Click(object sender, EventArgs e)
        {
            matchStart = true;
        }

        private void numUD_X_ValueChanged(object sender, EventArgs e)
        {
            Commons.Config.dislocateX = (int)numUD_X.Value;
            if (mainMap != null)
                backbufferG.DrawImage(mainMap, 0, 0, 800, 600);
        }

        private void numUD_y_ValueChanged(object sender, EventArgs e)
        {
            Commons.Config.dislocateY = (int)numUD_Y.Value;
            if (mainMap != null)
                backbufferG.DrawImage(mainMap, 0, 0, 800, 600);
        }


        private void scroll_logTime_Scroll(object sender, ScrollEventArgs e)
        {
            if (!manualDraw)
            {                
                switchToManualDraw();
            }
            
            currentTime = scroll_logTime.Value;
            //int temp = Commons.World.UpdateWorld(logger_startIndex);
            //logger_startIndex = temp;
            logger_startIndex = Commons.World.UpdateWorkScroll(currentTime);
            DrawMap();            
        }

        private void panel4_Paint(object sender, PaintEventArgs e)
        {

        }

        private void rb_autoPlay_CheckedChanged(object sender, EventArgs e)
        {
            if (rb_autoPlay.Checked)
            {
                //scroll_logTime.Enabled = false;
                switchToAutoPlay();
            }
        }

        private void switchToManualDraw()
        {
            rb_manualPlay.Checked = Enabled;

            b_play.Enabled = false;
            manualDraw = true;
            cb_leaveTrace.Checked = true;
            cb_leaveTrace.Enabled = false;
            mnuPlayLog.Visible = false;
            Commons.Config.Viewer_LeaveTrace = true;
            cb_autoReplay.Enabled = false;

            stopPlayLog();
        }

        private void switchToAutoPlay()
        {
            b_play.Enabled = true;
            manualDraw = false;
            cb_leaveTrace.Enabled = true;
            mnuPlayLog.Visible = true;

            cb_autoReplay.Enabled = true;

            rb_autoPlay.Checked = Enabled;
        }

        private void rb_manualPlay_CheckedChanged(object sender, EventArgs e)
        {
            if (rb_manualPlay.Checked)
            {
                //scroll_logTime.Enabled = true;s
                if (logIsPlaying)
                    stopPlayLog();
                switchToManualDraw();
                
            }
        }

        private void numericUpDown2_ValueChanged(object sender, EventArgs e)
        {
            Commons.Config.scaleX = (int)numUD_scaleX.Value;
            if (mainMap != null)
                backbufferG.DrawImage(mainMap, 0, 0, 800, 600);
        }

        private void numUD_scaleY_ValueChanged(object sender, EventArgs e)
        {
            Commons.Config.scaleY = (int)numUD_scaleY.Value;
            if (mainMap != null)
                backbufferG.DrawImage(mainMap, 0, 0, 800, 600);
        }

        private void txtTeamName_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == '\r')
                saveTeamName();

        }

        private void scroll_speed_Scroll(object sender, ScrollEventArgs e)
        {
            Commons.Config.speed = scroll_speed.Value;

        }

        private void cb_autoReplay_CheckedChanged(object sender, EventArgs e)
        {
            Commons.Config.autoReplay = cb_autoReplay.Checked;
        }

        private void numUD_distanceThreshold_ValueChanged(object sender, EventArgs e)
        {
            Commons.Config.distanceThreshold = (double)numUD_distanceThreshold.Value;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            RetrieveLastRobotPositions();
        }

        





        
    }
}
