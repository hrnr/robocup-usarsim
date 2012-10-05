using System;
using System.IO;
using System.Drawing;
using System.Collections.Specialized;

using LCM.LCM;
using LCMTypes;

using UvARescue.Tools;

namespace LCM.Proxy
{
    
    class UsarBot
    {

        /// <summary>
        /// program makes a connection to USARSim, spawns a UsarBot and publishes the sensor data on lcm-channels
        /// </summary>
        public static void Main(string[] args)
        {

            ArgsParser parser = new ArgsParser();

            parser.AddValueArg("h", "host", "ip-adress of host where USARSim is running", "127.0.0.1");
            
            parser.AddValueArg("t", "type", "the type of this robot", "P3AT");
            parser.AddValueArg("n", "name", "the name of this robot", "Robot1");

            parser.AddValueArg("l", "location", "the location where the robot is spawned", "-5.4734,27.8247,1.4720"); // {Level RoboCup2012-Tryout}
            parser.AddValueArg("r", "rotation", "the rotation of the robot when spawned", "0.0000,0.0000,-3.4361");

            parser.AddValueArg("v", "viewport", "the tile of the robots' camera in multiview (upperleft=1,2=totheright)", "1");
            parser.AddValueArg("w", "2nd viewport", "the tile of the robots' 2nd camera in multiview (none=0,upperleft=1,2=totheright)", "0");
            parser.AddValueArg("x", "CameraTileX", "the number of columns of multiview (typically 1,2,3)", "2");
                                
            StringDictionary values = null;
            StringCollection msgs = null;

            if (!parser.Parse(args, ref values, ref msgs))
            {

                Console.WriteLine("Invalid Arguments, error while parsing");
                foreach (String msg in msgs)
                {
                    Console.WriteLine("- " + msg);
                }
                Console.WriteLine();

                parser.PrintHelp(Console.Out);

                return;
            }

            RobotType = values["t"];

            FirstViewPort = int.Parse(values["v"]);
            SecondViewPort = int.Parse(values["w"]);
            MultiViewColumns = int.Parse(values["x"]);


            TcpMessagingConnection usarSimConnection = new TcpMessagingConnection();

            usarSimConnection.Connect(values["h"], 3000);
            
            if (!usarSimConnection.IsConnected)
            {
                Console.WriteLine("Please start USARSim at machine " + values["h"] + ":" + 3000);
                return;
            }
            else
            {
                Console.WriteLine("Connected to USARSim at machine " + values["h"] + ":" + 3000);
                usarSimConnection.Send("INIT {ClassName USARBot." + values["t"] + "} {Name " + values["n"] + "} {Location " + values["l"] + "} {Rotation " + values["r"] + "}" + System.Environment.NewLine); // {Level RoboCup2012-Tryout}
            }

            //LCM.LCM myLCM = LCM.LCM.Singleton;
            LCM.LCM myLCM = new LCM.LCM("udpm://239.255.76.67:7667?ttl=1"); // udpm have group addresses reserved in the range 224.0.0.0 to 239.255.255.255. TTL restricts the messages to be send in the same subnet.

            SimpleSubscriber sub = new SimpleSubscriber(usarSimConnection);
            myLCM.SubscribeAll(sub);

            TcpCameraConnection imageServerConnection = new TcpCameraConnection();

            imageServerConnection.Connect(values["h"], 5003);

            if (!imageServerConnection.IsConnected)
            {
                Console.WriteLine("Please start ImageServer at machine " + values["h"] + ":" + 5003);
                return;
            }
            else
            {
                Console.WriteLine("Connected to ImageServer at machine " + values["h"] + ":" + 5003);
                imageServerConnection.SendAcknowledgement(); // needed if legacyMode=false
            }

            _lastImage = DateTime.Now.Ticks / 10;

            while (true)
            {

                if (imageServerConnection.DataAvailable)
                {
                    handleImageData(imageServerConnection, myLCM);
                }


                if (usarSimConnection.DataAvailable)
                {
                    handleSensorData(usarSimConnection, myLCM);
                }
            }
        }

