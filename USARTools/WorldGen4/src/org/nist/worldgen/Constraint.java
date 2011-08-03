package org.nist.worldgen;

/**
 * A class storing minimum and maximum values for a particular item.
 *
 * @author Stephen Carlson
 */
public class Constraint<T extends Comparable<T>> {
	/**
	 * Whether the value can be null. If it can be, then it is always allowed.
	 */
	private boolean nullAllowed;
	/**
	 * The minimum value allowed.
	 */
	private T min;
	/**
	 * The maximum value allowed.
	 */
	private T max;

	/**
	 * Creates a new constraint where null is not allowed.
	 *
	 * @param min the minimum value allowed
	 * @param max the maximum value allowed
	 */
	public Constraint(T min, T max) {
		this(min, max, false);
	}
	/**
	 * Creates a new constraint.
	 *
	 * @param min the minimum value allowed
	 * @param max the maximum value allowed
	 * @param nullAllowed whether null values are permitted.
	 */
	public Constraint(T min, T max, boolean nullAllowed) {
		if (max != null && min != null && max.compareTo(min) < 0)
			throw new IllegalArgumentException("min > max");
		this.nullAllowed = nullAllowed;
		this.max = max;
		this.min = min;
	}
	/**
	 * Determines whether the value is allowed by this constraint.
	 *
	 * @param value the value to check
	 * @return whether the value is allowed according to the rules
	 */
	public boolean allow(T value) {
		return (value == null && nullAllowed) || !(value == null || ((max != null &&
			value.compareTo(max) > 0) || (min != null && value.compareTo(min) < 0)));
	}
	/**
	 * Compares this value to its bounds. Returns 0 if in bounds or null, 1 if too high, or
	 * -1 if too low.
	 *
	 * @param value the value to check
	 * @return a description of which bounds it violates
	 */
	public int compareBounds(T value) {
		int ret = 0;
		if (value != null) {
			if (max != null && value.compareTo(max) > 0) ret = 1;
			else if (min != null && value.compareTo(min) < 0) ret = -1;
		}
		return ret;
	}
	/**
	 * Creates a new constraint with a different maximum value.
	 *
	 * @param newMax the new maximum value
	 * @return a constraint with the same minimum and allowNull parameters as this one but
	 * with newMax as its maximum
	 */
	public Constraint<T> createMaxConstraint(T newMax) {
		return new Constraint<T>(min, newMax, nullAllowed);
	}
	/**
	 * Creates a new constraint with a different minimum value.
	 *
	 * @param newMin the new minimum value
	 * @return a constraint with the same maximum and allowNull parameters as this one but
	 * with newMin as its minimum
	 */
	public Constraint<T> createMinConstraint(T newMin) {
		return new Constraint<T>(newMin, max, nullAllowed);
	}
	/**
	 * Gets whether this constraint accepts null as a value.
	 *
	 * @return whether null is allowed
	 */
	public boolean isNullAllowed() {
		return nullAllowed;
	}
	/**
	 * Gets the maximum value of this constraint.
	 *
	 * @return the maximum allowed value
	 */
	public T getMax() {
		return max;
	}
	/**
	 * Gets the minimum value of this constraint.
	 *
	 * @return the minimum allowed value
	 */
	public T getMin() {
		return min;
	}
}