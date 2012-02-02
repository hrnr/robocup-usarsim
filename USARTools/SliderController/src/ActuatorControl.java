package gov.nist.sliders;

import java.util.ArrayList;

public class ActuatorControl {
	private String name;
	private int numLinks;
	private ArrayList<Boolean> linksRevolute;
	private ArrayList<Double> linkMin;
	private ArrayList<Double> linkMax;
	public ActuatorControl(String name)
	{
		this.name = name;
		linksRevolute = new ArrayList<Boolean>();
		linkMin = new ArrayList<Double>();
		linkMax = new ArrayList<Double>();
		numLinks = 0;
	}
	//type is true for revolute joint, false for otherwise
	public void addLink(boolean type, double min, double max)
	{
		linksRevolute.add(Boolean.valueOf(type));
		linkMin.add(Double.valueOf(min));
		linkMax.add(Double.valueOf(max));
		numLinks++;
	}
	public int getLinkNum()
	{
		return numLinks;
	}
	public boolean getRev(int index)
	{
		return linksRevolute.get(index);
	}
	public double getMax(int index)
	{
		return linkMax.get(index);
	}
	public double getMin(int index)
	{
		return linkMin.get(index);
	}
	public String getName()
	{
		return this.name;
	}
}
