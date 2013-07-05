using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using USARSimMetricTool.Location;
using System.Drawing;
using USARSimMetricTool.Common;

namespace USARSimMetricTool.USARSim
{
    public class USARItem
    {
        public string Name { get; set; }
        public string ItemClass { get; set; }
        public string Time { get; set; }
        public Point3D Location { get; set; }
        public Point3D Rotation { get; set; }
        public bool LocationChanged { get; set; }

        public USARItem()
        {
            //if (ItemClass == Commons.USAR_ITEM_CLASS_ROBOT_P3AT)
            //{
            //    Random r = new Random();
            //    color = Color.FromArgb(r.Next());
            //}
            //else if (ItemClass == Commons.USAR_ITEM_CLASS_MaleVictim ||
            //    ItemClass == Commons.USAR_ITEM_CLASS_FemaleVictim)
            //{
            //    color = Color.Red;
            //}   

        }

        const float Scale = 13.3f;
        //private float Scale = 20;
        public bool parse(string command)
        {
            //string[] splited = Regex.Split(commad, "\\{Name (.*)\\} \\{Class (.*)\\} \\{Time (?:.*)\\} \\{Location (.*),(.*),(.*)\\} \\{Rotation (.*),(.*),(.*)\\}");
            if (command!=null && command.Length < 39)
                return false;
            try
            {
                string[] splited = Regex.Split(command, "\\{Name (.*)\\} \\{Class (.*)\\} \\{Time (.*)\\} \\{Location (.*),(.*),(.*)\\} \\{Rotation (.*),(.*),(.*)\\}");
                if (splited.Length < 10)
                    return false;
                int count = splited.Length;
                Name = splited[1];
                ItemClass = splited[2];
                Time = splited[3];
                //float w = Commons.Config.getMapConfig(Commons.CurrentMapName).MapWidth;
                //float h = Commons.Config.getMapConfig(Commons.CurrentMapName).MapHeight;
                Location = new Point3D();
                Location.X = float.Parse(splited[5]);// +(Commons.currentMapWidth / 2);
                 //* (Commons.Config.scaleX / Commons.currentMapWidth) + Commons.Config.dislocateX; //AHA +20
                Location.Y = float.Parse(splited[4]);// +(Commons.currentMapHeight / 2);
                // * (Commons.Config.scaleY / Commons.currentMapHeight)) + Commons.Config.dislocateY;//AHA -20
                Location.Z = float.Parse(splited[6]);

                //AHA
                //if (Location.X > 795)
                //    Location.X = 795;
                //else if (Location.X < 5)
                //    Location.X = 5;

                //if (Location.Y > 595)
                //    Location.Y = 595;
                //else if (Location.Y < 5)
                //    Location.Y = 5;
                //

                Rotation = new Point3D();
                Rotation.X = float.Parse(splited[7]);
                Rotation.Y = float.Parse(splited[8]);
                Rotation.Z = float.Parse(splited[9]);


            }
            catch
            { return false; }
            return true;
        }
    }
}
