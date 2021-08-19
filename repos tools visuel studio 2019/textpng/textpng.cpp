// textpng.cpp : Ce fichier contient la fonction 'main'. L'exécution du programme commence et se termine à cet endroit.
//

#include <iostream>

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include <fstream>
#include <iterator>
#include <algorithm>

#include <cstdint> 

#include "FreeImage.h"



// ----------------------------------------------------------

/**
	FreeImage error handler
	@param fif Format / Plugin responsible for the error
	@param message Error message
*/
void FreeImageErrorHandler(FREE_IMAGE_FORMAT fif, const char* message) {
	printf("\n*** ");
	if (fif != FIF_UNKNOWN) {
		printf("%s Format\n", FreeImage_GetFormatFromFIF(fif));
	}
	printf(message);
	printf(" ***\n");
}

// ----------------------------------------------------------

unsigned DLL_CALLCONV
myReadProc(void* buffer, unsigned size, unsigned count, fi_handle handle) {
	return fread(buffer, size, count, (FILE*)handle);
}

unsigned DLL_CALLCONV
myWriteProc(void* buffer, unsigned size, unsigned count, fi_handle handle) {
	return fwrite(buffer, size, count, (FILE*)handle);
}

int DLL_CALLCONV
mySeekProc(fi_handle handle, long offset, int origin) {
	return fseek((FILE*)handle, offset, origin);
}

long DLL_CALLCONV
myTellProc(fi_handle handle) {
	return ftell((FILE*)handle);
}

#ifdef _MSC_VER
#define _CRT_SECURE_NO_WARNINGS
#endif

#pragma warning(disable:4996)

int main()
{
#ifdef _MSC_VER
#define _CRT_SECURE_NO_WARNINGS
#endif

	// initialize your own FreeImage error handler

	FreeImage_SetOutputMessage(FreeImageErrorHandler);

	// print version & copyright infos

	printf(FreeImage_GetVersion());
	printf("\n");
	printf("\n");

	char nomfichier[] = "C:/Users/Eric/projects/tectech/data/fontverticale1614.png";

	// initialize your own IO functions

	FreeImageIO io;

	io.read_proc = myReadProc;
	io.write_proc = myWriteProc;
	io.seek_proc = mySeekProc;
	io.tell_proc = myTellProc;

	FILE* file = fopen(nomfichier, "rb");

	if (file != NULL) {
		// find the buffer format
		FREE_IMAGE_FORMAT fif = FreeImage_GetFileTypeFromHandle(&io, (fi_handle)file, 0);

		if (fif != FIF_UNKNOWN) {
			// load from the file handle
			FIBITMAP* dib = FreeImage_LoadFromHandle(fif, &io, (fi_handle)file, 0);

			FIBITMAP* src = FreeImage_ConvertTo32Bits(dib);

			int bpp = FreeImage_GetBPP(src);
			printf("bits par pixel : %X\n", bpp);

			FREE_IMAGE_TYPE fit = FreeImage_GetImageType(src);
			printf("fit : %X %X pas : %X\n", fit, FIT_BITMAP, FIT_RGBA16);

			int width1 = FreeImage_GetWidth(src);
			printf("width1 : %d \n", width1);
			int height1 = FreeImage_GetHeight(src);
			printf("height1 : %d \n", height1);

			int scan_width1 = FreeImage_GetPitch(src);
			printf("scan_width1 : %d \n", scan_width1);

			BYTE* bufferimage = (BYTE*)malloc(height1 * scan_width1);
			FreeImage_ConvertToRawBits(bufferimage, dib, scan_width1, bpp, FI_RGBA_RED_MASK, FI_RGBA_GREEN_MASK, FI_RGBA_BLUE_MASK, TRUE);



			std::uint32_t* pointeurbufferu32 = (std::uint32_t*) bufferimage;

			BYTE* bufferimagedest = (BYTE*)malloc(8*15*10*16*4);
			memset(bufferimagedest, 0, 8 * 15 * 10 * 16 * 4);
			std::uint32_t* pointeurbufferu32dest = (std::uint32_t*)bufferimagedest;

			printf("octet 0 : %X\n", pointeurbufferu32[0]);
			printf("octet 0 : %X\n", pointeurbufferu32[1]);

			int pos_source = 0;
			for (int y = 0; y < 8; y++)
			{
				for (int x = 0; x < 10; x++)
				{
					for (int lignes = 0; lignes < 14;lignes++)

					{
						for (int colonnes = 0; colonnes < 16; colonnes++)
						{
							std::uint32_t pixel = pointeurbufferu32[colonnes + (lignes * 16 * 10 ) + (x * 16 ) + (y * 16 * 10 *14 )];
							pointeurbufferu32dest[(colonnes) + ((lignes) * 16 * 10 ) + (x * 16 ) + (y * 16 * 10 * 15)] = pixel;

						}
					}
				}
				for (int x = 0; x < 160; x++)
				{
					pointeurbufferu32dest[(y * 16 * 10 * 15) + x + (16*10*14)] = 0xFF000000;
				}
			}
			



			// FIBITMAP* newdib = FreeImage_Allocate(10*32, 8*32, bpp);

			FIBITMAP* newdib = FreeImage_ConvertFromRawBits(bufferimagedest, 160, (8*15), (160*4), bpp, FI_RGBA_RED_MASK, FI_RGBA_GREEN_MASK, FI_RGBA_BLUE_MASK, TRUE);


			int x = 0;
			int y = 0;
			int width = 32;
			int height = 32;

			FIBITMAP* subimage = FreeImage_Copy(dib, x, y, x + width, y + height);


			// save the bitmap as a PNG ...
			const char* output_filename = "C:/Users/Eric/projects/tectech/data/fontverticale1615.png";

			// first, check the output format from the file name or file extension
			FREE_IMAGE_FORMAT out_fif = FreeImage_GetFIFFromFilename(output_filename);

			if (out_fif != FIF_UNKNOWN) {
				// then save the file
				FreeImage_Save(out_fif, newdib, output_filename, 0);
			}

			// free the loaded FIBITMAP
			FreeImage_Unload(dib);
		}
		fclose(file);
	}

}

// Exécuter le programme : Ctrl+F5 ou menu Déboguer > Exécuter sans débogage
// Déboguer le programme : F5 ou menu Déboguer > Démarrer le débogage

// Astuces pour bien démarrer : 
//   1. Utilisez la fenêtre Explorateur de solutions pour ajouter des fichiers et les gérer.
//   2. Utilisez la fenêtre Team Explorer pour vous connecter au contrôle de code source.
//   3. Utilisez la fenêtre Sortie pour voir la sortie de la génération et d'autres messages.
//   4. Utilisez la fenêtre Liste d'erreurs pour voir les erreurs.
//   5. Accédez à Projet > Ajouter un nouvel élément pour créer des fichiers de code, ou à Projet > Ajouter un élément existant pour ajouter des fichiers de code existants au projet.
//   6. Pour rouvrir ce projet plus tard, accédez à Fichier > Ouvrir > Projet et sélectionnez le fichier .sln.
