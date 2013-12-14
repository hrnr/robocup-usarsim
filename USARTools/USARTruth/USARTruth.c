/*****************************************************************************
------------------------------------------------------------------------------
--  Copyright 2012-2013
--  Georgia Tech Research Institute
--  505 10th Street
--  Atlanta, Georgia 30332
--
--  This material may be reproduced under the GNU Public license
------------------------------------------------------------------------------

 DISCLAIMER:
 This software was originally produced by the National Institute of Standards
 and Technology (NIST), an agency of the U.S. government, and by statute is
 not subject to copyright in the United States.  

 Modifications to the code have been made by Georgia Tech Research Institute
 and these modifications are subject to the copyright shown above
*****************************************************************************/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "getopt.h"
#include "ulapi.h"
#include "parseUtils.h"

/*
  Usage: USARTruth {-p <port>} {-h <host>} {-s <string>}

  Connects as a client to the <port> on optional <host>, sends <string>
  and prints the response.

  <port> defaults to 3989
  <host> defaults to "localhost".
  <string> defaults to CR LF.
*/

static int done = 0;

static void handle_message(const char *message)
{
	const char *nextptr;
	char token[MAX_TOKEN_LEN];
	const char *ptr = message;
	double dbl[6];
	
  if (! strncmp(ptr, "{End}", strlen("{End}"))) {
    done = 1;
    return;
  }

  while (1)
  {
	  nextptr = getKey(ptr, token);
	  if(nextptr == ptr ) break;
	  ptr = nextptr;
	  if( !strcmp(token, "Name"))
	  {
		  nextptr = getValue(ptr, token);
		  if(nextptr == ptr ) break;
			ptr = nextptr;
		  printf( "Name: %s\n", token );
	  }
	  else if( !strcmp(token, "Class"))
	  {
		  nextptr = getValue(ptr, token);
		  if(nextptr == ptr ) break;
			ptr = nextptr;
		  printf( "Class: %s\n", token );
	  }
	  else if( !strcmp(token, "Time"))
	  {
		  nextptr = getDouble(ptr, &dbl[0] );
		  if(nextptr == ptr ) break;
			ptr = nextptr;
		  printf( "Time: %lf\n", dbl[0] );
	  }
	  else if( !strcmp(token, "Location"))
	  {
		  nextptr = getVector(ptr, dbl, 3 );
		  if(nextptr == ptr ) break;
			ptr = nextptr;
		  printf( "Location: <%lf %lf %lf>\n", dbl[0], dbl[1], dbl[2] );
	  }
	  else if( !strcmp(token, "Rotation"))
	  {
		  nextptr = getVector(ptr, dbl, 3 );
		  if(nextptr == ptr ) break;
			ptr = nextptr;
		  printf( "Rotation: <%lf %lf %lf>\n", dbl[0], dbl[1], dbl[2] );
	  }
	  else if( !strcmp(token, "Bone"))
	  {
		  // only interested in 'Main'
		  nextptr = expect("Main", ptr);
		  if( nextptr != ptr ) // found it
		  {
			  ptr = nextptr;
			  nextptr = getBone(ptr, dbl );
			  if( nextptr == ptr ) break;
			  printf( "Bone: <%lf %lf %lf> <%lf %lf %lf>\n", dbl[0], dbl[1], dbl[2], dbl[3], dbl[4], dbl[5] );
			  break; // this is the last thing that I want...
		  }
	  }
	  else
	  {
		  printf( "token: %s\n", token );
		  break;
	  }
  }
//  printf("remainder: %s\n", ptr);
}

int main(int argc, char *argv[])
{
  enum {HOSTNAMELEN = 80, STRINGLEN = 1024};
  int option;
  ulapi_integer port = 3989;
  char hostname[HOSTNAMELEN] = "localhost";
  char string[STRINGLEN] = "{class USARPhysObj.partc} {name part_c_6}";
  ulapi_integer socket_id;
  int nchars;
  enum {BUFFERLEN = 256, BUILDMAX = 1024};
#define DELIMITER '\n'
  int buildlen = BUFFERLEN;
  char *build = NULL;
  char *build_ptr;
  char *build_end;
  char buffer[BUFFERLEN];
  char *buffer_ptr;
  char *buffer_end;
  ptrdiff_t offset;

  opterr = 0;

  for (;;) {
    option = getopt(argc, argv, ":p:h:s:");
    if (option == -1)
      break;

    switch (option) {
    case 'p':
      port = atoi(optarg);
      break;

    case 'h':
      strncpy(hostname, optarg, sizeof(hostname) - 1);
      hostname[sizeof(hostname) - 1] = 0;
      break;

    case 's':
      strncpy(string, optarg, sizeof(string));
      string[sizeof(string) - 1] = 0;
      break;

    case ':':
      fprintf(stderr, "missing value for -%c\n", optopt);
      return 1;
      break;

    default:			/* '?' */
      fprintf(stderr, "unrecognized option -%c\n", optopt);
      return 1;
      break;
    }
  }
  if (optind < argc) {
    fprintf(stderr, "extra non-option characters: %s\n", argv[optind]);
    return 1;
  }

  if (ulapi_init(UL_USE_DEFAULT)) {
    fprintf(stderr, "ulapi_init error\n");
    return 1;
  }

  build = realloc(build, buildlen * sizeof(*build));
  build_ptr = build;
  build_end = build + buildlen;

  socket_id = ulapi_socket_get_client_id(port, hostname);

  strcat(string, "\r\n");
  fprintf(stderr, "sending string %s", string);
  ulapi_socket_write(socket_id, string, strlen(string));

  done = 0;

  while (! done) {
    nchars = ulapi_socket_read(socket_id, buffer, sizeof(buffer) - 1);
    if (-1 == nchars) {
      fprintf(stderr, "connection closed\n");
	  done = 1;
    } else if (0 == nchars) {
      fprintf(stderr, "end of file\n");
	  done = 1;
    } else {
      buffer_ptr = buffer;
      buffer_end = buffer + nchars;
      while (buffer_ptr != buffer_end) {
	if (build_ptr == build_end) {
	  if (buildlen > BUILDMAX) {
	    fprintf(stderr, "message overrun in reader\n");
	    build_ptr = build;
	    break;
	  }
	  offset = build_ptr - build;
	  buildlen *= 2;
	  build = (char *) realloc(build, buildlen * sizeof(*build));
	  build_ptr = build + offset;
	  build_end = build + buildlen;
	}
	*build_ptr++ = *buffer_ptr;
	if (*buffer_ptr++ == DELIMITER) {
	  offset = build_ptr - build;
	  build_ptr = build;
	  build[offset] = 0;
	  handle_message(build);
	  if( done ) {
		  ulapi_socket_write(socket_id, string, strlen(string));
		  done = 1;
	  }
	}
      }
    }
  }

  return 0;
}

