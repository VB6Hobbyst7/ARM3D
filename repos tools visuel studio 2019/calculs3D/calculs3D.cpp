// calculs3D.cpp : Ce fichier contient la fonction 'main'. L'exécution du programme commence et se termine à cet endroit.
//

#include <iostream>
#include <math.h>

int main()
{

    #define M_PI       3.14159265358979323846

    // std::cout << "Hello World!\n";


    double CX,CY,CZ;
    double SX,SY,SZ;
   
    // angles en 1/512
    double anglex = 0;
    double angley = 48;
    // 33,75° : sinus = 18204 , cosinus = 27245
    double anglez = 0;

    // conversion en radians
    // 512 = 360 °
    // 512 = 2 * pi
    // /512 puis *(2*pi)

    anglex = (anglex / 512)*  (2 * M_PI);
    angley = (angley / 512) * (2 * M_PI);
    anglez = (anglez / 512) * (2 * M_PI);


    CX = cos(anglex)* 32768;
    CY = cos(angley)* 32768;
    CZ = cos(anglez)* 32768;

    SX = sin(anglex)* 32768;
    SY = sin(angley)* 32768;
    SZ = sin(anglez)* 32768;


    CX = cos(anglex);
    CY = cos(angley);
    CZ = cos(anglez);

    SX = sin(anglex);
    SY = sin(angley);
    SZ = sin(anglez);


    printf("SX : %f \n", SX*32768);
    printf("CX : %f \n", CX * 32768);

    printf("SY : %f \n", SY * 32768);
    printf("CY : %f \n", CY * 32768);

    printf("SZ : %f \n", SZ * 32768);
    printf("CZ : %f \n", CZ * 32768);

    double A,B,C,D,E,F,G,H,I;

    A = CY * CZ;
    B = -((CY * SZ * CX) + (SX * SY));
    C = (CY * SZ * SX) - (SY * CX);
    D = SZ;
    E = (CX * CZ);
    F = -(SX * CZ);
    G = (SY * CZ);
    H = (CY * SX) - (SY * SZ * CX);
    I = (SY * SZ * SX) + (CY * CX);
    
    printf("\n");
    printf("A = %f \n", A * 32768);
    printf("B = %f \n", B * 32768);
    printf("C = %f \n", C * 32768);
    printf("D = %f \n", D * 32768);
    printf("E = %f \n", E * 32768);
    printf("F = %f \n", F * 32768);
    printf("G = %f \n", G * 32768);
    printf("H = %f \n", H * 32768);
    printf("I = %f \n", I * 32768);

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
