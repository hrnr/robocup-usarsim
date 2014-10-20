﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using USARSimMetricTool.Common;

namespace USARSimMetricTool
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Commons.Config = Configuration.LoadConfig();
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new frmViewer());
        }
    }
}