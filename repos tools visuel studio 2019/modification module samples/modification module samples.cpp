// modification module samples.cpp : Ce fichier contient la fonction 'main'. L'exécution du programme commence et se termine à cet endroit.
//
#define _CRT_SECURE_NO_WARNINGS

#include <iostream>
#include <cstdio>

int main()
{
  

   

    // ouvrir le module en source
    // le charger en memoire
    // ajouter $400 octets a chaque sample
    // sauvegarder le module

    // load module
#define ECART 2048

    const int BUFFERSIZE = 160218+(32* ECART);
    unsigned char* buffer = new unsigned char[BUFFERSIZE];
    unsigned char* buffer_dest = new unsigned char[BUFFERSIZE];

    for (int i = 0; i < BUFFERSIZE; i++)
    {
        buffer_dest[i] = 0;
    }

    // C:\Archi\vasm\YM\LSPlayer-main\brico\k.mod

    const char* fname = "C:/Archi/vasm/YM/LSPlayer-main/brico/k.mod";
    FILE* filp = fopen(fname, "rb");
    if (!filp) { printf("Error: could not open file %s\n", fname); return -1; }

    
    int bytes = fread(buffer, sizeof(char), BUFFERSIZE, filp);
    printf("bytes lus : %d\n", bytes);
        
    // Done and close.
    fclose(filp);

    // le module est dans buffer

    // lecture du nom du module pour tester les accès mémoire directs
    char* nommodule = new char[21];
    memcpy(nommodule, buffer , 20 );
    nommodule[20] = 0; /* Add terminator */
    nommodule[0] = 0x32;
    buffer[0] = 0x32;
    printf("nom du module : %s\n",nommodule);


    // Number of patterns stored is equal to the highest patternnumber
    //    in the song position table(at offset 952 - 1079).

    int highest_patternumber = 0;
    int pointeur = 952;
    for (int i = 0; i < 128; i++)
    {
        int pattern_number = (int)buffer[pointeur];
        if (pattern_number > highest_patternumber)  highest_patternumber = pattern_number;
        pointeur++;
    }
    highest_patternumber = highest_patternumber + 1; // compteur commence à zéro
    int pointeur_debut_samples = (highest_patternumber * 1024) + 1084;

    // copie début + infos chanson jusqu'au début des samples
    memcpy(buffer_dest, buffer, pointeur_debut_samples);

    // affiche infos samples
    // instrument 1 à 31
    pointeur = 20;
    int pointeur_source_samples = pointeur_debut_samples;
    int pointeur_dest = pointeur_debut_samples;

    char* nom_sample = new char[23];

    for (int isample = 1; isample < 32; isample++)
    {
        
        memcpy(nom_sample, buffer + pointeur, 22);
        nom_sample[22] = 0; /* Add terminator */
        printf("%s\n",nom_sample);
        
        // longeur sample
        int len1 = (int) buffer[pointeur + 22];
        int len2 = (int) buffer[pointeur + 23];
        int len3 = len1 * 256 + len2;
        len3 = len3 * 2;
        int longeur_sample = len3;

        len1 = (int)buffer[pointeur + 26];
        len2 = (int)buffer[pointeur + 27];
        len3 = len1 * 256 + len2; // en mots
        int repeat_start_sample = len3*2;

        len1 = (int)buffer[pointeur + 28];
        len2 = (int)buffer[pointeur + 29];
        len3 = len1 * 256 + len2; // en mots
        int repeat_length_sample = len3 * 2;


        printf("longeur sample : $%x\n", longeur_sample);
        printf("repeat start sample : $%x\n", repeat_start_sample);
        printf("repeat length sample : $%x\n", repeat_length_sample);

        // copie le sample en entier
        memcpy(buffer_dest + pointeur_dest, buffer + pointeur_source_samples, longeur_sample);

        int pointeur_source_repetition = pointeur_source_samples + repeat_start_sample;

        pointeur_source_samples = pointeur_source_samples + longeur_sample;
        pointeur_dest = pointeur_dest + longeur_sample;



        int nombre_de_copie_de_la_repetition = ECART / repeat_length_sample;

        printf("nombre de repetition : %d\n", nombre_de_copie_de_la_repetition);

        for (int i = 0; i < nombre_de_copie_de_la_repetition; i++)
        {
            memcpy(buffer_dest + pointeur_dest, buffer + pointeur_source_repetition, repeat_length_sample);
            pointeur_dest = pointeur_dest + repeat_length_sample;
        }
        printf("\n");
        int restant = ECART - (nombre_de_copie_de_la_repetition * repeat_length_sample);

        for (int i = 0; i < restant; i++)
        {
            memcpy(buffer_dest + pointeur_dest+i, buffer + pointeur_source_repetition+i, 1);

        }
        
        pointeur_dest = pointeur_dest + restant;



        
        // on met le pointeur de repetition à la fin du sample
        repeat_start_sample = longeur_sample;
        // un ajoute 1024 octets au sample
        longeur_sample = longeur_sample + ECART;



        // mise à jour des infos du sample
        
        // maj de longeur sample
        len1 = (longeur_sample / 2) / 256;
        len2 = (longeur_sample / 2) - (256 * len1);
        printf("start recalcul : %x%x  / ", len1, len2);
        buffer_dest[pointeur + 22] = (unsigned char) len1;
        buffer_dest[pointeur + 23] = (unsigned char) len2;

        // maj de repeat start sample
        len1 = (repeat_start_sample / 2) / 256;
        len2 = (repeat_start_sample / 2) - (256 * len1);
        printf("rep start recalcul : %x%x / ", len1, len2);
        buffer_dest[pointeur + 26] = (unsigned char)len1;
        buffer_dest[pointeur + 27] = (unsigned char)len2;
        
        // maj de repeat length sample
        len1 = (repeat_length_sample / 2) / 256;
        len2 = (repeat_length_sample / 2) - (256 * len1);
        printf("rep len recalcul : %x%x \n ", len1, len2);
        buffer_dest[pointeur + 28] = (unsigned char)len1;
        buffer_dest[pointeur + 29] = (unsigned char)len2;

        pointeur = pointeur + 30;
        

    }
    printf("high pattern : %d\n", highest_patternumber);
    printf("position samples hex: %x\n", pointeur_debut_samples);

    // ecriture du module
    FILE* pFile_dest;
    pFile_dest = fopen("C:/Archi/vasm/YM/LSPlayer-main/brico/k2.mod", "wb");
    fwrite(buffer_dest, 1, bytes, pFile_dest);
    fclose(pFile_dest);
}

