using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using USARSimMetricTool.Common;

namespace USARSimMetricTool
{
    public partial class frmConfig : Form
    {
        public frmConfig()
        {
            InitializeComponent();
        }

        private void btnSave_Click(object sender, EventArgs e)
        {
            Commons.Config.ServerIp = txtIpAddress.Text;
            Commons.Config.ServerPort = int.Parse(txtPort.Text);
            if (txtMapWidth.Enabled)
            {
                Commons.Config.getMapConfig(Commons.CurrentMapName).MapHeight = int.Parse(txtMapHeight.Text);
                Commons.Config.getMapConfig(Commons.CurrentMapName).MapWidth = int.Parse(txtMapWidth.Text);
                //AHA
                Commons.currentMapWidth = Commons.Config.getMapConfig(Commons.CurrentMapName).MapWidth;
                Commons.currentMapHeight = Commons.Config.getMapConfig(Commons.CurrentMapName).MapHeight;
            }
            Close();
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void frmConfig_Load(object sender, EventArgs e)
        {
            txtIpAddress.Text = Commons.Config.ServerIp;
            txtPort.Text = Commons.Config.ServerPort.ToString();
            txtIpAddress.Focus();
            if (string.IsNullOrEmpty(Commons.CurrentMapName)
              || Commons.Config.getMapConfig(Commons.CurrentMapName) == null)
            {
                txtMapHeight.Enabled = false;
                txtMapWidth.Enabled = false;
            }
            else
            {
                txtMapHeight.Text = Commons.Config.getMapConfig(Commons.CurrentMapName).MapHeight.ToString();
                txtMapWidth.Text = Commons.Config.getMapConfig(Commons.CurrentMapName).MapWidth.ToString();
            }
          
        }
    }
}
