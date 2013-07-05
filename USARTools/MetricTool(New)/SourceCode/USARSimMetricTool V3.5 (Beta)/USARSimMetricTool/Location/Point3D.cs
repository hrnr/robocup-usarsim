using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace USARSimMetricTool.Location
{
    public class Point3D
    {
        public float X { get; set; }
        public float Y { get; set; }
        public float Z { get; set; }

        public double Distance(Point3D p)
        {
            float t = (X - p.X) * (X - p.X) +
                (Y - p.Y) * (Y - p.Y) +
                (Z - p.Z) * (Z - p.Z);
            return Math.Sqrt(t);
        }
    }
}
