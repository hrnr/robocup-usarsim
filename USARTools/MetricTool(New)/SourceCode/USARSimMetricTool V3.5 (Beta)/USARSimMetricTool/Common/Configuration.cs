using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;
using System.Xml.Serialization;
using System.IO;

namespace USARSimMetricTool.Common
{
    public class Configuration
    {
        public int dislocateX { get; set; }
        public int dislocateY { get; set; }
        public int scaleX { get; set; }
        public int scaleY { get; set; }
        public int speed { get; set; }
        public bool autoReplay { get; set; }
        public double distanceThreshold { get; set; }

        public string ServerIp { get; set; }
        public int ServerPort { get; set; }
        public string TeamName { get; set; }
        public bool Viewer_DrawBlack { get; set; }
        public bool Viewer_LeaveTrace { get; set; }
        public bool Viewer_OnlineDraw { get; set; }
        public Point Viewer_DrawPoint { get; set; }
        public Size Viewer_Size { get; set; }
        public Point Viewer_Location { get; set; }
        public Point Controller_Location { get; set; }
        public List<MapConfig> mapConfigs = new List<MapConfig>();
        public Size Drawer_Size { get; set; }
        
        //public string Default_Map { get; set; }
        private MapConfig currentMapConfig = null;

        public MapConfig getMapConfig(string mapName)
        {
            if (currentMapConfig != null && currentMapConfig.MapName == mapName)
                return currentMapConfig;
            currentMapConfig = null;
            for (int i = 0; i < mapConfigs.Count; i++)
            {
                if (mapConfigs[i].MapName == mapName)
                    currentMapConfig = mapConfigs[i];
            }
            return currentMapConfig;
        }
        public void removeMapConfig(string mapName)
        {
            for (int i = 0; i < mapConfigs.Count; i++)
            {
                if (mapConfigs[i].MapName == mapName)
                {
                    mapConfigs.RemoveAt(i);
                    return;
                }
            }
        }
        public bool addMapConfig(string mapName)
        {
            bool exists = false;
            for (int i = 0; i < mapConfigs.Count; i++)
            {
                if (mapConfigs[i].MapName == mapName)
                { exists = true; 
                    break; }
            }
            if (!exists)
                mapConfigs.Add(new MapConfig(mapName));
            return !exists;
        }
        public Configuration()
        {
            //MapHeight = 600;
            //MapWidth = 800;
            Viewer_DrawBlack = false;
            //mapConfig.Add("salam", "dasda");
        }
        public void SaveConfig()
        {
            MemoryStream ms = new MemoryStream();
            XmlSerializer serializer = new XmlSerializer(this.GetType());
            serializer.Serialize(ms, this);
            ms.Position = 0;
            StreamWriter sr = new StreamWriter("Config.cfg");
            byte[] buffer = new byte[ms.Length];
            ms.Read(buffer, 0, buffer.Length);
            string result = System.Text.Encoding.UTF8.GetString(buffer);
            sr.Write(result);
            sr.Flush();
            sr.Close();
        }
        public static Configuration LoadConfig()
        {
            if (!File.Exists("Config.cfg"))
                return new Configuration();
            FileStream fs = new FileStream("Config.cfg", FileMode.Open);
            XmlSerializer serializer = new XmlSerializer(typeof(Configuration));
            Configuration config = (Configuration)serializer.Deserialize(fs);

            fs.Close();
            fs = null;
            serializer = null;
            return config;
        }

        
    }
}
