//  H265DecoderDemo

#import <UIKit/UIKit.h>

//#import "AppDelegate.h"
#import "DemoMain_IOS.h"
#import <mach/mach_time.h>

INT32 g_MallocCnt  = 0;
INT32 g_MallocSize = 0;
INT32 g_FreeCnt    = 0;

//void *HW265D_Malloc(UINT32 channel_id, UINT32 size)
//{
//    g_MallocCnt++;
//    g_MallocSize += size;
//    
//    return (void *)malloc(size);
//}
//
//void HW265D_Free(UINT32 channel_id, void * ptr)
//{
//    g_FreeCnt++;
//    free(ptr);
//}
//
//void HW265D_Log( UINT32 channel_id, IHWVIDEO_ALG_LOG_LEVEL eLevel, INT8 *p_msg, ...)
//{
//#ifndef TEST_SPEED
//    UINT8 OutLog[MAX_FILE_PATH];
//    //FILE *fp_log = stderr;//fopen("H265D_Log.txt", "a+");
//    NSArray  *pathout = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *docDir = [pathout objectAtIndex:0];
//    //NSLog(@"outdir path: %@\n", docDir);
//    strcpy((char *)OutLog, (const char *)[docDir UTF8String]);
//    strcat((char *)OutLog, "/H265D_Log.txt");
//    
//    FILE *fp_log = fopen((char *)OutLog, "a+");
//    if ( NULL == fp_log )
//    {
//        return;
//    }
//    
//    if(eLevel <= IHWVIDEO_ALG_LOG_INFO)
//    {
//        const INT8 *psz_prefix;
//        
//        va_list arg;
//        va_start( arg, p_msg );
//        
//        switch(eLevel)
//        {
//            case IHWVIDEO_ALG_LOG_ERROR:
//                psz_prefix = (INT8 *)"err";  // error
//                break;
//            case IHWVIDEO_ALG_LOG_WARNING:
//                psz_prefix = (INT8 *)"wrn";  // warning
//                break;
//            case IHWVIDEO_ALG_LOG_INFO:
//                psz_prefix = (INT8 *)"inf";  // info
//                break;
//            case IHWVIDEO_ALG_LOG_DEBUG:
//                psz_prefix = (INT8 *)"dbg";  // debug
//                break;
//            default:
//                psz_prefix = (INT8 *)"und";  // undefine
//                break;
//        }
//        
//        fprintf(fp_log, "[%s] channel = %#X: ", psz_prefix, channel_id);
//        vfprintf(fp_log, (const char *)p_msg, arg);
//        
//        va_end(arg);
//        fflush(fp_log);
//    }
//    
//    if (fp_log)
//    {
//        fclose(fp_log);
//    }
//#endif
//    return;
//}

INT32 H265DecLoadAU(UINT8* pStream, UINT32 iStreamLen, UINT32* pFrameLen) 
{ 
    UINT32 i; 
    UINT32 state = 0xffffffff; 
    BOOL32 bFrameStartFound=0;
	BOOL32 bSliceStartFound = 0;

    *pFrameLen = 0;
    if( NULL == pStream || iStreamLen <= 4) 
    {  
        return -1; 
    }

    for( i = 0; i < iStreamLen; i++) 
    { 
        if( (state & 0xFFFFFF7E) >= 0x100 &&
            (state & 0xFFFFFF7E) <= 0x13E )
        { 
            if( 1 == bFrameStartFound || bSliceStartFound == 1 ) 
            { 
                if( (pStream[i+1]>>7) == 1)
                { 
                    *pFrameLen = i - 4; 
                    return 0;
                }
            } 
            else 
            { 
				bSliceStartFound = 1;
                //bFrameStartFound = 1; 
            } 
        } 

        /*find a vps, sps, pps*/ 
        if( (state&0xFFFFFF7E) == 0x140 || 
            (state&0xFFFFFF7E) == 0x142 || 
            (state&0xFFFFFF7E) == 0x144)
        { 
			if (1 == bSliceStartFound)
			{
				bSliceStartFound = 1;
			}
            else if(1 == bFrameStartFound) 
            { 
                *pFrameLen = i - 4;
                return 0; 
            } 
            else 
            { 
                bFrameStartFound = 1; 
            } 
        } 

        state = (state << 8) | pStream[i];
    } 

    *pFrameLen = i; 
    return -1;
}

