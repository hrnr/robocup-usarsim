package gov.nist.sliders;
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author nunnally
 */
public class ArmDOFSlider extends DOFSlider {
    private int link;
    private int actuator;

    //Holds name and dof info for passing up to movement command
    public ArmDOFSlider(int cNum, int lNum){
        super();
        actuator = cNum;
        link = lNum;
    }

    public int getLinkNum(){
        return link;
    }
    public int getActNum()
    {
    	return actuator;
    }
}
