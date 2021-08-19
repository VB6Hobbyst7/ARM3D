// sincos.cpp : Ce fichier contient la fonction 'main'. L'exécution du programme commence et se termine à cet endroit.
//

#include <iostream>
#define _USE_MATH_DEFINES

#include <math.h>

int main()
{
    double  multiplicateur;
    multiplicateur = 32768;

    printf("--------------------\n");
    printf("\n");
    printf("\n");

    double cosinus, sinus;
    double angle = 0;
    for (int ligne = 0; ligne < (512 / 8); ligne++)
    {
        printf("	.long	");
        for (int colonne = 0; colonne < 7; colonne++)
        {
            // printf("0x%x,0x%x,", ((sin(angle))* multiplicateur), (cos(angle)* multiplicateur));
            
            cosinus = cos(angle) * multiplicateur;
            sinus = sin(angle) * multiplicateur;
            signed int cosinusi = int( cosinus);
            signed int sinusi = int(sinus);

            printf("%i, %i,", sinusi,cosinusi);
            angle = angle + ((2 * M_PI) / 512);
        }
        cosinus = cos(angle) * multiplicateur;
        sinus = sin(angle) * multiplicateur;
        signed int cosinusi = int(cosinus);
        signed int sinusi = int(sinus);

        printf("%i, %i", sinusi, cosinusi);
        angle = angle + ((2 * M_PI) / 512);

        printf("\n");
    }

    printf("cos 0 : %x\n", cos(0.0f));
    printf("sin 0: %f\n", sin(0.0f));
    printf("-1*512 : %x", -1*512);
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
