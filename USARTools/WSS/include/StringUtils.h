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

#ifndef STRINGUTILS_H_
#define STRINGUTILS_H_

#include <sstream>
#include <string>
#include <vector>

#include "debug.h"

/**
	not really a class, only a bunch of utility methods in one namespace so they aren't global.
*/
namespace StringUtils {

	/**
		simple template function to convert any type known to std::ostringstream to a string
		
		tested types:
		-int
		-double
		-float
		
	*/
	template <class T>
	inline std::string stringify(T x)
	{
		std::ostringstream o;
		if (!(o << x))
			return std::string();
		return o.str();
	}
	
	template <class T>
	inline T unstringify(const std::string& str, bool* worked = 0) {
		std::istringstream in(str);
		T out;
		if( !( in >> out ) ) {
			ERR( "Can't convert string \"%s\"!", str.c_str() );
			if(worked)
				(*worked) = false;
		} else {
			if(worked)
				(*worked) = true;
		}
		return out;
	}

	inline std::vector<std::string> getList(std::string& value, const char& delim) {
		unsigned int n = 0;
		int oldn = -1;
		std::vector<std::string> ret;

	//	cerr << "entering getList " << value.size() << endl;

		while(n<value.size()) {
			n = value.find(delim,n+1);

	//		cerr << "found : " << oldn << " " << n << " \"" << value.substr(oldn+1,n-oldn-1) << "\"" << endl;
			ret.push_back( value.substr(oldn+1,n-oldn-1) );

			oldn = n;
		}

	//	cerr << "exiting getList" << endl;

		return ret;
	}
	
	template <class T>
	inline std::vector<T> unstringifyList(std::string& value, const char& delim, const bool ignoreErrorParts = true, bool* worked = 0) {
			unsigned int n = 0;
			int oldn = -1;
			std::vector<T> ret;

			bool lastOK = false;
			if( worked != NULL ) {
				(*worked) = true;
			}

			while(n<value.size()) {
				n = value.find(delim,n+1);

				T el = unstringify<T>(value.substr(oldn+1,n-oldn-1), &lastOK);

				if( lastOK ) {
					ret.push_back( el );
				}

				if( !lastOK && worked != NULL && (*worked) ) {
					(*worked) = false;
				}
				
				if( !lastOK && !ignoreErrorParts ) {
					return std::vector<T>();
				}

				oldn = n;
			}

			return ret;
	}
};

#endif // STRINGUTILS_H_