        /// <summary>
        /// Receive images from USARSim and publish them on the CAMERA lcm-channel
        /// </summary>
        /// <param name="usarSimConnection">tcp socket connection to the ImageServer</param>
        /// <param name="myLCM">udpm connection used for broadcast</param>
        private static void handleImageData(TcpCameraConnection imageServerConnection, LCM.LCM myLCM)
        {
        if (imageServerConnection.DataAvailable)
                {


                    long measuredTime = DateTime.Now.Ticks / 10;
                    int bytes_length;
                    byte[] bytes = new byte[320 * 240 * 3 + 10];
                    bytes = imageServerConnection.ReceiveImageData(320 * 240 * 3 + 10);


                    if (bytes == null || bytes.Length <= 5)
                    {
                        return;
                    }
                    //Console.Out.WriteLine("ReceiveImageData: " + bytes.Length + " bytes");

                    int pixelformat = 0; // raw
                    if (bytes[0] == 0)
                    {
                        pixelformat = 859981650; // rgb from lcm/image_t_utils
                    }
                    else
                    {
                        pixelformat = 1196444237; // jpeg from lcm/image_t_utils

                    }

                    bytes_length = ((bytes[1] * (int)Math.Pow(2, 24)) + (bytes[2] * (int)Math.Pow(2, 16)) + (bytes[3] * (int)Math.Pow(2, 8)) + (bytes[4] * (int)Math.Pow(2, 0)));
                    //Console.Out.WriteLine("ImageSize according to heather: " + bytes_length + " bytes");

                    try
                    {
                        image_t temp = new image_t();
                        temp.utime = measuredTime;
                        temp.pixelformat = pixelformat;

                        image_t secondimage = new image_t();
                        secondimage.utime = measuredTime;
                        secondimage.pixelformat = pixelformat;

                        if (pixelformat == 1196444237) // jpeg
                        {
                                // from example-code http://stackoverflow.com/questions/10661967/saving-as-jpeg-from-memorystream-in-c-sharp
                                byte[] jpeg = new byte[bytes_length];
                                System.Buffer.BlockCopy(bytes, 5, jpeg, 0, jpeg.Length);
                                System.IO.MemoryStream streamIn = new System.IO.MemoryStream(jpeg);

                                using (var original = Image.FromStream(streamIn))
                                using (var subview = GetSubView(original, FirstViewPort, MultiViewColumns))
                                using (var resized = ResizeWithSameRatio(subview, 400, 300))
                                using (var anothersubview = GetSubView(original, SecondViewPort, MultiViewColumns))
                                using (var anotherresized = ResizeWithSameRatio(anothersubview, 400, 300))                                        
                                {
                                    if (true)
                                    {
                                        // Converting it back to bytes
                                        // http://stackoverflow.com/questions/268013/how-do-i-convert-a-bitmap-to-byte
                                        System.IO.MemoryStream streamOut = new System.IO.MemoryStream();
                                        resized.Save(streamOut, System.Drawing.Imaging.ImageFormat.Jpeg);
                                        //original.Save(streamOut, System.Drawing.Imaging.ImageFormat.Jpeg);
                                        streamOut.Position = 0;
                                        temp.image = new byte[streamOut.Length];
                                        // from http://msdn.microsoft.com/en-us/library/system.io.memorystream.aspx
                                        streamOut.Read(temp.image, 0, (int)(streamOut.Length - 1));
                                        temp.size = (int)streamOut.Length;

                                        temp.width = 400;
                                        temp.height = 300;
                                        temp.stride = 1;

                                        if (temp != null)
                                        {
                                            myLCM.Publish("CAMERA", temp);
                                        }

                                    }

                                    if ((SecondViewPort > 0))
                                    {
                                                                                 
                                            
                                            System.IO.MemoryStream anotherstreamOut = new System.IO.MemoryStream();
                                            anotherresized.Save(anotherstreamOut, System.Drawing.Imaging.ImageFormat.Jpeg);
                                            //original.Save(streamOut, System.Drawing.Imaging.ImageFormat.Jpeg);
                                            anotherstreamOut.Position = 0;
                                            secondimage.image = new byte[anotherstreamOut.Length];
                                            // from http://msdn.microsoft.com/en-us/library/system.io.memorystream.aspx
                                            anotherstreamOut.Read(secondimage.image, 0, (int)(anotherstreamOut.Length - 1));
                                            secondimage.size = (int)anotherstreamOut.Length;

                                            secondimage.width = 400;
                                            secondimage.height = 300;
                                            secondimage.stride = 1;

                                            if (secondimage != null && RobotType == "Kenaf")
                                            {
                                                myLCM.Publish("FISHEYE", secondimage);
                                            }
                                            if (secondimage != null && RobotType == "Nao")
                                            {
                                                myLCM.Publish("CameraBottom", secondimage);
                                            }
                                                                                                                       
                                    }
                                }
                        }
                        else // raw
                        { 

                            temp.width = (short )((bytes[5] * (int)Math.Pow(2, 8)) + (bytes[6] * (int)Math.Pow(2, 0)));
                            temp.height = (short )((bytes[7] * (int)Math.Pow(2, 8)) + (bytes[8] * (int)Math.Pow(2, 0)));
                            temp.stride = 1;

                            //Console.Out.WriteLine("Image dimensions according to heather: " + temp.width + "x" + temp.height + " pixels");

                            temp.size = bytes_length - 4;
                            temp.image = new byte[temp.size];
                            for (int i = 0; i < temp.size - 1; i++)
                            {
                                temp.image[i] = bytes[i + 9]; // heather: picturetype (1), size (4), dimension (4)
                            }

                            if (temp != null)
                            {
                                myLCM.Publish("CAMERA", temp);
                            }
                                                        
                        }

                        imageServerConnection.SendAcknowledgement();

                        System.Threading.Thread.Sleep(200);
                    }
                    catch (Exception ex)
                    {
                        Console.Error.WriteLine("Ex: " + ex);
                        imageServerConnection.SendAcknowledgement();
                    }
                }
                else
                {
                    var delay = (DateTime.Now.Ticks / 10) - _lastImage;
                    if (delay > 2000000) // no update for 2000 ms 
                    {
                        if (!imageServerConnection.IsConnected)
                        {
                            imageServerConnection.SendAcknowledgement();
                            Console.Error.WriteLine("Warning: Requested another image after delay of " + delay / 1000 + " ms.");
                            _lastImage = (DateTime.Now.Ticks / 10);
                        }
                    }
                }
        }
        /// <summary>
        /// Receive sensor messages from USARSim and publish them on the POSE and LASER lcm-channel
        /// </summary>
        /// <param name="usarSimConnection">tcp socket connection to USARSim</param>
        /// <param name="myLCM">udpm connection used for broadcast</param>
        private static void handleSensorData(TcpMessagingConnection usarSimConnection, LCM.LCM myLCM)
        {
            StringCollection msgs = usarSimConnection.ReceiveMessages(4096);

                    foreach (String msg in msgs)
                    {
                        if (msg.Contains("{Type RangeScanner}"))
                        {
                            // 'SEN {Time double} {Type RangeScanner} {Name Scanner1} {Resolution 0.0174} {FOV 3.1415} {Range <doubles>}

                            long measuredTime = DateTime.Now.Ticks / 10; // this are the variables we have to extract
                            
                            int nbeams = 228; // Hokuyo: 228 beams, SICK: 181 beams
                            float resolution = (float)(Math.PI / nbeams);
                            float fov = (float)(resolution * nbeams);

                            float[] beams = new float[nbeams];
                            for (int b = 0; b < nbeams; b++)
                            {
                                beams[b] = (float)(25.0 + 5 * Math.Sin(DateTime.Now.Ticks / 10000000.0));
                            }

                            //then extract all curly-braced parts
                            int j = msg.IndexOf(" ");
                            int i = msg.IndexOf("{", j);
                            while (i >= 0)
                            {
                                j = msg.IndexOf("}", i);
                                if (j >= 0)
                                {
                                    String part = msg.Substring(i + 1, j - i - 1);

                                    if (part.Contains("Time"))
                                    {
                                        int v = part.IndexOf(" ");
                                        double seconds = double.Parse(part.Substring(v + 1, part.Length - v - 1));
                                        measuredTime = (long)(seconds * 1000000); // lcm expects measuredtime in microseconds
                                    }

                                    if (part.Contains("Resolution"))
                                    {
                                        int v = part.IndexOf(" ");
                                        resolution = float.Parse(part.Substring(v + 1, part.Length - v - 1));
                                    }

                                    if (part.Contains("FOV"))
                                    {
                                        int v = part.IndexOf(" ");
                                        fov = float.Parse(part.Substring(v + 1, part.Length - v - 1));
                                    }

                                    if (part.StartsWith("Range")) // RangeScanner also contains Range
                                    {
                                        int v = part.IndexOf(" ");
                                        int w = part.IndexOf(",", v);

                                        nbeams = (int)(fov / resolution) + 1;

                                        for (int b = 0; b < nbeams; b++)
                                        {
                                            beams[b] = float.Parse(part.Substring(v + 1, w - v - 1));
                                            v = part.IndexOf(",", w);
                                            w = part.IndexOf(",", v + 1);
                                            if (w < 0)
                                            {
                                                w = part.Length;
                                            }
                                        }

                                    }


                                    i = msg.IndexOf("{", j);
                                }
                                else
                                {
                                    // done
                                    break;
                                } // End If
                            } // End While

                            try
                            {
                                laser_t temp = new laser_t();
                                temp.utime = measuredTime;


                                temp.rad0 = (float)(-fov / 2); // SICK; -90 deg 
                                temp.nranges = nbeams; // SICK; 181 beams
                                temp.radstep = resolution;

                                temp.ranges = new float[temp.nranges];
                                for (int l = 0; l < temp.nranges; l++)
                                {
                                    temp.ranges[l] = beams[l];
                                }

                                myLCM.Publish("LASER", temp); // channel according to intel.conf

                                System.Threading.Thread.Sleep(200);
                            }
                            catch (Exception ex)
                            {
                                Console.Error.WriteLine("Ex: " + ex);
                            }
                        } // end if (msg.StartsWith("SEN {Type RangeScanner}")

                        //////////////////////////////////////////////////////////////////////////////////////////////////////

                        if (msg.Contains("{Type INS}") || msg.Contains("{Type IMU}") || msg.Contains("{Type AcceleroMeter}"))
                        {
                            // 'SEN {Type INS} {Name InsTest} {Location -5.47,27.82,1.27} {Orientation 0.00,0.00,2.85}
                            long measuredTime = DateTime.Now.Ticks / 10; // No Time for INS!
                            double[] location = new double[3];
                            double[] acceleration = new double[3];
                            double[] orientation = new double[3];
                            double[] quaternion = new double[4];
                            double[] angular_vel = new double[3];
                            //double[] angular_acc = new double[3]; // published by IMU, but no angular_acc defined in pose_t

                            for (int d = 0; d < 3; d++)
                            {
                                location[d] = (double)(1.00 + d / 100);
                            }
                            for (int d = 0; d < 3; d++)
                            {
                                acceleration[d] = (double)(1.00 + d / 100);
                            }
                            for (int d = 0; d < 3; d++)
                            {
                                orientation[d] = (double)(0.00 + d / 100);
                            }
                            quaternion = rollPitchYawToQuat(orientation);
                            for (int d = 0; d < 3; d++)
                            {
                                angular_vel[d] = (double)(0.00 + d / 100);
                            }
                            //for (int d = 0; d < 3; d++)
                            //{
                            //    angular_acc[d] = (double)(0.00 + d / 100);
                            //}

                            //then extract all curly-braced parts
                            int j = msg.IndexOf(" ");
                            int i = msg.IndexOf("{", j);
                            while (i >= 0)
                            {
                                j = msg.IndexOf("}", i);
                                if (j >= 0)
                                {
                                    String part = msg.Substring(i + 1, j - i - 1);

                                    if (part.Contains("Time"))
                                    {
                                        int v = part.IndexOf(" ");
                                        double seconds = double.Parse(part.Substring(v + 1, part.Length - v - 1));
                                        measuredTime = (long)(seconds * 1000000); // lcm expects measuredtime in microseconds
                                    }

                                    if (part.Contains("Location")) // INS
                                    {
                                        int v = part.IndexOf(" ");
                                        int w = part.IndexOf(",", v);
                                        for (int d = 0; d < 3; d++)
                                        {
                                            location[d] = double.Parse(part.Substring(v + 1, w - v - 1));
                                            v = part.IndexOf(",", w);
                                            w = part.IndexOf(",", v + 1);
                                            if (w < 0)
                                            {
                                                w = part.Length;
                                            }
                                        }
                                    }

                                    if ((part.Contains("ProperAcceleration") || part.Contains("XYZAcceleration")) && !part.Contains("-2147483648")) // IMU and not NAN
                                    {
                                        int v = part.IndexOf(" ");
                                        int w = part.IndexOf(",", v);
                                        for (int d = 0; d < 3; d++)
                                        {
                                            acceleration[d] = double.Parse(part.Substring(v + 1, w - v - 1));
                                            v = part.IndexOf(",", w);
                                            w = part.IndexOf(",", v + 1);
                                            if (w < 0)
                                            {
                                                w = part.Length;
                                            }
                                        }
                                    }

                                    if (part.Contains("Orientation") || part.Contains("Rotation")) // INS || IMU
                                    {
                                        int v = part.IndexOf(" ");
                                        int w = part.IndexOf(",", v);
                                        for (int d = 0; d < 3; d++)
                                        {
                                            orientation[d] = double.Parse(part.Substring(v + 1, w - v - 1));
                                            v = part.IndexOf(",", w);
                                            w = part.IndexOf(",", v + 1);
                                            if (w < 0)
                                            {
                                                w = part.Length;
                                            }
                                        }
                                        quaternion = rollPitchYawToQuat(orientation);
                                    }

                                    if (part.Contains("AngularVel") && !part.Contains("-2147483648")) // IMU and not NAN
                                    {
                                        int v = part.IndexOf(" ");
                                        int w = part.IndexOf(",", v);
                                        for (int d = 0; d < 3; d++)
                                        {
                                            angular_vel[d] = double.Parse(part.Substring(v + 1, w - v - 1));
                                            v = part.IndexOf(",", w);
                                            w = part.IndexOf(",", v + 1);
                                            if (w < 0)
                                            {
                                                w = part.Length;
                                            }
                                        }
                                    }

                                    //if (part.Contains("AngularAcc")) // IMU
                                    //{
                                    //    int v = part.IndexOf(" ");
                                    //    int w = part.IndexOf(",", v);
                                    //    for (int d = 0; d < 3; d++)
                                    //    {
                                    //        angular_acc[d] = double.Parse(part.Substring(v + 1, w - v - 1));
                                    //        v = part.IndexOf(",", w);
                                    //        w = part.IndexOf(",", v + 1);
                                    //        if (w < 0)
                                    //        {
                                    //            w = part.Length;
                                    //        }
                                    //    }
                                    //}

                                    i = msg.IndexOf("{", j);
                                }
                                else
                                {
                                    // done
                                    break;
                                } // End If
                            } // End While

                            try
                            {
                                pose_t temp = new pose_t();
                                temp.utime = measuredTime; // no time in INS-message


                                temp.pos = new double[3];
                                for (int d = 0; d < 3; d++)
                                {
                                    temp.pos[d] = location[d];
                                }

                                temp.accel = new double[3];
                                for (int d = 0; d < 3; d++)
                                {
                                    temp.accel[d] = acceleration[d];
                                }

                                // orientation is represented with a quartenion
                                temp.orientation = new double[4];
                                for (int d = 0; d < 4; d++)
                                {
                                    temp.orientation[d] = quaternion[d];
                                }

                                temp.rotation_rate = new double[3];
                                for (int d = 0; d < 3; d++)
                                {
                                    temp.rotation_rate[d] = angular_vel[d];
                                }

                                //temp.not_defined_yet = new double[3];
                                //for (int d = 0; d < 3; d++)
                                //{
                                //    temp.not_defined_yet[d] = angular_acc[d];
                                //}

                                myLCM.Publish("POSE", temp); // channel according to intel.conf

                                System.Threading.Thread.Sleep(200);
                            }
                            catch (Exception ex)
                            {
                                Console.Error.WriteLine("Ex: " + ex);
                            }
                        } // end if (msg.StartsWith("SEN {Type INS}")

                     
                        if (msg.Contains("{Type Sonar}"))
                        {
                            // 'SEN {Time 45.14} {Type Sonar} {Name F1}  {Range 4.4690} OR {Name F2 Range 1.9387} 


                            long measuredTime = DateTime.Now.Ticks / 10; // this are the variables we have to extract

                            float beamAngle = 0.349F; // (rad): From default SonarSensor in USARUDK.ini
                            float beam = 0.0F;

                            //then extract all curly-braced parts
                            int j = msg.IndexOf(" ");
                            int i = msg.IndexOf("{", j);
                            while (i >= 0)
                            {
                                j = msg.IndexOf("}", i);
                                if (j >= 0)
                                {
                                    String part = msg.Substring(i + 1, j - i - 1);

                                    if (part.Contains("Time"))
                                    {
                                        int v = part.IndexOf(" ");
                                        double seconds = double.Parse(part.Substring(v + 1, part.Length - v - 1));
                                        measuredTime = (long)(seconds * 1000000); // lcm expects measuredtime in microseconds
                                    }

                                    if (part.Contains("Range")) // {Name F1 Range 4.4690} {Name F2 Range 1.9387} 

                                    {
                                        int v = part.IndexOf(" ");
                                        beam = float.Parse(part.Substring(v + 1, part.Length - v - 1));   
                                    }


                                    i = msg.IndexOf("{", j);
                                }
                                else
                                {
                                    // done
                                    break;
                                } // End If
                            } // End While

                            try
                            {
                                sonar_t temp = new sonar_t();
                                temp.utime = measuredTime;
                                temp.range = beam;
                                temp.direction = 0.0F; // for Nao, all straight
                                temp.width = beamAngle;
                                
                                // missing is location
                                // 
                                

                                myLCM.Publish("SONAR", temp); // channel according to intel.conf

                                System.Threading.Thread.Sleep(200);
                            }
                            catch (Exception ex)
                            {
                                Console.Error.WriteLine("Ex: " + ex);
                            }
                        } // end if (msg.StartsWith("SEN {Type Sonar}")
                    } // end foreach
                
        }
        /// <summary>
        /// Resize Image to requested width x height
        /// </summary>
        /// <param name="image">image to be resized</param>
        /// <param name="width">requested width in pixels</param>
        /// <param name="height">requested height in pixels</param>
        private static Image ResizeWithSameRatio(Image image, float width, float height)
        {
            // from http://stackoverflow.com/questions/10661967/saving-as-jpeg-from-memorystream-in-c-sharp

            // the colour for letter boxing, can be a parameter
            var brush = new SolidBrush(Color.Black);

            // target scaling factor
            float scale = Math.Min(width / image.Width, height / image.Height);

            // target image
            var bmp = new Bitmap((int)width, (int)height);
            var graph = Graphics.FromImage(bmp);

            var scaleWidth = (int)(image.Width * scale);
            var scaleHeight = (int)(image.Height * scale);

            // fill the background and then draw the image in the 'centre'
            graph.FillRectangle(brush, new RectangleF(0, 0, width, height));
            graph.DrawImage(image, new Rectangle(((int)width - scaleWidth) / 2, ((int)height - scaleHeight) / 2, scaleWidth, scaleHeight));
            
            return bmp;
        }

