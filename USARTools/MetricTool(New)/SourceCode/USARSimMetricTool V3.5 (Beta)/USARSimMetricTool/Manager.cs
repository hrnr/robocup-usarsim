using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using USARSimMetricTool.Network;
using System.IO;
using USARSimMetricTool.USARSim;
using USARSimMetricTool.Common;

namespace USARSimMetricTool
{
    public class Manager
    {
        private Communication com;
        private string fileName;
        private StreamWriter sw;
        private volatile bool isAlive = false;

        public string FileName { get { return fileName; } }
        public long FileSize { get {
            if (sw == null || sw.BaseStream==null)
                return 0;
            return sw.BaseStream.Length; } }
        public Manager(string host, int port, string teamName)
        {
            com = new Communication(host, port);
            fileName = teamName + "-" + DateTime.Now.ToString("yyy-MM-d_HH-mm-ss") + ".txt";
            sw = new StreamWriter(fileName, true);
        }
        public bool connect()
        {
            return com.connect();
        }
        public void disconnect()
        {
            com.disconnect();
        }
        public void start()
        {
            if (isAlive)
                return;
            isAlive = true;
            Thread thread = new Thread(new ThreadStart(begin));
            thread.IsBackground = true;
            thread.Start();
        }
        private void begin()
        {
            while (isAlive)
            {
                try
                {
                    string result = com.sendAndReceive("");
                    if (!isAlive)
                        return;
                    sw.Write(result + Environment.NewLine);
                    sw.Flush();
                    USARItems uitems = new USARItems();
                    
                    uitems.parse(result);
                    int count = uitems.items.Count;
                    for (int i = 0; i < count; i++)
                    {
                        Commons.World.AddUSARItem(uitems.items[i]);                        
                    }
                    
                }
                catch { }
            }
        }
        public void stop()
        {
            isAlive = false;
           // sr.Close();
            if (sw != null && sw.BaseStream != null)
            {
                sw.Flush();
                sw.Close();
            }
            
        }
    }
}
