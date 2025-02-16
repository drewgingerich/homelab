# Troubleshooting Plex hardware transcoding 

While streaming a 1080p video to a Plex browser client,
Plex uses all four cores of my server's CPU.
It's not the fastest CPU, but that's still a ton of utilization.
My first thought is that there must be an issue with the hardware transcoding.

I start by getting the encoding of the video file:

```sh
$ mediainfo <video_file_path>
...
Video
ID                                       : 1
Format                                   : HEVC
Format/Info                              : High Efficiency Video Coding
Format profile                           : Main 10@L4@Main
HDR format                               : Dolby Vision, Version 1.0, dvhe.08.03, BL+RPU, HDR10 compatible / SMPTE ST 2086, HDR10 compatible
Codec ID                                 : V_MPEGH/ISO/HEVC
Duration                                 : 40 min 15 s
Bit rate                                 : 5 385 kb/s
Width                                    : 1 920 pixels
Height                                   : 1 080 pixels
Display aspect ratio                     : 16:9
Frame rate mode                          : Constant
Frame rate                               : 24.000 FPS
Color space                              : YUV
Chroma subsampling                       : 4:2:0 (Type 2)
Bit depth                                : 10 bits
Bits/(Pixel*Frame)                       : 0.108
Stream size                              : 1.51 GiB (87%)
Default                                  : Yes
Forced                                   : No
Color range                              : Limited
Color primaries                          : BT.2020
Transfer characteristics                 : PQ
Matrix coefficients                      : BT.2020 non-constant
Mastering display color primaries        : Display P3
Mastering display luminance              : min: 0.0001 cd/m2, max: 1000 cd/m2
Maximum Content Light Level              : 941 cd/m2
Maximum Frame-Average Light Level        : 176 cd/m2
...
```

Based on the Intel Quicksync wikipedia page,
my CPU is too old to encode 10-bit HEVC.

https://en.wikipedia.org/wiki/Intel_Quick_Sync_Video

So, playing this video is using software transcoding.
It makes sense that the performance is abysmal,
and there's not much I can do about it.