        /// <summary>
        /// Crops a tile from an image (the ImageServer publishes the different cameras in multiview)
        /// </summary>
        /// <param name="image">image to be cropped</param>
        /// <param name="viewNumber">requested tile</param>
        /// <param name="numberOfColumns">number of columns of tiles (each with a camera image)</param>
        private static Image GetSubView(Image image, int viewNumber, int numberOfColumns)
        {
            int row, column, x, y, width, height;

            column = System.Math.DivRem(viewNumber - 1, numberOfColumns, out row);
            //row = remainder;


            if (row < 0)
            {
                // Console.WriteLine("[GetSubView]: Warning row < 0, set to 0");
                row = 0;
            }
            if (column < 0)
            {
                // Console.WriteLine("[GetSubView]: Warning column < 0, set to 0");
                column = 0;
            }

            width = image.Width / numberOfColumns;
            height = image.Height / numberOfColumns;

            // Console.WriteLine("full: {0},{1}, cropped: {2},{3}", fullView.Width, fullView.Height, width, height)

            x = row * width;
            y = column * height;

            var fullview = new Bitmap(image);
            var subview = fullview.Clone(new Rectangle(x, y, width, height), fullview.PixelFormat); // fixed UsarSim format 320x240
            
            return (Image)subview;

        }

