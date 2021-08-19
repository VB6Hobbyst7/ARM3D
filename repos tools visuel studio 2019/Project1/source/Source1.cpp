#if __INTELLISENSE__
typedef unsigned int __SIZE_TYPE__;
typedef unsigned long __PTRDIFF_TYPE__;
#define __attribute__(q)
#define __builtin_strcmp(a,b) 0
#define __builtin_strlen(a) 0
#define __builtin_memcpy(a,b) 0
#define __builtin_va_list void*
#define __builtin_va_start(a,b)
#define __extension__
#endif

#if defined(_MSC_VER)
#include <BaseTsd.h>
typedef SSIZE_T ssize_t;
#endif

#include <malloc.h>
#include <switch.h>
#include <iostream>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include"StSoundLibrary.h"
#include"SwedishNewYear90ym.h"

#define SAMPLERATE 48000
#define CHANNELCOUNT 2
#define FRAMERATE 50
#define SAMPLECOUNT (SAMPLERATE / FRAMERATE)
#define BYTESPERSAMPLE 2

int main(int argc, char* argv[])
{
    consoleInit(NULL);

    // Other initialization goes here. As a demonstration, we print hello world.
    std::cout << "Hello World!\n" << std::endl;

    bool res = 0;
    printf("Loading music \"%s\"...\n", argv[1]);
    YMMUSIC* pMusic = ymMusicCreate();

    res = ymMusicLoadMemory(pMusic, (void *)&SwedishNewYear90ym, SwedishNewYear90ym_size);
    printf("res de YM music load : %x\n", res);

    ymMusicInfo_t info;
    ymMusicGetInfo(pMusic, &info);
    printf("Name.....: %s\n", info.pSongName);
    printf("Author...: %s\n", info.pSongAuthor);
    printf("Comment..: %s\n", info.pSongComment);
    printf("Duration.: %d:%02d\n", info.musicTimeInSec / 60, info.musicTimeInSec % 60);
    printf("Driver...: %s\n", info.pSongPlayer);

    ymMusicSetLoopMode(pMusic, YMTRUE);
    ymMusicPlay(pMusic);

    // Make sure the sample buffer size is aligned to 0x1000 bytes.
    uint32_t data_size = (SAMPLECOUNT * CHANNELCOUNT * BYTESPERSAMPLE);
    uint32_t buffer_size = (data_size + 0xfff) & ~0xfff;
    int nbSample = buffer_size / sizeof(ymsample);
    void* out_buf_data1 = aligned_alloc(buffer_size * 4, 0x1000);

    printf("pointeur buffer : %x\n", out_buf_data1);
    printf("pointeur struc music : %x\n", pMusic);
    ymMusicCompute(pMusic, (ymsample*)out_buf_data1, 40);


    // Main loop
    while (appletMainLoop())
    {
        // Scan all the inputs. This should be done once for each frame
        hidScanInput();

        // hidKeysDown returns information about which buttons have been
        // just pressed in this frame compared to the previous one
        u64 kDown = hidKeysDown(CONTROLLER_P1_AUTO);

        if (kDown & KEY_A)
            std::cout << "Pressed A button!\n" << std::endl;

        if (kDown & KEY_PLUS)
            break; // break in order to return to hbmenu

        // Your code goes here

        // Update the console, sending a new frame to the display
        consoleUpdate(NULL);
    }

    // Deinitialize and clean up resources used by the console (important!)
    consoleExit(NULL);
    return 0;
}