// convert_png.cpp : Ce fichier contient la fonction 'main'. L'exécution du programme commence et se termine à cet endroit.
//

#include <iostream>

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#define FREEIMAGE_LIB
#include "FreeImage.h"



fi_handle g_load_address;


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


int main()
{

	// call this ONLY when linking with FreeImage as a static library
#ifdef FREEIMAGE_LIB
	FreeImage_Initialise();
#endif // FREEIMAGE_LIB



    std::cout << "Hello World!\n";
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
