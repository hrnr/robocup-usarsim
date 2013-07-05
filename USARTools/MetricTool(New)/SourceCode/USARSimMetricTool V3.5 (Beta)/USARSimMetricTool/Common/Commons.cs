using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using USARSimMetricTool.USARSim;
using System.IO;
using System.Drawing;
using System.Xml.Serialization;

namespace USARSimMetricTool.Common
{
    public enum MessageType
    {
        Message = 1,
        Warning = 2,
        Error = 3
    }
    public class Commons
    {
        //static data only for fast proccess
        public static float currentMapHeight;
        public static float currentMapWidth;

        public static Random rand = new Random(Environment.TickCount);
        public static frmViewer Form_Viewer { get; set; }
        
        public static string CurrentMapName = "";
        
        public const string USAR_ITEM_CLASS_MaleVictim = "MaleVictim";
        public const string USAR_ITEM_CLASS_FemaleVictim = "FemaleVictim";
        public const string USAR_ITEM_CLASS_UTPawn = "MaleVictim";

        public const string USAR_ITEM_CLASS_ROBOT_P3AT = "P3AT";
        public const string USAR_ITEM_CLASS_ROBOT_AirRobot = "AirRobot";
        public const string USAR_ITEM_CLASS_ROBOT_Kenaf = "Kenaf";
        public static List<Color> DEFAULT_COLORS = new List<Color>() {  
            Color.Black, Color.Salmon, Color.Brown, 
            Color.Blue,Color.Indigo,Color.Gold, Color.DarkKhaki, 
            Color.Red, Color.Tan, Color.Turquoise, Color.DeepSkyBlue
        };
        public static int getRandom()
        {
            return rand.Next();
        }
        public static string getTimeString(int totalSec)
        {
            TimeSpan t = new TimeSpan(0, 0, totalSec);
            return
                //(t.Hours < 10 ? "0" + t.Hours.ToString() : t.Hours.ToString()) + ":" +
             (t.Minutes < 10 ? "0" + t.Minutes.ToString() : t.Minutes.ToString()) + ":" +
           (t.Seconds < 10 ? "0" + t.Seconds.ToString() : t.Seconds.ToString());


        }
        public static string getFileSize(long size)
        {
            string result = "";
            double temp = (double)size;
            int i = 0;
            while (temp > 1024)
            {
                temp = temp / 1024;
                i++;
            }
            result = temp.ToString("0.00");
            switch (i)
            {
                case 0:
                    result += "b";
                    break;

                case 1:
                    result += "KB";
                    break;

                case 2:
                    result += "MB";
                    break;

                case 3:
                    result += "GB";
                    break;
            }
            return result;
        }

        public static Configuration Config { get; set; }

        public static class World
        {
            public static List<USARItem> AllData = new List<USARItem>();
            private static Dictionary<string, Robot> Robots = new Dictionary<string, Robot>();
            private static Dictionary<string, USARItem> Victims = new Dictionary<string, USARItem>();


            public static void reset()
            {
                Robots.Clear();
                Victims.Clear();
                AllData.Clear();
            }
            public static int UpdateWorld(int startIndex)
            {
                string time = "";
                if (startIndex >= AllData.Count)
                    return startIndex;
                time = AllData[startIndex].Time;
                int count = AllData.Count;
                do
                {
                    AddUSARItem(AllData[startIndex]);
                    startIndex++;
                }
                while (startIndex < count && time == AllData[startIndex].Time);
                return startIndex;

            }

            public static int UpdateWorkScroll(int destTime)
            {
                ClearRobotsVictims();                
                int index = 0;
                if (index >= AllData.Count)
                    return index;
                while ((int)float.Parse(AllData[index].Time) <= destTime)
                {
                    AddUSARItem(AllData[index]);
                    index++;
                }
                return index;
            }

            private static void ClearRobotsVictims()
            {
                Robots.Clear();
                Victims.Clear();
            }

            public static int FinalTime()
            {
                return (int)float.Parse(AllData[AllData.Count - 1].Time);
            }

            public static int CurrentTime(int startIndex)
            {
                if (AllData.Count > 0)
                {
                    if (startIndex >= AllData.Count)
                        return AllData.Count;
                    return (int)float.Parse(AllData[startIndex].Time);
                }
                else
                    return 0;
            }


            //public static void UpdateWorld()
            //{
            //    int count = AllData.Count;
            //    for (int i = 0; i < AllData.Count; i++)
            //        AddUSARItem(AllData[i]);
            //}
            public static void AddUSARItem(USARItem usarItem)
            {
                switch (usarItem.ItemClass)
                {
                    case USAR_ITEM_CLASS_FemaleVictim:
                    case USAR_ITEM_CLASS_MaleVictim:
                        if (!Victims.ContainsKey(usarItem.Name))
                            Victims.Add(usarItem.Name, usarItem);
                        else if (Victims[usarItem.Name].Location != usarItem.Location)
                            Victims[usarItem.Name].Location = usarItem.Location;
                        break;
                    case USAR_ITEM_CLASS_ROBOT_P3AT:
                    case USAR_ITEM_CLASS_ROBOT_AirRobot:
                    case USAR_ITEM_CLASS_ROBOT_Kenaf:
                        if (!Robots.ContainsKey(usarItem.Name))
                            Robots.Add(usarItem.Name, new Robot(usarItem, Robots.Count));
                        Robot r = Robots[usarItem.Name];
                        if (r.Location[r.Location.Count-1] != usarItem.Location)
                        {                            
                            r.update(usarItem);
                        }
                        break;
                }
            }

            public static Dictionary<string, Robot> getUSARRobots()
            {
                return Robots;
            }
            public static Dictionary<string, USARItem> getUSARVictims()
            {
                return Victims;
            }
            public static bool LoadFromFile(string fileName)
            {
                try
                {
                    FileStream fs = new FileStream(fileName, FileMode.Open);
                    StreamReader sr = new StreamReader(fs);
                    string line = "";
                    do
                    {
                        line = sr.ReadLine();
                        USARItem uitem = new USARItem();
                        if (uitem.parse(line))
                            AllData.Add(uitem);
                    } while (!sr.EndOfStream);
                    sr.Close();
                    fs.Close();
                    sr = null;
                    fs = null;
                    return true;
                }
                catch (FileNotFoundException e)
                {
                    return false;
                }


                
            }
        }
    }
}
