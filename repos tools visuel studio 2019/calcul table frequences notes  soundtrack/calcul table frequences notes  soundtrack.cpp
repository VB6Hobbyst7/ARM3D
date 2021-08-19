// calcul table frequences notes  soundtrack.cpp : Ce fichier contient la fonction 'main'. L'exécution du programme commence et se termine à cet endroit.
//

#include <iostream>
#include <math.h>

int main()
{
    // nombre de us de temps entre chaque sample : actual_uS
    // 416 octets = 48
    // 
    long double temps_us = 16;
    
    long double frq;
    long double freq;

    long double note_amiga = 400;

    freq = 1000000 / temps_us;
    long double nombre_octets_par_vbl =  freq / 50.0801282;
    printf("nombre d octets par VBL ( doit etre un entier) : %f\n", nombre_octets_par_vbl);

    printf("Frequence de replay Archi : %f\n", freq);
    // freq = 31250;
    // freq = 20833.33333;

    // calcul equinox faux
    // long double puissance_moins_sept = 0.0000001;
    //printf("puissance : %g \n", puissance_moins_sept);
    //frq = 2.79365 * puissance_moins_sept;
    //frq = 1 / frq;
    //frq = frq / freq;

    // calcul juste 
    frq = 3546895 / freq;



    printf("frq : %Lf \n", frq);

    long double resultat = round((frq / note_amiga) * 4096);


    // frq = (1 / (2.79365 * 10^-7)) / freq;

    printf("Frequence cible : %f \n", freq);

    printf("note Amiga : %f : resultat : %f \n", note_amiga, resultat);

    int     tableau_increments[3600];
    for (int i=0; i < 3600; i++)
    {
        tableau_increments[i] = int(round((frq / i) * 4096));
        // printf(" res : %d \n", tableau_increments[i]);
    }
    int index = 0;
    for (int ligne = 0; ligne < (3600 / 8); ligne++)
    {
        printf("      .long      %d, %d, %d, %d, %d, %d, %d, %d \n", tableau_increments[index], tableau_increments[index+1], tableau_increments[index+2], tableau_increments[index+3], tableau_increments[index+4], tableau_increments[index+5], tableau_increments[index+6], tableau_increments[index+7]);
        index = index + 8;


    }
}


