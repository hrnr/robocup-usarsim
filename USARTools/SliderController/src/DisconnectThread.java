package gov.nist.sliders;

public class DisconnectThread implements Runnable{
	private SliderPanel connectPanel;
	private DisconnectListener listener;
	public DisconnectThread(SliderPanel panel, DisconnectListener listener)
	{
		connectPanel = panel;
		this.listener = listener;
	}
	public void run() {
		while(connectPanel.readInputLine());
		//while loop exited
		listener.onDisconnect();
	}

}
