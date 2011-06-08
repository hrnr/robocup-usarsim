// Implementes both a stack and a queue, that is a buffer with both FIFO and LIFO capabilities
class StackQueue extends Object;

var array<Object> buffer; // array to store all data
var int newestIndex; // index to the empty cell after the last added object, 0 initially
var int oldestIndex; // index to the last added object still in buffer

defaultproperties
{
	newestIndex=0;
	oldestIndex=0;
}

// push data into the buffer
function push(Object obj)
{
	buffer[newestIndex++]=obj;
}

// gets the newest object from the buffer, so use as a stack
// returns None when buffer is empty
function Object pop_newest()
{
	local Object obj;
	if (newestIndex>0)
	{
		newestIndex--;
		obj=buffer[newestIndex];
	}
	else
		obj=None;
	return obj;
}

// gets the oldest object from the buffer, so use as a queue
// returns None when buffer is empty
function Object pop_oldest()
{
	local Object obj;
	if (oldestIndex<newestIndex)
	{
		obj=buffer[oldestIndex];
		oldestIndex++;
		if (oldestIndex==newestIndex) // empty buffer so start at index 0
		{
			oldestIndex=0;
			newestIndex=0;
		}
	}
	else
		obj=None;
	return obj;
}

// returns the first index for interating trough the buffer
function int start()
{
	return oldestIndex;
}

// returns the one past the last index for interating trough the buffer
function int end()
{
	return newestIndex;
}

// returns the object at the specified index
function Object get(int index)
{
	return buffer[index];
}
