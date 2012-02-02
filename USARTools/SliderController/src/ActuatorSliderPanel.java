package gov.nist.sliders;
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * HumanSliderPanel.java
 *
 * Created on Jun 28, 2010, 4:00:29 PM
 */

/**
 *
 * @author nunnally
 */

import java.awt.Dimension;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.Scanner;

import javax.swing.JButton;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

public class ActuatorSliderPanel extends SliderPanel {

    private int numBones, multiplier;
    private ArrayList<ActuatorControl> controllers;
    private LinkSliderPanel[] boneSliders;
    private Scanner scan;
    private JTextField cmd;
    /** Creates new form HumanSliderPanel */
    //This inits the arm in the UT3 level and holds an array of LinkSliderPanels
    public ActuatorSliderPanel(String botName, float x, float y, float z, float r, float p, float w, int percision, String host, int port) {
        super();
    	String str;
        ArmDOFSlider sliders;
        
        multiplier = (int)Math.pow(10,percision);

        this.setLayout(new GridBagLayout());
        GridBagConstraints c = new GridBagConstraints();
        c.fill = GridBagConstraints.NONE;
        c.anchor = GridBagConstraints.LINE_START;
        c.gridx = 0;

        try{
            USARSocket = new Socket(host, port);
            out = new PrintWriter(USARSocket.getOutputStream(),true);
            in = new BufferedReader(new InputStreamReader(USARSocket.getInputStream()));        

            sendCommand("INIT {ClassName USARBot."+botName+"} {Location "+x+","+y+","+z+"} {Rotation "+r+","+p+","+w+"}");
            in.readLine();
            str = getConf();
            
            System.out.println(str);
            scan = new Scanner(str);

            scan = new Scanner(str);
            controllers = getControllers();
            boneSliders = new LinkSliderPanel[numBones];
            int linkIndex = 0;
            for(int i = 0; i < controllers.size(); i++){
            	ActuatorControl control = controllers.get(i);
            	for(int j = 0;j<control.getLinkNum();j++)
            	{
            		String name = control.getName() + " link "+ j;
	                if(control.getRev(j))
	                    boneSliders[linkIndex]= new LinkSliderPanel(name,'W', control.getMin(j), control.getMax(j), percision, i, j);
	                else
	                    boneSliders[linkIndex]= new LinkSliderPanel(name,'Z', control.getMin(j), control.getMax(j), percision, i, j);
	                c.gridy = linkIndex;
	                this.add(boneSliders[linkIndex],c);
	
	                sliders = boneSliders[linkIndex].getSliders();
	
	                sliders.addChangeListener(new SliderListener());
	                linkIndex++;
            	}
            }
            JPanel cmdPanel = new JPanel();
            cmdPanel.setLayout(new GridBagLayout());
            cmd = new JTextField();
            cmd.setPreferredSize(new Dimension(500, 20));
            JButton button = new JButton();
            button.setText("Send");
            button.addActionListener(new ButtonListener());
            cmdPanel.add(cmd);
            cmdPanel.add(button);
            c.gridy = numBones + 2;
            this.add(cmdPanel, c);
        }
        catch(UnknownHostException e){
            System.out.println("Bad host");
            System.exit(1);
        }
        catch(IOException e){
            System.out.println("USARSim must be running");
            System.exit(1);
        }

    }

    // Sends a message to get the configuration data of the arm
    private String getConf(){
        String result="";
        sendCommand("GETCONF {Type Actuator}");
        try{
            result = in.readLine();
        }
        catch(IOException e){
            System.out.println("IOException thrown in getConf: " + e.getMessage());
            System.exit(1);
        }

        return result;
    }


    //Gets the controller name from the conf message
    private ArrayList<ActuatorControl> getControllers(){
        numBones = 0;
        ArrayList<ActuatorControl> actuators = new ArrayList<ActuatorControl>();
        int numActuators = 0;
        while (scan.hasNext()){
        	String val = scan.next();
        	if(val.equals("{Name")){
        		numActuators++;
        		String temp = scan.next();
                ActuatorControl ac = new ActuatorControl(temp.substring(0, temp.length()-1));
                actuators.add(ac);
            }
        	else if(val.equals("{Link"))
        	{
        		numBones++;
        		boolean isRev = isRev();
        		double min = getMin();
        		double max = getMax();
        		actuators.get(numActuators - 1).addLink(isRev, min, max);
        	}
        }
        return actuators;
    }

    //Checks to see if this is a revolutionary joint
    private boolean isRev(){
        boolean result;

        while(!scan.next().equals("{JointType")){}

        result = scan.next().equals("Revolute}");


        return result;
    }

    //Gets the min limit of the the current joint from the conf message
    private double getMin(){
        double result;
        String temp;

        while(!scan.next().equals("{MinValue")){}

        temp = scan.next();
        result = Double.parseDouble(temp.substring(0,temp.length()-1));

        return result;
    }

    //Gets the max limit of the the current joint from the conf message
    private double getMax(){
        double result;
        String temp;

        while(!scan.next().equals("{MaxValue")){}

        temp = scan.next();
        result = Double.parseDouble(temp.substring(0,temp.length()-1));

        return result;
    }

    //Sends a command to the Unreal server
    private void sendCommand(String cmd){
        out.println(cmd);
    }
    //Listens for changes to the sliders and sends the movement command
    private class SliderListener implements ChangeListener{
        public void stateChanged(ChangeEvent evt){
            ArmDOFSlider source = (ArmDOFSlider) evt.getSource();
            int value = source.getValue();
            String name = controllers.get(source.getActNum()).getName();
            int link = source.getLinkNum();
            sendCommand("ACT {Name "+name+"} {Link "+link+"} {Value "+(((double)value)/multiplier)+"}");
            }
    }
    private class ButtonListener implements ActionListener{
    	public void actionPerformed(ActionEvent e)
    	{
    		sendCommand(cmd.getText());
    	}
    }
    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(this);
        this.setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 400, Short.MAX_VALUE)
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 300, Short.MAX_VALUE)
        );
    }// </editor-fold>//GEN-END:initComponents


    // Variables declaration - do not modify//GEN-BEGIN:variables
    // End of variables declaration//GEN-END:variables

}
