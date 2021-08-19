// sinus1 sol vectorball.cpp : Ce fichier contient la fonction 'main'. L'exécution du programme commence et se termine à cet endroit.
//
// // format : 
// .long	couleur0					; couleur du fond
// .long	0x3640000 ; 
// .long	0x3620000; vstart

// V2 : 10^x
// V3 : ajout d'un composant sinus au milieu
#define _CRT_SECURE_NO_WARNINGS


#include <string>
#include <cstdio>

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <algorithm>    // std::min

#include <math.h>

#include <cstdio>
#include <string>



#define PI 3.14159265

using namespace std;

int main()
{
    FILE* pFileW;
    pFileW = fopen("C:/Archi/vasm/table_sol2V3.s", "w");

    int     tableau_numeros_lignes[200];
    int     nb_lignes_a_afficher_total = 0;

    int index_dans_tableau_destination = 0;
    int nbvaleurs = 0;

    int nb_lignes_a_afficher = 60;
    nb_lignes_a_afficher_total = nb_lignes_a_afficher + nb_lignes_a_afficher_total;

    int nombre_etapes = 60;   // nombre de lignes de reflet

    for (double x = 1.5; x < 3.0; x = x + (1.5 / nombre_etapes))
    {
        int numero_ligne_a_afficher;
        numero_ligne_a_afficher = int( 200 - ((pow(x, 2) * (200 / 06.7))))+68;

        if (index_dans_tableau_destination >= 0 && index_dans_tableau_destination < 60)
        {
            // au milieu on fait une variation

            double angle = (((double) index_dans_tableau_destination / 30.0) + 0.5) * PI;
            double variation= (cos(angle ))*10;
            printf("variation : %f / ", variation);
            printf("numero_ligne_a_afficher : %d / ", numero_ligne_a_afficher);

            numero_ligne_a_afficher = round(numero_ligne_a_afficher + variation);

        }


        tableau_numeros_lignes[index_dans_tableau_destination] = numero_ligne_a_afficher;
        index_dans_tableau_destination++;

        printf("ligne %d:  x=%f : %d\n", index_dans_tableau_destination, x,numero_ligne_a_afficher);


    }
  

    fprintf(pFileW, ";       .long   couleur0, vstart, vend\n");

    fprintf(pFileW, "table_couleur0_vstart_vend_MEMC1:\n");

    for (int i = 0; i < nb_lignes_a_afficher_total; i++)
    {
        
        if (i == 0)
        {
            fprintf(pFileW, "   .set 	couleur0, 0\n");
        }
        
        if (i == 2 || i==4 || i==6 || i==8 ||  i==10 ||  i==12 || i==0 )
        {
            fprintf(pFileW, "       .set	couleur0, couleur0+0b100000000\n");
        }

 


        // valeur couleur
        // .long	couleur0



        fprintf(pFileW, "       .long   couleur0, ");

        // valeur vstart
        int valeur_vstart = tableau_numeros_lignes[i];
        // .long	0x3620000; vstart
        fprintf(pFileW, "0x3620000 + (%d*104)+(104*32), ", valeur_vstart);

        // valeur vend, 1ere ligne = vend=fin de l'ecran
        if (i == 0)
        // premiere ligne, vend = 0x3640000+((200*104)-4)
        {
            fprintf(pFileW, "0x3640000+((200*104)-4)+(104*32)\n");
        }
        else
        {
            int valeur_vend = tableau_numeros_lignes[i - 1];
            fprintf(pFileW, "0x3640000+(%d*104)+100+(104*32)\n ", valeur_vend);
        }
        nbvaleurs++;
    }
           
    fprintf(pFileW, "table_couleur0_vstart_vend_MEMC2:\n"); 
    fprintf(pFileW, ";       .long   couleur0, vstart, vend\n");
    for (int i = 0; i < nb_lignes_a_afficher_total; i++)
    {

        if (i == 0)
        {
            fprintf(pFileW, "   .set 	couleur0, 0\n");
        }

        if (i == 2 || i == 4 || i == 6 || i == 8 || i == 10 || i == 12 || i == 0)
        {
            fprintf(pFileW, "       .set	couleur0, couleur0+0b100000000\n");
        }

        // valeur couleur
        // .long	couleur0
        fprintf(pFileW, "       .long   couleur0, ");

        // valeur vstart
        int valeur_vstart = tableau_numeros_lignes[i];
        // .long	0x3620000; vstart
        fprintf(pFileW, "0x3620000 + (%d*104)+(104*32)+(104*290), ", valeur_vstart);

        // valeur vend, 1ere ligne = vend=fin de l'ecran
        if (i == 0)
            // premiere ligne, vend = 0x3640000+((200*104)-4)
        {
            fprintf(pFileW, "0x3640000+((200*104)-4)+(104*32)+(104*290)\n");
        }
        else
        {
            int valeur_vend = tableau_numeros_lignes[i - 1];
            fprintf(pFileW, "0x3640000+(%d*104)+100+(104*32)+(104*290)\n ", valeur_vend);
        }
        nbvaleurs++;
    }

    
    fclose(pFileW);
    printf("nombre de valeurs : %d\n", nbvaleurs);





    
}
/*
// partie du début qui reflete partie basse
int     nb_lignes_a_afficher = 40;
int     plus_haute_ligne_du_haut = 66;
int     nombre_lignes_prises_en_haut = 133;



for (int i = 0; i < nb_lignes_a_afficher; i++)
{
    // de 180° à 270°
    double  angle = i * (90.0 / nb_lignes_a_afficher) + 180;
    double  resultat = sin(angle * PI / 180.0);
    resultat = (resultat * (nombre_lignes_prises_en_haut)) + plus_haute_ligne_du_haut + nombre_lignes_prises_en_haut;
    int resint = int(resultat);

    tableau_numeros_lignes[index_dans_tableau_destination] = resint;
    index_dans_tableau_destination++;

    //printf("res : %f\n", resultat);
    printf("resint : %x / %d\n", resint, resint);
}
nb_lignes_a_afficher_total = nb_lignes_a_afficher + nb_lignes_a_afficher_total;

// partie basse du reflet qui reflete la partie haute de l'écran
nb_lignes_a_afficher = 20;
plus_haute_ligne_du_haut = 0;
nombre_lignes_prises_en_haut = 65;


for (int i = 0; i < nb_lignes_a_afficher; i++)
{
    // de 180° à 270°
    double  angle = i * (90.0 / nb_lignes_a_afficher) + 180;
    double  resultat = sin(angle * PI / 180.0);
    resultat = (resultat * (nombre_lignes_prises_en_haut)) + plus_haute_ligne_du_haut + nombre_lignes_prises_en_haut;
    int resint = int(resultat);

    tableau_numeros_lignes[index_dans_tableau_destination] = resint;
    index_dans_tableau_destination++;

    //printf("res : %f\n", resultat);
    printf("resint : %x / %d\n", resint, resint);
}*/