        /// <summary>
        /// To prevent singularities, the orientation is stored as an quaternion
        /// </summary>
        /// <param name="rpy">vector of length 3 with resp. roll, pitch, yaw</param>
        private static double[] rollPitchYawToQuat(double[] rpy)
        {
            // from april/java/src/jmat/LinAlg.java

            //assert(rpy.Length==3);

            double[] q = new double[4];
            double roll = rpy[0], pitch = rpy[1], yaw = rpy[2];

            double halfroll = roll / 2;
            double halfpitch = pitch / 2;
            double halfyaw = yaw / 2;

            double sin_r2 = Math.Sin(halfroll);
            double sin_p2 = Math.Sin(halfpitch);
            double sin_y2 = Math.Sin(halfyaw);

            double cos_r2 = Math.Cos(halfroll);
            double cos_p2 = Math.Cos(halfpitch);
            double cos_y2 = Math.Cos(halfyaw);

            q[0] = cos_r2 * cos_p2 * cos_y2 + sin_r2 * sin_p2 * sin_y2;
            q[1] = sin_r2 * cos_p2 * cos_y2 - cos_r2 * sin_p2 * sin_y2;
            q[2] = cos_r2 * sin_p2 * cos_y2 + sin_r2 * cos_p2 * sin_y2;
            q[3] = cos_r2 * cos_p2 * sin_y2 - sin_r2 * sin_p2 * cos_y2;

            return q;
        }

