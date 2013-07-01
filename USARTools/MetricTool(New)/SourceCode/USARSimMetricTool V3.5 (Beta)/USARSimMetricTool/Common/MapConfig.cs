using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;

namespace USARSimMetricTool.Common
{
    [Serializable()]
    public class MapConfig
    {
        public MapConfig()
        {
        }
        public MapConfig(string mapName)
        {
            this.MapName = mapName;
        }
        public string MapName { get; set; }
        public string MapFullPath { get; set; }
        public int MapWidth { get; set; }
        public int MapHeight { get; set; }
        public Point DrawPoint { get; set; }

    }
}
