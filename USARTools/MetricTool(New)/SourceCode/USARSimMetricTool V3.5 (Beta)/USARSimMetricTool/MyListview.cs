using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace USARSimMetricTool
{
    public class MyListView : ListView
    {
        public MyListView()
            : base()
        {
            DoubleBuffered = true;
        }
    }
}