//INT32 Demo_DecFrame( H265D_DEMO_PARAM *pstDecParam)
//{
//    FILE *fpInFile = NULL;
//    FILE *fpOutFile = NULL;
//    INT32 iFileLen;
//    UINT8 *pInputStream = NULL, *pStream;
//    IHW265D_INIT_PARAM stInitParam = {0};
//    INT32 iRet = 0;
//    IH265DEC_HANDLE hDecoder = NULL;
//    IHWVIDEO_ALG_VERSION_STRU stVersion;
//    BOOL32 bStreamEnd = 0;
//    IH265DEC_INARGS stInArgs;
//    IH265DEC_OUTARGS stOutArgs = {0};
//    UINT32 iFrameIdx = 0;
//    uint64_t startTime = 0;
//    uint64_t endTime = 0;
//    uint64_t elapsedTime = 0;
//    uint64_t elapsedTimeNano = 0;
//
//    //inputfile
//    NSArray *inputpath = [[NSBundle mainBundle] pathsForResourcesOfType:(@"bin") inDirectory:(@"input")];
//
//    INT32 count = [inputpath count];
//#ifndef TEST_SPEED
//    NSLog(@"infile count: %d\n", count);
//    if(count == 0)
//    {
//        return 0;
//    }
//#endif
//
//    NSString *path = [inputpath objectAtIndex:(0)];
//#ifndef TEST_SPEED
//    NSLog(@"infile path: %@\n", path);
//#endif
//
//    strcpy((char *)pstDecParam->szInFileName, (const char *)[path UTF8String]);
//#ifndef TEST_SPEED
//    printf("InPutName :%s\n",pstDecParam->szInFileName);
//#endif
//
//    //outputfile
//    NSArray  *pathout = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *docDir = [pathout objectAtIndex:0];
//    //NSLog(@"outdir path: %@\n", docDir);
//    strcpy((char *)pstDecParam->szOutFileName, (const char *)[docDir UTF8String]);
//    strcat((char *)pstDecParam->szOutFileName, "/test.yuv");
//#ifndef TEST_SPEED
//    printf("OutPutName :%s\n",pstDecParam->szOutFileName);
//#endif
//
//    //openfiles
//    if(!strcmp(pstDecParam->szInFileName, "\0") || NULL == (fpInFile = fopen(pstDecParam->szInFileName, "rb")))
//    {
//        fprintf(stderr, "ERROR: Open input file %s failed.\n", pstDecParam->szInFileName);
//        goto CLEAN;
//    }
//
//    if(!strcmp(pstDecParam->szOutFileName, "\0") || NULL == (fpOutFile = fopen(pstDecParam->szOutFileName, "wb")))
//    {
//        fprintf(stderr, "ERROR: Open input file %s failed.\n", pstDecParam->szOutFileName);
//        goto CLEAN;
//    }
//
//    fseek( fpInFile, 0, SEEK_END);
//    iFileLen = ftell( fpInFile);
//    fseek( fpInFile, 0, SEEK_SET);
//
//    pInputStream = malloc(iFileLen);
//    //    pInputStream = malloc(INBUFSIZE);
//    if (pInputStream == NULL)
//    {
//        fprintf(stderr, "ERROR: Malloc pInputStream memory Failed!\n");
//        goto CLEAN;
//    }
//
//    mach_timebase_info_data_t timeBaseInfo;
//    mach_timebase_info(&timeBaseInfo);
//
//    /*create decode handle*/
//    {
//        stInitParam.uiChannelID = 0;
//        stInitParam.iMaxWidth  = pstDecParam->iMaxWidth;
//        stInitParam.iMaxHeight = pstDecParam->iMaxHeight;
//        stInitParam.iMaxRefNum = pstDecParam->iMaxRefNum;
//        stInitParam.iMaxVPSNum = pstDecParam->iMaxVPSNum;
//        stInitParam.iMaxSPSNum = pstDecParam->iMaxSPSNum;
//        stInitParam.iMaxPPSNum = pstDecParam->iMaxPPSNum;
//        stInitParam.uiBitDepth = pstDecParam->uiBitDepth;
//
//        stInitParam.eThreadType = (HW265D_THREADTYPE)pstDecParam->iThreadType;
//        stInitParam.eOutputOrder= IH265D_DISPLAY_ORDER;
//        //stInitParam.eOutputOrder= IH265D_DECODE_ORDER;
//
//        stInitParam.MallocFxn  = HW265D_Malloc;
//        stInitParam.FreeFxn    = HW265D_Free;
//        stInitParam.LogFxn     = HW265D_Log;
//    }
//#ifndef TEST_SPEED
//    fprintf(stdout, "=======================H265_Decoder=======================\n");
//    IHW265D_GetVersion(&stVersion);
//    fprintf(stderr, "CODEC version    : %s\n", stVersion.cVersionChar);
//    fprintf(stderr, "CompileVersion   : %d\n", stVersion.uiCompileVersion);
//    fprintf(stderr, "Release time     : %s\n", stVersion.cReleaseTime);
//    fprintf(stdout, "Input  file name : %s\n", pstDecParam->szInFileName);
//    fprintf(stdout, "Output file name : %s\n", pstDecParam->szOutFileName);
//    fprintf(stdout, "==========================================================\n");
//#endif
//    iRet = IHW265D_Create(&hDecoder, &stInitParam);
//
//    if (iRet != IHW265D_OK)
//    {
//        fprintf(stderr, "ERROR: IHW265D_Create failed!\n");
//        goto CLEAN;
//    }
//
//    //read stream
//    if (1 > fread(pInputStream, 1, iFileLen, fpInFile))
//    {
//        fprintf(stderr, "ERROR: Read input file %s failed.\n", pstDecParam->szInFileName);
//        goto CLEAN;
//    }
//#ifdef TEST_LONG
//    INT32 iLenght;
//    iLenght = iFileLen;
//    while(1)
//    {
//
//        iFileLen = iLenght;
//        elapsedTimeNano = 0;
//        iFrameIdx = 0;
//        bStreamEnd = 0;
//#endif
//    pStream = pInputStream;
//    while(!bStreamEnd)
//    {
//        INT32 iNaluLen;
//        H265DecLoadAU(pStream, iFileLen, &iNaluLen);
//
//        stInArgs.eDecodeMode =  iNaluLen>0 ? IH265D_DECODE : IH265D_DECODE_END; // same to hisi uFlags
//        stInArgs.pStream = pStream;
//        stInArgs.uiStreamLen = iNaluLen;
//
//        pStream += iNaluLen;
//        iFileLen-= iNaluLen;
//
//        stOutArgs.eDecodeStatus = -1;
//        stOutArgs.uiBytsConsumed = 0;
//
//        // if return value is need more bits, then read more bits
//        while(stOutArgs.eDecodeStatus != IH265D_NEED_MORE_BITS)
//        {
//            // decoder is empty, exit form the loop, decode is over
//            if(stOutArgs.eDecodeStatus == IH265D_NO_PICTURE)
//            {
//                bStreamEnd = 1;
//                break;
//            }
//            // display decode picture
//            if (stOutArgs.eDecodeStatus == IH265D_GETDISPLAY)
//            {
//#ifndef TEST_SPEED
//                //write out yuv
//                if (fpOutFile != NULL && stOutArgs.uiLayerIdx == 0)
//                {
//                    UINT32 i;
//                    UINT32 j;
//                    UINT8 Const_0[1] ={0} ;
//                    if (TRUE != pstDecParam->bCheckMd5)
//                    {
//                        if(stOutArgs.uiBitDepthY == 8)
//                        {
//                            if(stOutArgs.uiBitDepthC == 8)
//                            {
//                                for (i=0;i<stOutArgs.uiDecHeight;i++)
//                                {
//                                    fwrite(stOutArgs.pucOutYUV[0]+i*stOutArgs.uiYStride, 1, stOutArgs.uiDecWidth, fpOutFile);
//                                }
//                            }
//                            else
//                            {
//                                for (i=0;i<stOutArgs.uiDecHeight;i++)
//                                {
//                                    for(j=0;j<stOutArgs.uiDecWidth;j++)
//                                    {
//                                        fwrite(stOutArgs.pucOutYUV[0]+i*stOutArgs.uiYStride+j, 1, 1, fpOutFile);
//                                        fwrite(Const_0, 1, 1, fpOutFile);
//                                    }
//                                }
//                            }
//                        }
//                        else
//                        {
//                            for (i=0;i<stOutArgs.uiDecHeight;i++)
//                            {
//                                fwrite(stOutArgs.pucOutYUV[0]+i*stOutArgs.uiYStride*sizeof(INT16), 1, stOutArgs.uiDecWidth*sizeof(INT16), fpOutFile);
//                            }
//                        }
//                        if(stOutArgs.uiBitDepthC == 8)
//                        {
//                            if(stOutArgs.uiBitDepthY == 8)
//                            {
//                                for (i=0;i<((stOutArgs.uiDecHeight)>>1);i++)
//                                {
//                                    fwrite(stOutArgs.pucOutYUV[1]+i*stOutArgs.uiUVStride, 1, (stOutArgs.uiDecWidth>>1), fpOutFile);
//                                }
//                                for (i=0;i<((stOutArgs.uiDecHeight)>>1);i++)
//                                {
//                                    fwrite(stOutArgs.pucOutYUV[2]+i*stOutArgs.uiUVStride, 1, (stOutArgs.uiDecWidth>>1), fpOutFile);
//                                }
//                            }
//                            else
//                            {
//                                for (i=0;i<((stOutArgs.uiDecHeight)>>1);i++)
//                                {
//                                    for(j=0;j<((stOutArgs.uiDecWidth)>>1);j++)
//                                    {
//                                        fwrite(stOutArgs.pucOutYUV[1]+i*stOutArgs.uiUVStride+j, 1, 1, fpOutFile);
//                                        fwrite(Const_0, 1, 1, fpOutFile);
//                                    }
//                                }
//                                for (i=0;i<((stOutArgs.uiDecHeight)>>1);i++)
//                                {
//                                    for(j=0;j<((stOutArgs.uiDecWidth)>>1);j++)
//                                    {
//                                        fwrite(stOutArgs.pucOutYUV[2]+i*stOutArgs.uiUVStride+j, 1, 1, fpOutFile);
//                                        fwrite(Const_0, 1, 1, fpOutFile);
//                                    }
//                                }
//                            }
//                        }
//                        else
//                        {
//                            for (i=0;i<((stOutArgs.uiDecHeight)>>1);i++)
//                            {
//                                fwrite(stOutArgs.pucOutYUV[1]+i*stOutArgs.uiUVStride*sizeof(INT16), 1, (stOutArgs.uiDecWidth>>1)*sizeof(INT16), fpOutFile);
//                            }
//                            for (i=0;i<((stOutArgs.uiDecHeight)>>1);i++)
//                            {
//                                fwrite(stOutArgs.pucOutYUV[2]+i*stOutArgs.uiUVStride*sizeof(INT16), 1, (stOutArgs.uiDecWidth>>1)*sizeof(INT16), fpOutFile);
//                            }
//                        }
//                    }
//                    else //更新MD5值：
//                    {
//                        for (i = 0; i < stOutArgs.uiDecHeight; i++)
//                        {
//                            MD5Update (&context, stOutArgs.pucOutYUV[0]+i*stOutArgs.uiYStride, stOutArgs.uiDecWidth);
//                        }
//
//                        for (i = 0; i < ((stOutArgs.uiDecHeight)>>1); i++)
//                        {
//                            MD5Update (&context, stOutArgs.pucOutYUV[1]+i*stOutArgs.uiUVStride, stOutArgs.uiDecWidth>>1);
//                        }
//
//                        for (i = 0; i < ((stOutArgs.uiDecHeight)>>1); i++)
//                        {
//                            MD5Update (&context, stOutArgs.pucOutYUV[2]+i*stOutArgs.uiUVStride, stOutArgs.uiDecWidth>>1);
//                        }
//                    }
//
//                }
//
//                if (fpOutFileIL != NULL && stOutArgs.uiLayerIdx == 1)
//                {
//                    UINT32 i;
//                    if (TRUE != pstDecParam->bCheckMd5)
//                    {
//                        for (i=0;i<stOutArgs.uiDecHeight;i++)
//                        {
//                            fwrite(stOutArgs.pucOutYUV[0]+i*stOutArgs.uiYStride, 1, stOutArgs.uiDecWidth, fpOutFileIL);
//                        }
//                        for (i=0;i<((stOutArgs.uiDecHeight)>>1);i++)
//                        {
//                            fwrite(stOutArgs.pucOutYUV[1]+i*stOutArgs.uiUVStride, 1, stOutArgs.uiDecWidth>>1, fpOutFileIL);
//                        }
//                        for (i=0;i<((stOutArgs.uiDecHeight)>>1);i++)
//                        {
//                            fwrite(stOutArgs.pucOutYUV[2]+i*stOutArgs.uiUVStride, 1, stOutArgs.uiDecWidth>>1, fpOutFileIL);
//                        }
//                    }
//                    else //更新MD5值：
//                    {
//                        for (i = 0; i < stOutArgs.uiDecHeight; i++)
//                        {
//                            MD5Update (&context, stOutArgs.pucOutYUV[0]+i*stOutArgs.uiYStride, stOutArgs.uiDecWidth);
//                        }
//
//                        for (i = 0; i < ((stOutArgs.uiDecHeight)>>1); i++)
//                        {
//                            MD5Update (&context, stOutArgs.pucOutYUV[1]+i*stOutArgs.uiUVStride, stOutArgs.uiDecWidth>>1);
//                        }
//
//                        for (i = 0; i < ((stOutArgs.uiDecHeight)>>1); i++)
//                        {
//                            MD5Update (&context, stOutArgs.pucOutYUV[2]+i*stOutArgs.uiUVStride, stOutArgs.uiDecWidth>>1);
//                        }
//                    }
//
//                }
//
//#endif
////                printf("frame index %6d\r", iFrameIdx);
//                iFrameIdx++;
//#if 0
//                if(iFrameIdx == 5)
//                {
//                    bStreamEnd = 1;
//                    break;
//                }
//#endif
//
//            }
//
//            // decode the undecode bits in the last
//            {
//                // input pointer equal the undecoded stream start positon
//                stInArgs.pStream += stOutArgs.uiBytsConsumed;
//                stInArgs.uiStreamLen -= stOutArgs.uiBytsConsumed;
//                startTime = mach_absolute_time();
//                iRet = IHW265D_DecodeFrame(hDecoder, &stInArgs, &stOutArgs);
//                endTime = mach_absolute_time();
//                elapsedTime = endTime - startTime;
//                elapsedTimeNano += elapsedTime * timeBaseInfo.numer / timeBaseInfo.denom;
//
//                if ((iRet != IHW265D_OK) && (iRet != IHW265D_NEED_MORE_BITS))
//                {
//                    fprintf(stderr, "ERROR: IHW265D_DecodeFrame failed!\n");
//
//                     if (0 == iFileLen)
//                    {
//                        bStreamEnd = 1;
//                    }
//                    break;
//                    //                    goto CLEAN;
//                }
//            }
//        }
//    }
//
//    printf("time = %4f fps\n",(FLOAT32)(iFrameIdx*1000000)/(elapsedTimeNano/1000));
//#ifdef TEST_LONG
//    }
//#endif
//CLEAN:
//    if (hDecoder != NULL)
//    {
//        IHW265D_Delete(hDecoder);
//    }
//    if(fpInFile != NULL)
//    {
//        fclose(fpInFile);
//    }
//    if(fpOutFile != NULL)
//    {
//        fclose(fpOutFile);
//    }
//    if(pInputStream!=NULL)
//    {
//        free(pInputStream);
//    }
//    if (g_MallocCnt != g_FreeCnt)
//    {
//        fprintf(stderr, "warning; there is some memory leak!\n");
//    }
//#ifndef TEST_SPEED
//    NSLog(@"Success!\n");
//#endif
//    return 1;
//}
////INT32 AddSum();
//int main_demo(int argc, char * argv[])
//{
//    H265D_DEMO_PARAM stDecParam={0};
//      //
//    //Initial
//    stDecParam.bDisplayEnable = FALSE;
//    stDecParam.iMaxWidth  = 1920;
//    stDecParam.iMaxHeight = 1080;
//    stDecParam.iMaxRefNum = 15;
//    stDecParam.bCheckMd5  = FALSE;
//    stDecParam.eDecMode   = DECODE_FRAME;
//    stDecParam.iMaxVPSNum = 16;
//    stDecParam.iMaxSPSNum = 16;
//    stDecParam.iMaxPPSNum = 64;
//    stDecParam.uiBitDepth = 10;
//#ifndef TEST_MULTITHREAD
//    stDecParam.iThreadType = 0;//signal thread
//#else
//    stDecParam.iThreadType = 1;//multithread
//#endif
//
//    if (DECODE_FRAME == stDecParam.eDecMode)
//    {
//        Demo_DecFrame(&stDecParam);
//        //INT32 i;
//        //i=AddSum();
//    }
//    else
//    {
//        fprintf(stderr, "ERROR: please enter the correct decoding mode!\n");
//    }
//
//    exit(0);
//    @autoreleasepool {
//        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
//    }
//}
