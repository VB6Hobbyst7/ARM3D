// Include the most common headers from the C standard library
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Include the main libnx system header, for Switch development
#include <switch.h>

#include"StSoundLibrary.h"
#include"SwedishNewYear90ym_bin.h"

static	volatile	YMMUSIC			*	s_pMusic = NULL;

#define SAMPLERATE 48000
#define CHANNELCOUNT 2
#define FRAMERATE 50
#define SAMPLECOUNT (SAMPLERATE / FRAMERATE)
#define BYTESPERSAMPLE 2

// Main program entrypoint
int main(int argc, char* argv[])
{
    // This example uses a text console, as a simple way to output text to the screen.
    // If you want to write a software-rendered graphics application,
    //   take a look at the graphics/simplegfx example, which uses the libnx Framebuffer API instead.
    // If on the other hand you want to write an OpenGL based application,
    //   take a look at the graphics/opengl set of examples, which uses EGL instead.
    consoleInit(NULL);

    // Configure our supported input layout: a single player with standard controller styles
    padConfigureInput(1, HidNpadStyleSet_NpadStandard);

    // Initialize the default gamepad (which reads handheld mode inputs as well as the first connected controller)
    PadState pad;
    padInitializeDefault(&pad);

    // Other initialization goes here. As a demonstration, we print hello world.
    printf("Hello World!\n");

	printf("Loading music \"%s\"...\n",argv[1]);
    YMMUSIC *pMusic = ymMusicCreate();
	
	uint8_t  *pointeur_ym = &SwedishNewYear90ym_bin;
	
	printf("pointeur : %x\n", pointeur_ym);
	printf("ym direct : %x\n", SwedishNewYear90ym_bin);
    ymMusicLoadMemory(pMusic, pointeur_ym,SwedishNewYear90ym_bin_size);

	ymMusicInfo_t info;
	ymMusicGetInfo(pMusic,&info);
	printf("Name.....: %s\n",info.pSongName);
	printf("Author...: %s\n",info.pSongAuthor);
	printf("Comment..: %s\n",info.pSongComment);
	printf("Duration.: %d:%02d\n",info.musicTimeInSec/60,info.musicTimeInSec%60);
	printf("Driver...: %s\n", info.pSongPlayer);
		
	ymMusicSetLoopMode(pMusic,YMTRUE);
	ymMusicPlay(pMusic);
	
	// Make sure the sample buffer size is aligned to 0x1000 bytes.
    u32 data_size = (SAMPLECOUNT * CHANNELCOUNT * BYTESPERSAMPLE);
    u32 buffer_size = (data_size + 0xfff) & ~0xfff;
	int nbSample = buffer_size / sizeof(ymsample);
	u8* out_buf_data1 = memalign(0x1000, buffer_size*2);
	
	printf("pointeur buffer : %x\n", out_buf_data1);
	printf("pointeur struc music : %x\n", pMusic);
	// ymMusicCompute(pMusic,out_buf_data1,2);
	
	// Main loop
    while (appletMainLoop())
    {
        // Scan the gamepad. This should be done once for each frame
        padUpdate(&pad);

        // padGetButtonsDown returns the set of buttons that have been
        // newly pressed in this frame compared to the previous one
        u64 kDown = padGetButtonsDown(&pad);

        if (kDown & HidNpadButton_Plus)
            break; // break in order to return to hbmenu

        // Your code goes here

        // Update the console, sending a new frame to the display
        consoleUpdate(NULL);
    }

    // Deinitialize and clean up resources used by the console (important!)
    consoleExit(NULL);
	ymMusicStop(pMusic);
	ymMusicDestroy(pMusic);
    return 0;
}
