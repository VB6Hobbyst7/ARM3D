// fabrication datas mouvements vectorball.cpp : Ce fichier contient la fonction 'main'. L'exécution du programme commence et se termine à cet endroit.
//


#define _CRT_SECURE_NO_WARNINGS


#include <string>
#include <cstdio>

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <algorithm>    // std::min


#include <cstdio>
#include <string>


using namespace std;

int main()
{

        FILE* pointeurfichier = fopen("C:/Archi/vasm/descente_verticaleXY100.bin", "wb");
        //FILE* stream = fopen("C:/Archi/vasm/montee_verticaleXY.bin", "w");

        int nombre_valeurs = 260;

        int32_t a[2000*2];
        int indexvaleurs = 0;
        int32_t position_objet = -130;
        for (int loop = 0; loop< nombre_valeurs; loop++)
        {
            // X
            a[indexvaleurs] = (int32_t) 0;
            indexvaleurs++;
            
            // Y
            a[indexvaleurs] = (int32_t)(position_objet);
            indexvaleurs++;

            position_objet = position_objet + 1;


            // Z 
            // a[0] = (uint32_t)0;
            // fwrite(a, 4, 1, pointeurfichier);

            
        }
        fwrite(a, 4, nombre_valeurs*2, pointeurfichier);

        fclose(pointeurfichier);



}
