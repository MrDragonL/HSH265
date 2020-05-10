
#ifndef __DEMOMAIN_H__  /* Macro sentry to avoid redundant including */
#define __DEMOMAIN_H__

#ifdef __cplusplus
extern "C"{
#endif 

#include "IHWVideo_Typedef.h"
#include "IHW265Dec_Api.h"
//#define TEST_SPEED
//#define TEST_LONG
#define TEST_MULTITHREAD
#define COUNT_SINGLE_FRAME_TIME_IOS 0
#define HW_INT64_MAX_TIME 0x7fffffffffffffff
#define MAX_LINE_LEN    256
#define MAX_FILE_PATH   256

typedef enum
{
    DECODE_FRAME = 0,
    DECODE_AU = 1,
    DECODE_ERR_BITS_TEST = 2,	// error code test, insert error code, control by macro
	DECODE_COMPATIBILITY = 3,	// compatibility test, compare the test stream's MD5 with the right MD5 for all stream in order
	DECODE_THREAD_TEST = 4,
}DECODE_MODE;

// typedef struct for many video files testing.
typedef struct 
{
    INT8   szInFileName[MAX_FILE_PATH];  
    INT8   szOutFileName[MAX_FILE_PATH];
    BOOL32 bDisplayEnable;
    INT32  iMaxWidth;
    INT32  iMaxHeight;
    INT32  iMaxRefNum;
    INT32  iMaxVPSNum;
    INT32  iMaxSPSNum;
    INT32  iMaxPPSNum;
    
    UINT32  uiBitDepth;
    BOOL32 bCheckMd5;
    DECODE_MODE eDecMode;
	INT32  iThreadType;           // thread type : 0 for single thread, 1 for multi thread

    FILE *fpRecon;                //file to store reconstruct frames
    FILE *fpStream;                //file to store output stream
    FILE *fpLog;                  //log file pointer
}H265D_DEMO_PARAM;





#ifdef __cplusplus
}
#endif  /* __cplusplus */

#endif  /* __DEMOMAIN_H__ */

