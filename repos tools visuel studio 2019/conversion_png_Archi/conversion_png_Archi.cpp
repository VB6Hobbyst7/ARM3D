// conversion_png_Archi.cpp : Ce fichier contient la fonction 'main'. L'exécution du programme commence et se termine à cet endroit.
//
// For 8bpp, bits 0 - 3 select which palette reg to use, and bits 4 - 7 replace bits
// 3, 6, 7 and 11 of the palette data.
// 
// SUP |     BLUE          |     GREEN        |     RED          |      
// D12 |  L7  D10  D9  D8  |  L6  L5  D5  D4  |  L4  D2  D1  D0  |
// masquebleu = 0b0111 
// masquevert = 0b0011
// masquerouge = 0b0111
// format de sortie:
// 16 octets : palette
// N octets : sprite 
//
// OK - réduire à 4 bits par couleur
// OK - voir si 2 couleurs sont devenues identiques ?
// masquer les couleurs trouvées, compter combien de differentes une fois masquées
//
//
//
// - eliminer des couleurs, proches des octets masquées. par exemple 0 3 3 = 0 1 3 + 0 4 0
// test avec 1 bits de moins par couleur : 64 couleurs
// 71 couleurs sans perte. 
//
// - réappliquer les couleurs contenues dans tableau_couleurs_4bits_maske pour 16 variations du dessin

#define _CRT_SECURE_NO_WARNINGS


#include <iostream>

//#define STB_IMAGE_IMPLEMENTATION
#define  MONPI  3.14159265358979323846

#include <stdio.h>
#include <climits>
#include <cstdlib>
#include <string.h>
#include <stdio.h>
#include <malloc.h>
#include <math.h>
#include "./stb_image.h"


struct pixel
{
    unsigned char R;
    unsigned char G;
    unsigned char B;
    unsigned char R4bits;
    unsigned char G4bits;
    unsigned char B4bits;
    unsigned char R4bits_mask_palette;
    unsigned char G4bits_mask_palette;
    unsigned char B4bits_mask_palette;
    unsigned short couleur12bits;
};

unsigned short  tableau_octets[16];
pixel tableau_couleurs[200];
pixel tableau_couleurs_4bits_epure[200];
pixel tableau_couleurs_4bits_maske[200];



typedef unsigned int u32;

