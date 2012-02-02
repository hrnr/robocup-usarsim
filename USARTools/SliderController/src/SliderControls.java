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

import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.event.*;
import java.io.File;
import java.io.FileNotFoundException;
import java.util.*;

public class SliderControls {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        boolean changeConfig = false;
        String file="";

        //Check to see if the user is using another configFile in the arguments line
        if(args.length == 1){
            changeConfig = true;
            file = args[0];
        } else if(args.length > 1){
            System.out.println("Usage: java -jar SliderControls.jar [optional configFile]");
            System.exit(1);
        }

        new SliderControls(changeConfig, file);
    }

    //Declaration of Class Variables
    private InputPanel panel;
    private SliderPanel slidePanel;
    private JFrame frame;
    
    private String configFile="src/SliderController.ini";

    //Declaration of Config Variables
    private int port;
    private String host;
    private int precision;
    
    public SliderControls(boolean changeConfig, String file){
        if(changeConfig){
            configFile = file;
        }
        
        frame = new JFrame("Slider Controls");
        frame.setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
        frame.addWindowListener(new ClosingOperation());
        panel = new InputPanel();
        frame.getContentPane().add(panel);
        panel.getButton().addActionListener(new SendPressed());
        frame.pack();
        frame.show();
    }

    private class ClosingOperation implements WindowListener{
        public void windowActivated(WindowEvent e){}
        public void windowClosed(WindowEvent e){
            if (slidePanel != null)
                slidePanel.closeSocket();
            System.exit(0);
        }
        public void windowClosing(WindowEvent e){
            if (slidePanel != null)
                slidePanel.closeSocket();
            System.exit(0);
        }
        public void windowDeactivated(WindowEvent e){}
        public void windowDeiconified(WindowEvent e){}
        public void windowIconified(WindowEvent e){}
        public void windowOpened(WindowEvent e){}
    }

    private class SendPressed implements ActionListener{
        public void actionPerformed(ActionEvent e){
            // Set the variables from the configuration file
            configure();
            slidePanel = new ActuatorSliderPanel(panel.getClassName(),panel.getLocX(),panel.getLocY(),panel.getLocZ(),panel.getRotR(),panel.getRotP(),panel.getRotW(),precision,host,port);
            frame.getContentPane().removeAll();
            frame.getContentPane().add(slidePanel);
            frame.pack();
            frame.show();
        }
    }
    
    // Method to set all of the configuration variables based on the SoundServer.ini file
    private void configure(){
        try{
            Scanner config = new Scanner(new File(configFile));

            while(config.hasNextLine()){
                setVariable(config.next(),config);
            }
        }
        catch(FileNotFoundException exp){
            System.out.println(configFile + " does not exist");
            System.exit(1);
        }
        catch(InputMismatchException exp){
            System.out.println("Config file is not formatted correctly.\nCheck README file to see what should be a float, int, and a string");
            System.exit(1);
        }
        catch(Exception exp){
            System.out.println("Check configuration file: " + exp);
            System.exit(1);
        }
    }

    // Var should be one of the configuration variables, then sets it based
    //    on the config file
    private void setVariable(String var, Scanner config){
        config.next();

        if(var.equals("Precision")){
            precision=config.nextInt();
        }else if(var.equals("Host")){
            host = config.next();
        }else if(var.equals("Port")){
            port = config.nextInt();
        }else{
            System.out.println("Unknown variable = " + var);
            config.nextLine();
        }
    }
}
