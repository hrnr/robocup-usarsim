package org.nist.usarui;

import javax.swing.*;
import java.util.*;

/**
 * A data model for JList classes that uses a (surprise!) java.util.List!
 *
 * @author Stephen Carlson (NIST)
 */
public class ListDataModel<T> extends AbstractListModel {
	private static final long serialVersionUID = 0L;

	private final List<T> list;

	/**
	 * Creates a new list data model based on the specified list.
	 *
	 * @param list the list to display
	 */
	public ListDataModel(List<T> list) {
		this.list = list;
	}
	/**
	 * Indicates that the list has been cleared.
	 */
	public void fireCleared() {
		fireContentsChanged(0, 0);
	}
	/**
	 * Indicates that items have been modified in the list.
	 *
	 * @param start the index of the first changed item
	 * @param end the index of the last changed item
	 */
	public void fireContentsChanged(int start, int end) {
		fireContentsChanged(this, start, end);
	}
	/**
	 * Indicates that items have been added to the list.
	 *
	 * @param start the index of the first added item
	 * @param end the index of the last added item
	 */
	public void fireIntervalAdded(int start, int end) {
		fireIntervalAdded(this, start, end);
	}
	/**
	 * Indicates that items have been removed from the list.
	 *
	 * @param start the index of the first removed item
	 * @param end the index of the last removed item
	 */
	public void fireIntervalRemoved(int start, int end) {
		fireIntervalRemoved(this, start, end);
	}
	public int getSize() {
		return list.size();
	}
	public Object getElementAt(int index) {
		return list.get(index);
	}
}