        // Properties indicated by arguments to main /////////////////////////////////////

        private static string robot_type;  // the private field 
        public static string RobotType    // the public property
        {
            get
            {
                return robot_type;
            }
            set
            {
                robot_type = value;
            }
        }

        private static int _camera1_tile;  // the private field 
        public static int FirstViewPort    // the public property
        {
            get
            {
                return _camera1_tile;
            }
            set
            {
                _camera1_tile = value;
            }
        }

        private static int _camera2_tile;  // the private field 
        public static int SecondViewPort    // the public property
        {
            get
            {
                return _camera2_tile;
            }
            set
            {
                _camera2_tile = value;
            }
        }

        private static int _camera_columns;  // the private field 
        public static int MultiViewColumns    // the public property
        {
            get
            {
                return _camera_columns;
            }
            set
            {
                _camera_columns = value;
            }
        }

        // Properties indicated by arguments to main /////////////////////////////////////
        private static long _lastImage;
        /// <summary>
        /// Handles incoming lcm-messages
        /// </summary>
        internal class SimpleSubscriber : LCM.LCMSubscriber
        {
            TcpMessagingConnection usarSimConnection;
            public SimpleSubscriber(TcpMessagingConnection usarSimConnection)
            {
                this.usarSimConnection = usarSimConnection;
            }