int main()
{
    unsigned short bit3 =  0b000000001000;
    unsigned short bit6 =  0b000001000000;
    unsigned short bit7 =  0b000010000000;
    unsigned short bit11 = 0b100000000000;



    tableau_octets[0] = 0x00000000;

    tableau_octets[1] = bit3;
    tableau_octets[2] = bit6;
    tableau_octets[3] = bit7;
    tableau_octets[4] = bit11;

    tableau_octets[5] = bit3 | bit6;
    tableau_octets[6] = bit3 | bit7;
    tableau_octets[7] = bit3 | bit11;
    tableau_octets[8] = bit6 | bit7;
    tableau_octets[9] = bit6 | bit11;
    tableau_octets[10] = bit7 | bit11;

    tableau_octets[11] = bit6 | bit7 | bit11;
    tableau_octets[12] = bit3 | bit6 | bit7;
    tableau_octets[13] = bit3 | bit7 | bit11;
    tableau_octets[14] = bit3 | bit6 | bit11;

    tableau_octets[15] = bit3 | bit6 | bit7 | bit11;




    


    int     masque_selection_palette = 0x0f;
    int     masquage_palette_R = 0b0111;
    int     masquage_palette_G = 0b0011;
    int     masquage_palette_B = 0b0111;

    

    stbi_uc* pointeur_sphere_violette;
    u32* pointeur_sphere_violette_u32;
    char* pointeur_sphere_violette_char;
    int width, height, nchan;

    pointeur_sphere_violette = stbi_load("C:/Users/Eric/Pictures/boule16x16.png", &width, &height, &nchan, STBI_rgb);
    //pointeur_sphere_violette = stbi_load("./bowls.png", &width, &height, &nchan, STBI_rgb);

    printf("width : %d\n", width);
    printf("height : %d\n", height);
    printf("nchan : %d\n", nchan);

    pointeur_sphere_violette_u32 = (u32*)pointeur_sphere_violette;
    pointeur_sphere_violette_char = (char*)pointeur_sphere_violette;

    int nbpixels = width * height;
    printf("Nombre de pixels : %d\n", nbpixels);

    int indice = 0;

    int nbcouleurs_actuel = 0;

    // on compte le nombre de couleurs dans le PNG

    for (int i = 0; i < nbpixels; i++)
    {
        // on recupere les infos RGB du pixel en cours
        unsigned char Rpixel = pointeur_sphere_violette_char[indice];
        indice++;
        unsigned char Gpixel = pointeur_sphere_violette_char[indice];
        indice++;
        unsigned char Bpixel = pointeur_sphere_violette_char[indice];
        indice++;

        bool trouve = false;
        int position_recherche_dans_les_couleurs = 0;
        while ((position_recherche_dans_les_couleurs < nbcouleurs_actuel) && !trouve)
        {
            if ((Rpixel == tableau_couleurs[position_recherche_dans_les_couleurs].R) && (Gpixel == tableau_couleurs[position_recherche_dans_les_couleurs].G) && (Bpixel == tableau_couleurs[position_recherche_dans_les_couleurs].B))
             {
             trouve = true;

              }
            position_recherche_dans_les_couleurs++;
         }
        if (!trouve)
        {
            printf("ajout de %d %d %d ... %x %x %x \n ",Rpixel, Gpixel, Bpixel, Rpixel, Gpixel, Bpixel);
            tableau_couleurs[nbcouleurs_actuel].R = Rpixel;
            tableau_couleurs[nbcouleurs_actuel].G = Gpixel;
            tableau_couleurs[nbcouleurs_actuel].B = Bpixel;

            nbcouleurs_actuel++;

        }


     }
    printf("nombre initial de couleurs : %d \n", nbcouleurs_actuel);

    // on réduit en 4 bits

    for (int i = 0;  i < nbcouleurs_actuel;i++)
    {
        tableau_couleurs[i].R4bits = tableau_couleurs[i].R >> 4;
        tableau_couleurs[i].G4bits = tableau_couleurs[i].G >> 4;
        tableau_couleurs[i].B4bits = tableau_couleurs[i].B >> 4;
        printf("valeurs masquees 4 bits :  %x %x %x \n ", tableau_couleurs[i].R4bits, tableau_couleurs[i].G4bits, tableau_couleurs[i].B4bits);
    }
    
    // on vérifie qu'on a pas 2 fois la même couleur masquée

    int nbcouleurs_actuel_4bits = 0;
    int index_couleur_testee_actuelle=0;
    for (int i=0; i< nbcouleurs_actuel; i++)
    {
        bool trouve_4bits = false;
        int position_recherche_dans_les_couleurs_4bits = 0;

        while ((position_recherche_dans_les_couleurs_4bits < nbcouleurs_actuel_4bits) && !trouve_4bits)
        {
            if ((tableau_couleurs[index_couleur_testee_actuelle].R4bits == tableau_couleurs_4bits_epure[position_recherche_dans_les_couleurs_4bits].R4bits) && (tableau_couleurs[index_couleur_testee_actuelle].G4bits == tableau_couleurs_4bits_epure[position_recherche_dans_les_couleurs_4bits].G4bits) && (tableau_couleurs[index_couleur_testee_actuelle].B4bits == tableau_couleurs_4bits_epure[position_recherche_dans_les_couleurs_4bits].B4bits) )
            {
                trouve_4bits = true;
                printf("en doublon :  %x %x %x \n ", tableau_couleurs[index_couleur_testee_actuelle].R4bits, tableau_couleurs[index_couleur_testee_actuelle].G4bits, tableau_couleurs[index_couleur_testee_actuelle].B4bits);

            }
            position_recherche_dans_les_couleurs_4bits++;

        }

        if (!trouve_4bits)
        {
            printf("ajout de  %x %x %x \n ", tableau_couleurs[index_couleur_testee_actuelle].R4bits, tableau_couleurs[index_couleur_testee_actuelle].G4bits, tableau_couleurs[index_couleur_testee_actuelle].B4bits);
            tableau_couleurs_4bits_epure[nbcouleurs_actuel_4bits].R4bits = tableau_couleurs[index_couleur_testee_actuelle].R4bits;
            tableau_couleurs_4bits_epure[nbcouleurs_actuel_4bits].G4bits = tableau_couleurs[index_couleur_testee_actuelle].G4bits;
            tableau_couleurs_4bits_epure[nbcouleurs_actuel_4bits].B4bits = tableau_couleurs[index_couleur_testee_actuelle].B4bits;

            nbcouleurs_actuel_4bits++;

        }
        index_couleur_testee_actuelle++;
    }
    printf("nombre total de couleurs 4bits : %d \n", nbcouleurs_actuel_4bits);

    // masquage des valeurs de palette en fonction de l'octet

    printf("masques : %x %x %x \n ", masquage_palette_R, masquage_palette_G, masquage_palette_B);

    for (int i = 0; i < nbcouleurs_actuel_4bits; i++)
    {
        // printf("avant maskage: %x %x %x \n ", tableau_couleurs_4bits_epure[i].R4bits, tableau_couleurs_4bits_epure[i].G4bits, tableau_couleurs_4bits_epure[i].B4bits);
        tableau_couleurs_4bits_epure[i].R4bits_mask_palette = tableau_couleurs_4bits_epure[i].R4bits & masquage_palette_R;
        tableau_couleurs_4bits_epure[i].G4bits_mask_palette = tableau_couleurs_4bits_epure[i].G4bits & masquage_palette_G;
        tableau_couleurs_4bits_epure[i].B4bits_mask_palette = tableau_couleurs_4bits_epure[i].B4bits & masquage_palette_B;

        printf("apres maskage: %x %x %x \n ", tableau_couleurs_4bits_epure[i].R4bits_mask_palette, tableau_couleurs_4bits_epure[i].G4bits_mask_palette, tableau_couleurs_4bits_epure[i].B4bits_mask_palette);
    }
    
    // on cherche les doublons après masquage octet palette

    int nbcouleurs_actuel_4bits_maske = 0;
    int index_couleur_testee_actuelle_maske = 0;
    for (int i = 0; i < nbcouleurs_actuel_4bits; i++)
    {
        bool trouve_4bits_maske = false;
        int position_recherche_dans_les_couleurs_4bits_maske = 0;

        unsigned char couleur_recherchee_R = tableau_couleurs_4bits_epure[index_couleur_testee_actuelle_maske].R4bits_mask_palette;
        unsigned char couleur_recherchee_G = tableau_couleurs_4bits_epure[index_couleur_testee_actuelle_maske].G4bits_mask_palette;
        unsigned char couleur_recherchee_B = tableau_couleurs_4bits_epure[index_couleur_testee_actuelle_maske].B4bits_mask_palette;


        while ((position_recherche_dans_les_couleurs_4bits_maske < nbcouleurs_actuel_4bits_maske) && !trouve_4bits_maske)
        {
            if ((tableau_couleurs_4bits_maske[position_recherche_dans_les_couleurs_4bits_maske].R4bits_mask_palette == couleur_recherchee_R) && (tableau_couleurs_4bits_maske[position_recherche_dans_les_couleurs_4bits_maske].G4bits_mask_palette == couleur_recherchee_G) && (tableau_couleurs_4bits_maske[position_recherche_dans_les_couleurs_4bits_maske].B4bits_mask_palette == couleur_recherchee_B))
            {
                trouve_4bits_maske = true;
                printf("en doublon :  %x %x %x \n ", couleur_recherchee_R, couleur_recherchee_G, couleur_recherchee_B);

            }
            position_recherche_dans_les_couleurs_4bits_maske++;

        }

        if (!trouve_4bits_maske)
        {
            printf("ajout de  %x %x %x \n ", couleur_recherchee_R, couleur_recherchee_G, couleur_recherchee_B);
            tableau_couleurs_4bits_maske[nbcouleurs_actuel_4bits_maske].R4bits = couleur_recherchee_R;
            tableau_couleurs_4bits_maske[nbcouleurs_actuel_4bits_maske].G4bits = couleur_recherchee_G;
            tableau_couleurs_4bits_maske[nbcouleurs_actuel_4bits_maske].B4bits = couleur_recherchee_B;

            nbcouleurs_actuel_4bits_maske++;

        }
        index_couleur_testee_actuelle_maske++;
    }
    printf("nombre total de couleurs 4bits : %d \n", nbcouleurs_actuel_4bits_maske);

    // lire les données de l'image
    // determiner la couleur correspondante
    // remplacer la donnée dans l'image

    
    indice = 0;
    for (int i = 0; i < nbpixels; i++)
    {
        unsigned char Rpixel = pointeur_sphere_violette_char[indice];
        unsigned char Gpixel = pointeur_sphere_violette_char[indice + 1];
        unsigned char Bpixel = pointeur_sphere_violette_char[indice + 2];

        // tout en 4 bits, 4096 couleurs
        Rpixel = Rpixel >> 4;
        Gpixel = Gpixel >> 4;
        Bpixel = Bpixel >> 4;

        // masque palette/data
        //Rpixel = Rpixel & masquage_palette_R;
        //Gpixel = Gpixel & masquage_palette_G;
        //Bpixel = Bpixel & masquage_palette_B;

        unsigned char valeur_octet = 0b00000000;

        //Rpixel = Rpixel | valeur_octet;
        //Gpixel = Gpixel | valeur_octet;
        //Bpixel = Bpixel | valeur_octet;


        // on remultiplie sinon tout est noir sur PC
        Rpixel = Rpixel << 4;
        Gpixel = Gpixel << 4;
        Bpixel = Bpixel << 4;


        pointeur_sphere_violette_char[indice] = Rpixel;
        indice++;
        pointeur_sphere_violette_char[indice] = Gpixel;
        indice++;
        pointeur_sphere_violette_char[indice] = Bpixel;
        indice++;


    }
     
    // int resultat = stbi_write_png("./sphereviolette2.png", width, height, 3, pointeur_sphere_violette_char, 0);
    FILE* pFile2;
    pFile2 = fopen("C:/Users/Eric/Pictures/sphere16x164bits.data", "wb");
    fwrite(pointeur_sphere_violette_char, 1, nbpixels*3, pFile2);

    fclose(pFile2);

    // créer une palette complete de 256 couleurs
    // a partir du png

    int nbpixels_fichier_palette = nbcouleurs_actuel_4bits_maske * 16  * 3; // * 16 maskes * 3 octets par couleur R G B sur PC
    unsigned char* paletteRGB_PC = ( unsigned char*) malloc(nbpixels_fichier_palette);
    memset(paletteRGB_PC, 0, nbpixels_fichier_palette);
    unsigned char valeur_octet = 0b00000000;
    // palette dans tableau_couleurs_4bits_maske
    int indice_destination = 0;
    for (int j = 0; j < 16; j++)
    {
        for (int i = 0; i < nbcouleurs_actuel_4bits_maske; i++)
        {
            unsigned short couleur12bits=0;
            couleur12bits = tableau_couleurs_4bits_maske[i].R4bits;
            couleur12bits = couleur12bits << 4 | tableau_couleurs_4bits_maske[i].G4bits;
            couleur12bits = couleur12bits << 4 | tableau_couleurs_4bits_maske[i].B4bits;

            couleur12bits = couleur12bits | tableau_octets[j];

            unsigned char R_palette_pc = couleur12bits >> 8;
            unsigned char G_palette_pc = ( couleur12bits & 0x00F0) >> 4;
            unsigned char B_palette_pc = (couleur12bits & 0x000F) ;


            paletteRGB_PC[indice_destination] = R_palette_pc << 4;
            indice_destination++;
            paletteRGB_PC[indice_destination] = G_palette_pc << 4;
            indice_destination++;
            paletteRGB_PC[indice_destination] = B_palette_pc << 4;
            indice_destination++;


        }

    }

    FILE* pFile;
    pFile = fopen("C:/Users/Eric/Pictures/sphere16x16v2.data", "wb");
        fwrite(paletteRGB_PC, 1, nbpixels_fichier_palette, pFile);

    fclose(pFile);

    /////////////////////////////////////////////////////////////////// Archi //////////////////////////////////
    // creation de la version Archi de la sphere violette
    // 
    // en B G R !!!
    //
    // 16 * short = palette 16 couleurs 12 bits
    // 32*32 octets = dessin boule

    FILE* pFile3;
    pFile3 = fopen("C:/Users/Eric/Pictures/sphere16x16pourArchi.bin", "wb");

    // 16 * short = palette 16 couleurs 12 bits

    unsigned short zero = 0;

    for (int i = 0; i < 16; i++)
    {
        unsigned short couleur16bits;

        // B G R sur Archi
        couleur16bits = tableau_couleurs_4bits_maske[i].B4bits << 8;
        couleur16bits = couleur16bits | (tableau_couleurs_4bits_maske[i].G4bits << 4);
        couleur16bits = couleur16bits | tableau_couleurs_4bits_maske[i].R4bits ;
        tableau_couleurs_4bits_maske[i].couleur12bits = couleur16bits;
        printf("couleur 16 bits : %x \n", couleur16bits);
        fwrite(&zero, 1, 2, pFile3);
        fwrite( &couleur16bits, 1, 2, pFile3);

        
    }

    // 32*32 octets = dessin boule
    // parcourir le dessin
    // masquer avec 0b011100110111
    // chercher dans tableau_couleurs_4bits_maske[i].couleur12bits

    unsigned char pixelsfinaux[256*256];

    int index_lecture_source=0;
    int index_dest = 0;
    for (int j = 0; j < nbpixels; j++)
    {
        // R du PNG de 8bits à 4bits
        unsigned char Rtmp = pointeur_sphere_violette[index_lecture_source] >> 4;
        // G du PNG de 8bits à 4bits
        unsigned char Gtmp = pointeur_sphere_violette[index_lecture_source+1] >> 4;
        // B du PNG de 8bits à 4bits
        unsigned char Btmp = pointeur_sphere_violette[index_lecture_source+2] >> 4;

        if (Rtmp == 15 && Gtmp == 15 && Btmp == 15)
        {
            printf("pixel blanc\n");
        }

        unsigned short pixel_a_chercher = (Btmp << 8) | (Gtmp << 4) | Rtmp;

        index_lecture_source = index_lecture_source+3;

        
        //printf("pixel_a_chercher : %x \n", pixel_a_chercher);

        unsigned short pixel_a_chercher_mask_palette = pixel_a_chercher & 0b011100110111;
        unsigned short pixel_a_chercher_mask_memoire_video = pixel_a_chercher & 0b100011001000;
        
        unsigned short bit7 = pixel_a_chercher_mask_memoire_video & 0b100000000000;
        bit7 = bit7 >> 11;
        bit7 = bit7 << 7;
        unsigned short bit6 = pixel_a_chercher_mask_memoire_video & 0b000010000000;
        bit6 = bit6 >> 7;
        bit6 = bit6 << 6;
        unsigned short bit5 = pixel_a_chercher_mask_memoire_video & 0b000001000000;
        bit5 = bit5 >> 6;
        bit5 = bit5 << 5;
        unsigned short bit4 = pixel_a_chercher_mask_memoire_video & 0b000000001000;
        bit4 = bit4 >> 3;
        bit4 = bit4 << 4;





        unsigned char pixel_a_chercher_mask_octet_pixel = (bit7 | bit6 | bit5 | bit4);


        bool pixel_trouve = false;
        int index_recherche = 0;
        int index_trouve = 0;

        while ((pixel_trouve == false) && (index_recherche< nbcouleurs_actuel_4bits_maske))
        {
            if (tableau_couleurs_4bits_maske[index_recherche].couleur12bits == pixel_a_chercher_mask_palette)
            {
                pixel_trouve = true;
                index_trouve = index_recherche;
            }
            index_recherche++;
        }
        if (pixel_trouve == false) printf("ERREUR : %x\n", pixel_a_chercher_mask_palette);

        unsigned char pixel_final = pixel_a_chercher_mask_octet_pixel + index_trouve;

        pixelsfinaux[index_dest] = pixel_final;
        index_dest++;

    }

    fwrite(pixelsfinaux, 1,nbpixels, pFile3);

    fclose(pFile3);

    // recréer un fichier data pour PC:
    // prendre un octet dans pixelsfinaux sur nbpixels
    // bits 0-3 : prendre la couleur dans tableau_couleurs_4bits_maske[i].couleur12bits
    // octet and 0b11110000
    // tester chaque bit, mettre chaque bit correspondant dans  R G B de destination
    // 

    unsigned char pixelsfinaux_archi_rebuild_vers_PC[256 * 256];

    FILE* pFile4;
    pFile4 = fopen("C:/Users/Eric/Pictures/sphere16x16recree.data", "wb");

    int index_rebuild_PC = 0;
    for (int j = 0; j < nbpixels; j++)
    {
        // octet dans le binaire Archi
        unsigned char  pixel_lu = pixelsfinaux[j];

        // on garde 4 bits
        int index_palette = pixel_lu & 0b1111;

        // 12 bits en format B G R
        unsigned short couleur_12bits_lu = tableau_couleurs_4bits_maske[index_palette].couleur12bits;

        unsigned char B_lu = couleur_12bits_lu >> 8;
        unsigned char G_lu = (couleur_12bits_lu >> 4 ) & 0b1111;
        unsigned char R_lu = couleur_12bits_lu & 0b1111;

        unsigned char pixel_lu_masque = pixel_lu & 0b11110000; // 4 bits du haut, on vire l'index de recherche dans la palette

        // bit 7
        if ((pixel_lu_masque & 0b10000000) == 0b10000000) B_lu = B_lu | 0b1000;
        // bit 6
        if ((pixel_lu_masque & 0b01000000) == 0b01000000) G_lu = G_lu | 0b1000;
        // bit 5
        if ((pixel_lu_masque & 0b00100000) == 0b00100000) G_lu = G_lu | 0b0100;
        // bit 4
        if ((pixel_lu_masque & 0b00010000) == 0b00010000) R_lu = R_lu | 0b1000;

        pixelsfinaux_archi_rebuild_vers_PC[index_rebuild_PC] = R_lu << 4;
        index_rebuild_PC++;
        pixelsfinaux_archi_rebuild_vers_PC[index_rebuild_PC] = G_lu << 4;
        index_rebuild_PC++;
        pixelsfinaux_archi_rebuild_vers_PC[index_rebuild_PC] = B_lu << 4;
        index_rebuild_PC++;




    }

    fwrite(pixelsfinaux_archi_rebuild_vers_PC, 1, nbpixels*3, pFile4);


    fclose(pFile4);

}


