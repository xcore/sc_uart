// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <stdio.h>
#include "header.h"
#include <stdlib.h>

struct STCTX stcontext;


struct STCTX readfile() {
//void readfile(){
FILE * pFile;
  long lSize;
  char * buffer;
  size_t result;
  struct STCTX stContext;
  int i ;

  pFile = fopen ( "testConfig.txt" , "r+" );
  if (pFile==NULL) {fputs ("File error",stderr); exit (1);}

  // obtain file size:
  fseek (pFile , 0 , SEEK_END);
  lSize = ftell (pFile);
  rewind (pFile);

  // allocate memory to contain the whole file:
  buffer = (char*) malloc (sizeof(char)*lSize);
  if (buffer == NULL) {fputs ("Memory error",stderr); exit (2);}

  // copy the file into the buffer:
  result = fread (buffer,1,lSize,pFile);
  if (result != lSize) {fputs ("Reading error",stderr); exit (3);}

  /* the whole file is now loaded in the memory buffer. */

  for(i=0;i<3;i++){
  printf("%c\n",buffer[i]);
  }
  stContext.ui32stopbit = atoi(buffer);
  stContext.ui32bitsperbyte = atoi(buffer+2);


  // terminate
  fclose (pFile);
  free (buffer);
  return stContext;
}
