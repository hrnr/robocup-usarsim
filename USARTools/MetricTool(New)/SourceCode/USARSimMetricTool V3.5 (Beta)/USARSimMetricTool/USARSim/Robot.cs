using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using USARSimMetricTool.Location;
using System.Drawing;
using USARSimMetricTool.Common;

namespace USARSimMetricTool.USARSim
{
    public class Robot
    {
        public string Name { get; set; }
        public string ItemClass { get; set; }
        public string Time { get; set; }
        public List<Point3D> Location { get; set; }
        public List<string> LocationTime { get; set; }
        public List<Point3D> Rotation { get; set; }
        public Color DrawColor { get; set; }
        public int LastLocationIndex = 0;
        
        public Robot()
        {
            Location = new List<Point3D>();
            LocationTime = new List<string>();
            Rotation = new List<Point3D>();
        }
        public Robot(USARItem usarItem, int colorIndex):this()
        {
            Name = usarItem.Name;
            ItemClass = usarItem.ItemClass;
            Time = usarItem.Time;

            Location.Add(usarItem.Location);
            LocationTime.Add(usarItem.Time);
            Rotation.Add(usarItem.Rotation);
            DrawColor = Commons.DEFAULT_COLORS[colorIndex];
        }
        public void update(USARItem usarItem)
        {
            Location.Add(usarItem.Location);
            LocationTime.Add(usarItem.Time);
            Rotation.Add(usarItem.Rotation);
            Time = usarItem.Time;
        }
    }
}