            public void MessageReceived(LCM.LCM lcm, string channel, LCM.LCMDataInputStream dins)
            {
                if (channel == "GAMEPAD")
                {
                    gamepad_t inc = new gamepad_t(dins);

                    if (RobotType != "AirRobot")
                    {
                        if (inc.axes[5] < -0.5)
                            usarSimConnection.Send("DRIVE {Left 1,00} {Right 1,00}" + System.Environment.NewLine);
                        else if (inc.axes[5] > 0.5)
                            usarSimConnection.Send("DRIVE {Left -1,00} {Right -1,00}" + System.Environment.NewLine);
                        else if (inc.axes[4] < -0.5)
                            usarSimConnection.Send("DRIVE {Left 0,00} {Right 1,00}" + System.Environment.NewLine);
                        else if (inc.axes[4] > 0.5)
                            usarSimConnection.Send("DRIVE {Left 1,00} {Right 0,00}" + System.Environment.NewLine);
                        else
                            usarSimConnection.Send("DRIVE {Left 0,00} {Right 0,00}" + System.Environment.NewLine);
                    }
                    else
                    {
                        if (inc.axes[5] < -0.5)
                            usarSimConnection.Send("DRIVE {AltitudeVelocity 0,00} {LinearVelocity +1,00} {LateralVelocity 0,00} {RotationalVelocity 0,00} {Normalized False}" + System.Environment.NewLine);
                        else if (inc.axes[5] > 0.5)
                            usarSimConnection.Send("DRIVE {AltitudeVelocity 0,00} {LinearVelocity -1,00} {LateralVelocity 0,00} {RotationalVelocity 0,00} {Normalized False}" + System.Environment.NewLine);
                        else if (inc.axes[4] < -0.5)
                            usarSimConnection.Send("DRIVE {AltitudeVelocity 0,00} {LinearVelocity 0,00} {LateralVelocity +1,00} {RotationalVelocity 0,00} {Normalized False}" + System.Environment.NewLine);
                        else if (inc.axes[4] > 0.5)
                            usarSimConnection.Send("DRIVE {AltitudeVelocity 0,00} {LinearVelocity 0,00} {LateralVelocity -1,00} {RotationalVelocity 0,00} {Normalized False}" + System.Environment.NewLine);
                        else if (inc.axes[3] < -0.5)
                            usarSimConnection.Send("DRIVE {AltitudeVelocity +1,00} {LinearVelocity 0,00} {LateralVelocity 0,00} {RotationalVelocity 0,00} {Normalized False}" + System.Environment.NewLine);
                        else if (inc.axes[3] > 0.5)
                            usarSimConnection.Send("DRIVE {AltitudeVelocity -1,00} {LinearVelocity 0,00} {LateralVelocity 0,00} {RotationalVelocity 0,00} {Normalized False}" + System.Environment.NewLine);
                        else if (inc.buttons == 4)
                            usarSimConnection.Send("DRIVE {AltitudeVelocity +1,00} {LinearVelocity 0,00} {LateralVelocity 0,00} {RotationalVelocity 0,00} {Normalized False}" + System.Environment.NewLine);
                        else if (inc.buttons == 16)
                            usarSimConnection.Send("DRIVE {AltitudeVelocity -1,00} {LinearVelocity 0,00} {LateralVelocity 0,00} {RotationalVelocity 0,00} {Normalized False}" + System.Environment.NewLine);
                        else
                            usarSimConnection.Send("DRIVE {AltitudeVelocity 0,00} {LinearVelocity 0,00} {LateralVelocity 0,00} {RotationalVelocity 0,00} {Normalized False}" + System.Environment.NewLine);

                    }

                }

            }
        }
    }
}


