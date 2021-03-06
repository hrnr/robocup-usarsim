/* LCM type definition class file
 * This file was automatically generated by lcm-gen
 * DO NOT MODIFY BY HAND!!!!
 */

using System;
using System.Collections.Generic;
using System.IO;
using LCM.LCM;
 
namespace LCMTypes
{
    public sealed class pose_t : LCM.LCM.LCMEncodable
    {
        public long utime;
        public double[] pos;
        public double[] vel;
        public double[] orientation;
        public double[] rotation_rate;
        public double[] accel;
 
        public pose_t()
        {
            pos = new double[3];
            vel = new double[3];
            orientation = new double[4];
            rotation_rate = new double[3];
            accel = new double[3];
        }
 
        public static readonly ulong LCM_FINGERPRINT;
        public static readonly ulong LCM_FINGERPRINT_BASE = 0x170b77d82958082fL;
 
        static pose_t()
        {
            LCM_FINGERPRINT = _hashRecursive(new List<String>());
        }
 
        public static ulong _hashRecursive(List<String> classes)
        {
            if (classes.Contains("LCMTypes.pose_t"))
                return 0L;
 
            classes.Add("LCMTypes.pose_t");
            ulong hash = LCM_FINGERPRINT_BASE
                ;
            classes.RemoveAt(classes.Count - 1);
            return (hash<<1) + ((hash>>63)&1);
        }
 
        public void Encode(LCMDataOutputStream outs)
        {
            outs.Write((long) LCM_FINGERPRINT);
            _encodeRecursive(outs);
        }
 
        public void _encodeRecursive(LCMDataOutputStream outs)
        {
            outs.Write(this.utime); 
 
            for (int a = 0; a < 3; a++) {
                outs.Write(this.pos[a]); 
            }
 
            for (int a = 0; a < 3; a++) {
                outs.Write(this.vel[a]); 
            }
 
            for (int a = 0; a < 4; a++) {
                outs.Write(this.orientation[a]); 
            }
 
            for (int a = 0; a < 3; a++) {
                outs.Write(this.rotation_rate[a]); 
            }
 
            for (int a = 0; a < 3; a++) {
                outs.Write(this.accel[a]); 
            }
 
        }
 
        public pose_t(byte[] data) : this(new LCMDataInputStream(data))
        {
        }
 
        public pose_t(LCMDataInputStream ins)
        {
            if ((ulong) ins.ReadInt64() != LCM_FINGERPRINT)
                throw new System.IO.IOException("LCM Decode error: bad fingerprint");
 
            _decodeRecursive(ins);
        }
 
        public static LCMTypes.pose_t _decodeRecursiveFactory(LCMDataInputStream ins)
        {
            LCMTypes.pose_t o = new LCMTypes.pose_t();
            o._decodeRecursive(ins);
            return o;
        }
 
        public void _decodeRecursive(LCMDataInputStream ins)
        {
            this.utime = ins.ReadInt64();
 
            this.pos = new double[(int) 3];
            for (int a = 0; a < 3; a++) {
                this.pos[a] = ins.ReadDouble();
            }
 
            this.vel = new double[(int) 3];
            for (int a = 0; a < 3; a++) {
                this.vel[a] = ins.ReadDouble();
            }
 
            this.orientation = new double[(int) 4];
            for (int a = 0; a < 4; a++) {
                this.orientation[a] = ins.ReadDouble();
            }
 
            this.rotation_rate = new double[(int) 3];
            for (int a = 0; a < 3; a++) {
                this.rotation_rate[a] = ins.ReadDouble();
            }
 
            this.accel = new double[(int) 3];
            for (int a = 0; a < 3; a++) {
                this.accel[a] = ins.ReadDouble();
            }
 
        }
 
        public LCMTypes.pose_t Copy()
        {
            LCMTypes.pose_t outobj = new LCMTypes.pose_t();
            outobj.utime = this.utime;
 
            outobj.pos = new double[(int) 3];
            for (int a = 0; a < 3; a++) {
                outobj.pos[a] = this.pos[a];
            }
 
            outobj.vel = new double[(int) 3];
            for (int a = 0; a < 3; a++) {
                outobj.vel[a] = this.vel[a];
            }
 
            outobj.orientation = new double[(int) 4];
            for (int a = 0; a < 4; a++) {
                outobj.orientation[a] = this.orientation[a];
            }
 
            outobj.rotation_rate = new double[(int) 3];
            for (int a = 0; a < 3; a++) {
                outobj.rotation_rate[a] = this.rotation_rate[a];
            }
 
            outobj.accel = new double[(int) 3];
            for (int a = 0; a < 3; a++) {
                outobj.accel[a] = this.accel[a];
            }
 
            return outobj;
        }
    }
}

