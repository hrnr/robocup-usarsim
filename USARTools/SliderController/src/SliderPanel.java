package gov.nist.sliders;
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author nunnally
 */

import javax.swing.*;
import java.net.*;
import java.io.*;

//Parent of intersection of Human and MisPkg
// has socket variables and closing method
public class SliderPanel extends JPanel {
    protected Socket USARSocket;
    protected PrintWriter out;
    protected BufferedReader in;
    void closeSocket(){
     try{
            out.flush();
            out.close();
            in.close();
            USARSocket.close();
        }
        catch(IOException e){
            System.out.println("IOException thrown in SliderPanel: " + e.getMessage());
        }
    }
    //attempt to read a line coming in over the socket (and ignores it).
    //returns true if the line is not null.
    public boolean readInputLine()
    {
    	String result = null;
    	try
    	{
    		result = in.readLine();
    	}catch(IOException e)
    	{
    		return false;
    	}
    	if(result == null)
    		return false;
    	return true;
    }
}
