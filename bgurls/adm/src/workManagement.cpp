#include "mex.h"
#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <vector>
#include <algorithm>
#include <iostream>

#include "../include/retCode.h"
#include "../include/lockLib.h"

struct MetaData
{
  int32_t blockID;
  int32_t  status;
};

int getWork(const char *stateFileName, int fLock)
{
  FILE *fState;

  if(acquireLock(fLock) == LOCK_FAIL) return NO_WORK;

  if((fState = fopen(stateFileName, "r+")) == NULL)
  {
    mexPrintf("Unable to read stateFile\n");
    fState = NULL;
    return JOB_DONE;
  }

  // get size of file
  long fsize;

  fseek(fState, 0L, SEEK_END);
  fsize = ftell(fState);
  fseek(fState, 0L, SEEK_SET);

  // Read file into memory
  std::vector<MetaData> buffer(fsize/sizeof(MetaData));
  fread( buffer.data(), sizeof(MetaData), buffer.size(), fState );

  // Find the first item that hasn't been worked on yet
  // (linear search)
  auto found = std::find_if( buffer.begin(), buffer.end(),
      [](MetaData const & md)
      {
        return md.status == 0;
      } );

  /*
  // Perform binary search over the file to find the first
  // work item that hasn't been done
  auto found = std::lower_bound( buffer.begin(), buffer.end(), 0,
      [](MetaData const & md, int32_t tag)
      {
        return md.status != tag;
      } );
  */

  int blockID = found->blockID;
  int state = found->status;

  // Updates the tag for a blockID to some value
  auto updateTag = [&]( int32_t blockID, int32_t newTag )
  {
    const long index = (blockID == FINALIZE_JOB) ? buffer.size() - 1 : blockID - 1;
    const long pos = index * sizeof(MetaData) + sizeof(int32_t);

    buffer[index].status = newTag;

    fseek( fState, pos, SEEK_SET );
    fwrite( &newTag, sizeof(int32_t), 1, fState );
  };

  /*
   *  Normal case: we found a new job to do.
   *	We just want to check whether it is a normal
   *	job or a finalizing job.
   */

  //mexPrintf("blockID:\t%d\nstate:\t\t%d\n",blockID,state);

  switch(state)
  {
    case 0:
      if(blockID > 0)
      {
        /*
         *	Normal case:
         *	- regular job found
         *	- tell the world we'll take care of it
         */
        updateTag( blockID, 1 );
      }
      else
      {
        /*
         * 	Finalize task:
         * 	- the first available job is the last one (finalization)
         *	- make sure all other jobs have been completed and not just booked
         *	- tell the workd we'll take care of this task
         */
        for( auto const & md : buffer )
        {
          if( md.blockID != -1 && md.status != 2 )
          {
            // This case happens when all work has been assigned but not finished yet,
            // so this job should just do nothing (the MATLAB code will sleep)
            //
            // eventually, this case should fire and make it through the entire loop
            // leading to blockID == FINALIZE_JOB
            blockID = NO_WORK;
            break;
          }
        }

        if(blockID == FINALIZE_JOB)
        {
          updateTag( blockID, 1 );
        }
      }
      break;
    case 2:
      blockID = JOB_DONE;
      break;
    default:
      blockID = NO_WORK;
      break;
  }

  fclose(fState);
  while(releaseLock(fLock) != LOCK_SUCCESS) sleep(1);
  return blockID;
}

int reportWork(const char *stateFileName, int fLock, int finishedBlockID)
{
  FILE *fState;

  if(acquireLock(fLock) == LOCK_FAIL) return REPORT_FAIL;

  if((fState = fopen(stateFileName, "r+")) == NULL)
  {
    mexPrintf("Unable to read stateFile\n");
    fState = NULL;
    return REPORT_FAIL;
  }

  auto updateTag = [&]( int32_t blockID, int32_t newTag )
  {
    const long pos = (blockID - 1) * sizeof(MetaData) + sizeof(int32_t);

    fseek( fState, pos, SEEK_SET );
    fwrite( &newTag, sizeof(int32_t), 1, fState );
  };

  updateTag( finishedBlockID, 2 );
  fclose( fState );

  while(releaseLock(fLock) != LOCK_SUCCESS) sleep(1);
  return REPORT_SUCCESS;
}
