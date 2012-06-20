/*
Copyright (C) 2008 Jacobs University

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public
License as published by the Free Software Foundation; either
version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

#ifndef __SMARTPOINTER_H__
#define __SMARTPOINTER_H__

/** class for counted reference semantics
 * - deletes the object to which it refers when the last SmartPtr
 *   that refers to it is destroyed. 
 * This class is not thread-safe.
 *  Based on http://www.josuttis.com/libbook/cont/countptr.hpp.html
 */
template <class T>
class SmartPtr {
public:
    /// initialize pointer with existing pointer
    /// - requires that the pointer p is a return value of new
    explicit SmartPtr (T* p=0)
        : ptr(p), count(new long(1)) {
    }

    /// copy pointer (one more owner)
    SmartPtr(const SmartPtr<T>& p) throw()
        : ptr(p.ptr), count(p.count) {
        ++(*count);
    }

    /// destructor (delete value if this was the last owner)
    virtual ~SmartPtr() throw() {
        dispose();
    }

    /// assignment (unshare old and share new value)
    SmartPtr<T>& operator= (const SmartPtr<T>& p) throw() {
        if (this != &p) {
            dispose();
            ptr = p.ptr;
            count = p.count;
            ++(*count);
        }
        return *this;
    }

    /// access the value to which the pointer refers
    T& operator*() const throw() {
        return *ptr;
    }
    T* operator->() const throw() {
        return ptr;
    }

    bool isNull(void) const throw(){
        return (ptr == 0); 
    }

	bool operator==(const SmartPtr<T>& p) {
		return ptr == p.ptr;
	}
	
	bool operator<(const SmartPtr<T>& p) {
		return (uint)ptr < (uint)p.ptr;
	}


    /** Class DT should be a derived class of T, 
     * and the initial pointer should point to an object of type DT.
     */
    template<class DT>
    operator DT*(){
        return dynamic_cast<DT*>(ptr);
    }


protected:
    void dispose() {
        if (--(*count) == 0) {
            delete count;
            delete ptr;
        }
    }
protected:
    T* ptr;        // pointer to the value
    long* count;   // shared number of owners    
};


#endif /* __SMARTPOINTER_H__ */
