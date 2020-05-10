//
//  yuv420torgb24.h
//  IOTCamera
//
//  Created by Cloud Hsiao on 12/8/13.
//
//

#ifndef IOTCamera_my_yuv420torgb24_h
#define IOTCamera_my_yuv420torgb24_h

#ifdef __cplusplus
extern "C" {
#endif
    
void my_yuv420torgb24_c_init();
void  my_yuv420torgb24_c(unsigned char *src0, int stride_y,
					  unsigned char *src1, unsigned char *src2, int stride_uv,
					  unsigned char *dst_ori, int width, int height);
#ifdef __cplusplus
}
#endif

#endif
