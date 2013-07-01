using System;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Windows.Forms;

namespace USARSimMetricTool.Network
{
    public class Communication
    {
        private const int RECEIVE_TIMEOUT = 4000;

        private string ip;
        private int port;
        private Socket connection;
        private NetworkStream networkStream = null;

        public Communication(string host, int port)
        {
            this.ip = host;
            this.port = port;


        }
        public bool connect()
        {
            connection = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            //try
            //{
            connection.Connect(ip, port);
            //}
            //catch (Exception e)
            //{
            //    MessageBox.Show("Server is not available on this port.");
            //    return false;
            //}
            networkStream = new NetworkStream(connection);
            getAvalibleData();
            return true;
        }
        public string sendAndReceive(string cmd)
        {
            if (networkStream == null)
                return "";

            try
            {
                //string s = getAvalibleData();
                cmd += Environment.NewLine;

                byte[] buffer = Encoding.ASCII.GetBytes(cmd);
                networkStream.Write(buffer, 0, buffer.Length);
                networkStream.Flush();

                buffer = new byte[512];
                networkStream.ReadTimeout = RECEIVE_TIMEOUT;

                while (!networkStream.DataAvailable) { Thread.Sleep(0); }

                int numreads = 0;
                int bytesCount = connection.Available;

                if (buffer.Length != bytesCount)
                    buffer = new byte[bytesCount];
                string response = "";
                try
                {
                    while (numreads < bytesCount)
                    {
                        networkStream.ReadTimeout = RECEIVE_TIMEOUT;
                        numreads += networkStream.Read(buffer, numreads, bytesCount - numreads);

                        response += Encoding.ASCII.GetString(buffer, 0, buffer.Length);
                        buffer = new byte[bytesCount];
                        if (numreads < bytesCount)
                            break;
                        numreads = 0;
                        Thread.Sleep(0);
                    }
                }
                catch { }

                return response;
            }
            catch (Exception e) { return e.ToString(); }

        }
        public void sendCommand(string cmd)
        {
            if (networkStream == null)
                return;
            try
            {
                cmd += Environment.NewLine;

                byte[] buffer = Encoding.ASCII.GetBytes(cmd);
                networkStream.Write(buffer, 0, buffer.Length);
                networkStream.Flush();
            }
            catch { return; }
        }
        public string getAvalibleData()
        {
            Thread.Sleep(50);

            if (networkStream == null)
                return "";
            if (!networkStream.DataAvailable)
                return "";

            try
            {
                byte[] buffer = new byte[1024];
                networkStream.ReadTimeout = RECEIVE_TIMEOUT;
                string response = "";
                while (networkStream.DataAvailable)
                {
                    int len = networkStream.Read(buffer, 0, buffer.Length);
                    response += Encoding.ASCII.GetString(buffer, 0, len);
                }
                return response;
            }
            catch { return ""; }
        }

        public void disconnect()
        {
            try
            {
                connection.Disconnect(false);
                connection.Dispose();
            }
            catch { }
        }
    }
}
