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
    public sealed class gamepad_t : LCM.LCM.LCMEncodable
    {
        public long utime;
        public bool present;
        public int naxes;
        public double[] axes;
        public long buttons;
 
        public gamepad_t()
        {
        }
 
        public static readonly ulong LCM_FINGERPRINT;
        public static readonly ulong LCM_FINGERPRINT_BASE = 0x345b96879832ec32L;
 
        static gamepad_t()
        {
            LCM_FINGERPRINT = _hashRecursive(new List<String>());
        }
 
        public static ulong _hashRecursive(List<String> classes)
        {
            if (classes.Contains("LCMTypes.gamepad_t"))
                return 0L;
 
            classes.Add("LCMTypes.gamepad_t");
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
 
            outs.Write(this.present); 
 
            outs.Write(this.naxes); 
 
            for (int a = 0; a < this.naxes; a++) {
                outs.Write(this.axes[a]); 
            }
 
            outs.Write(this.buttons); 
 
        }
 
        public gamepad_t(byte[] data) : this(new LCMDataInputStream(data))
        {
        }
 
        public gamepad_t(LCMDataInputStream ins)
        {
            if ((ulong) ins.ReadInt64() != LCM_FINGERPRINT)
                throw new System.IO.IOException("LCM Decode error: bad fingerprint");
 
            _decodeRecursive(ins);
        }
 
        public static LCMTypes.gamepad_t _decodeRecursiveFactory(LCMDataInputStream ins)
        {
            LCMTypes.gamepad_t o = new LCMTypes.gamepad_t();
            o._decodeRecursive(ins);
            return o;
        }
 
        public void _decodeRecursive(LCMDataInputStream ins)
        {
            this.utime = ins.ReadInt64();
 
            this.present = ins.ReadBoolean();
 
            this.naxes = ins.ReadInt32();
 
            this.axes = new double[(int) naxes];
            for (int a = 0; a < this.naxes; a++) {
                this.axes[a] = ins.ReadDouble();
            }
 
            this.buttons = ins.ReadInt64();
 
        }
 
        public LCMTypes.gamepad_t Copy()
        {
            LCMTypes.gamepad_t outobj = new LCMTypes.gamepad_t();
            outobj.utime = this.utime;
 
            outobj.present = this.present;
 
            outobj.naxes = this.naxes;
 
            outobj.axes = new double[(int) naxes];
            for (int a = 0; a < this.naxes; a++) {
                outobj.axes[a] = this.axes[a];
            }
 
            outobj.buttons = this.buttons;
 
            return outobj;
        }
    }
}

