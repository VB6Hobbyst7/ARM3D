// conversion animations ST en long Archi.cpp : Ce fichier contient la fonction 'main'. L'exécution du programme commence et se termine à cet endroit.
//

#define _CRT_SECURE_NO_WARNINGS

#include <iostream>
#include "intrin.h"

int main()
{
    
    int nombre_de_points = 64;
    int nombre_de_frames = 1;
    // 40

    FILE* pFile;
    FILE* pFileW;
    pFile = fopen("C:/Archi/vasm/DATA/HELI_ROT.DAT", "rb");
    pFileW = fopen("C:/Archi/vasm/HELI_ROT.s", "w");
    signed short valeur_mot;
    signed  long    valeur_long;

    for (int i = 0; i < nombre_de_frames; i++)
    {
        for (int j = 0; j < nombre_de_points; j++)
        {
            fread(&valeur_mot, 2, 1, pFile);
            valeur_mot = _byteswap_ushort(valeur_mot);
            valeur_long = signed long(valeur_mot);
            printf("valeur mot : %x\n", valeur_long);
            fprintf(pFileW, "       .long 0x%x, ", valeur_long);

            // fwrite(&valeur_long, 4, 1, pFileW);


            fread(&valeur_mot, 2, 1, pFile);
            valeur_mot = _byteswap_ushort(valeur_mot);
            valeur_long = signed long(valeur_mot);
            printf("valeur mot : %x\n", valeur_long);
            fprintf(pFileW, " 0x%x,", valeur_long);

            //fwrite(&valeur_long, 4, 1, pFileW);


            fread(&valeur_mot, 2, 1, pFile);
            valeur_mot = _byteswap_ushort(valeur_mot);
            valeur_long = signed long(valeur_mot);
            printf("valeur mot : %x\n", valeur_long);
            fprintf(pFileW, "0x%x, ", valeur_long);

            //fwrite(&valeur_long, 4, 1, pFileW);


            fread(&valeur_mot, 2, 1, pFile);
            valeur_mot = _byteswap_ushort(valeur_mot);
            valeur_long = signed long(valeur_mot);
            printf("valeur mot : %x\n", valeur_long);
            fprintf(pFileW, "0x%x\n", valeur_long);

            //fwrite(&valeur_long, 4, 1, pFileW);

        }
    }

    fclose(pFile);
    fclose(pFileW);




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
