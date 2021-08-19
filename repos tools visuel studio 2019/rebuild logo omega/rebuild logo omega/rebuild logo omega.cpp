// rebuild logo omega.cpp : Ce fichier contient la fonction 'main'. L'exécution du programme commence et se termine à cet endroit.
//
#define _CRT_SECURE_NO_WARNINGS
#include <iostream>

int main()
{
    uint16_t palette1[16];
    palette1[0] = 0x0000;
    palette1[1] = 0x0103;
    palette1[2] = 0x0204;
    palette1[3] = 0x0305;
    palette1[4] = 0x0406;
    palette1[5] = 0x0527;
    palette1[6] = 0x0647;
    palette1[7] = 0x0757;
    palette1[8] = 0x0310;
    palette1[9] = 0x0420;
    palette1[10] = 0x0530;
    palette1[11] = 0x0640;
    palette1[12] = 0x0750;
    palette1[13] = 0x0760;
    palette1[14] = 0x0770;
    palette1[15] = 0x0777;

    uint16_t palette2[16];
    palette2[0] = 0x0000;
    palette2[1] = 0x0300;
    palette2[2] = 0x0400;
    palette2[3] = 0x0600;
    palette2[4] = 0x0720;
    palette2[5] = 0x0740;
    palette2[6] = 0x0760;
    palette2[7] = 0x0773;
    palette2[8] = 0x0030;
    palette2[9] = 0x0040;
    palette2[10] = 0x0050;
    palette2[11] = 0x0070;
    palette2[12] = 0x0373;
    palette2[13] = 0x0474;
    palette2[14] = 0x0575;
    palette2[15] = 0x0777;
    


    std::cout << "Hello World!\n";

    FILE* fptr;
    FILE* wptr;
    fptr = fopen("C:\\Python\\Python39\\logo.bin", "rb");
    wptr = fopen("C:\\Python\\Python39\\logo16.data", "w");

    uint16_t bufferp1[1];
    uint16_t bufferp2[1];
    uint16_t bufferp3[1];
    uint16_t bufferp4[1];

    uint8_t couleurRVB = 0xFF;
    uint8_t couleurnoir = 0x00;

    uint8_t couleurAlpha = 0xFF;

    for (int x = 0; x < 20 * 66; x++)
    {
        fread(bufferp1, 1, sizeof(bufferp1), fptr);
        uint16_t pixelp1 = bufferp1[0];
        int16_t  swapped1 = (pixelp1 >> 8) | (pixelp1 << 8);
        // swapped1 = pixelp1;

        fread(bufferp2, 1, sizeof(bufferp2), fptr);
        uint16_t pixelp2 = bufferp2[0];
        int16_t  swapped2 = (pixelp2 >> 8) | (pixelp2 << 8);
        // swapped2 = pixelp2;

        fread(bufferp3, 1, sizeof(bufferp3), fptr);
        uint16_t pixelp3 = bufferp3[0];
        int16_t  swapped3 = (pixelp3 >> 8) | (pixelp3 << 8);
        // swapped3 = pixelp3;

        fread(bufferp4, 1, sizeof(bufferp4), fptr);
        uint16_t pixelp4 = bufferp4[0];
        int16_t  swapped4 = (pixelp4 >> 8) | (pixelp4 << 8);
        // swapped4 = pixelp4;

        if (bufferp1[0] != 0 || bufferp2[0] != 0 || bufferp3[0] != 0 || bufferp4[0] != 0  )
        {
            std::cout << "couleur\n";
        }
        // on va de gauche a droite des U16
        uint16_t mask_pixel = 32768;
        // on va de droite a gauche des U16
        // uint16_t mask_pixel = 1;
        for (int pixel = 0; pixel < 16; pixel++)
        {
            uint16_t couleurt = swapped4 & mask_pixel;
            if (couleurt > 0)
            {
                couleurt = 1;
            }
            uint16_t couleur = couleurt;

            couleur = couleur << 1;

            couleurt = swapped3 & mask_pixel;
            if (couleurt > 0)
            {
                couleurt = 1;
            }
            couleur = couleur | couleurt;
            couleur = couleur << 1;

            couleurt = swapped2 & mask_pixel;
            if (couleurt > 0)
            {
                couleurt = 1;
            }
            couleur = couleur | couleurt;
            couleur = couleur << 1;


            couleurt = swapped1 & mask_pixel;
            if (couleurt > 0)
            {
                couleurt = 1;
            }
            couleur = couleur | couleurt;
            // couleur = couleur << 1;

            // on a la couleur entre 0 et 15

            //if (couleur == 0)
            //{
            //    fwrite(&couleurnoir, sizeof(couleurnoir), 1, wptr);
            //}
            //else
            //{
                uint16_t couleurST = palette2[couleur];
                // xxxxxrrrxvvvxbbb
                uint16_t couleurR = couleurST & 0b0000011100000000;
                couleurR = couleurR >> 8;
                uint8_t couleurR8 = (uint8_t)couleurR;
                uint16_t couleurV = couleurST & 0b0000000001110000;
                couleurV = couleurV >> 4;
                uint8_t couleurV8 = (uint8_t)couleurV;
                uint16_t couleurB = couleurST & 0b0000000000000111;
                uint8_t couleurB8 = (uint8_t)couleurB;

                // couleurs trop sombres
                couleurR8 = couleurR8 << 5;
                couleurB8 = couleurB8 << 5;
                couleurV8 = couleurV8 << 5;

                
                // fwrite(&couleurAlpha, sizeof(couleurAlpha), 1, wptr);
                fwrite(&couleurR8, sizeof(couleurR8), 1, wptr);
                fwrite(&couleurV8, sizeof(couleurV8), 1, wptr);
                fwrite(&couleurB8, sizeof(couleurB8), 1, wptr);

                //fwrite(&couleurRVB, sizeof(couleurRVB), 1, wptr);
                //fwrite(&couleurRVB, sizeof(couleurRVB), 1, wptr);
            //}

            // on va de gauche a droite des U16
             mask_pixel = mask_pixel >> 1;

            // on va de droite a gauche des U16
            // mask_pixel = mask_pixel << 1;

        }
    }
    for (int x = 0; x < 20 * 66; x++)
    {
        fread(bufferp1, 1, sizeof(bufferp1), fptr);
        uint16_t pixelp1 = bufferp1[0];
        int16_t  swapped1 = (pixelp1 >> 8) | (pixelp1 << 8);
        // swapped1 = pixelp1;

        fread(bufferp2, 1, sizeof(bufferp2), fptr);
        uint16_t pixelp2 = bufferp2[0];
        int16_t  swapped2 = (pixelp2 >> 8) | (pixelp2 << 8);
        // swapped2 = pixelp2;

        fread(bufferp3, 1, sizeof(bufferp3), fptr);
        uint16_t pixelp3 = bufferp3[0];
        int16_t  swapped3 = (pixelp3 >> 8) | (pixelp3 << 8);
        // swapped3 = pixelp3;

        fread(bufferp4, 1, sizeof(bufferp4), fptr);
        uint16_t pixelp4 = bufferp4[0];
        int16_t  swapped4 = (pixelp4 >> 8) | (pixelp4 << 8);
        // swapped4 = pixelp4;

        if (bufferp1[0] != 0 || bufferp2[0] != 0 || bufferp3[0] != 0 || bufferp4[0] != 0)
        {
            std::cout << "couleur\n";
        }
        // on va de gauche a droite des U16
        uint16_t mask_pixel = 32768;
        // on va de droite a gauche des U16
        // uint16_t mask_pixel = 1;
        for (int pixel = 0; pixel < 16; pixel++)
        {
            uint16_t couleurt = swapped4 & mask_pixel;
            if (couleurt > 0)
            {
                couleurt = 1;
            }
            uint16_t couleur = couleurt;

            couleur = couleur << 1;

            couleurt = swapped3 & mask_pixel;
            if (couleurt > 0)
            {
                couleurt = 1;
            }
            couleur = couleur | couleurt;
            couleur = couleur << 1;

            couleurt = swapped2 & mask_pixel;
            if (couleurt > 0)
            {
                couleurt = 1;
            }
            couleur = couleur | couleurt;
            couleur = couleur << 1;


            couleurt = swapped1 & mask_pixel;
            if (couleurt > 0)
            {
                couleurt = 1;
            }
            couleur = couleur | couleurt;
            // couleur = couleur << 1;

            // on a la couleur entre 0 et 15

            //if (couleur == 0)
            //{
            //    fwrite(&couleurnoir, sizeof(couleurnoir), 1, wptr);
            //}
            //else
            //{
            uint16_t couleurST = palette1[couleur];
            // xxxxxrrrxvvvxbbb
            uint16_t couleurR = couleurST & 0b0000011100000000;
            couleurR = couleurR >> 8;
            uint8_t couleurR8 = (uint8_t)couleurR;
            uint16_t couleurV = couleurST & 0b0000000001110000;
            couleurV = couleurV >> 4;
            uint8_t couleurV8 = (uint8_t)couleurV;
            uint16_t couleurB = couleurST & 0b0000000000000111;
            uint8_t couleurB8 = (uint8_t)couleurB;

            // couleurs trop sombres
            couleurR8 = couleurR8 << 5;
            couleurB8 = couleurB8 << 5;
            couleurV8 = couleurV8 << 5;


            // fwrite(&couleurAlpha, sizeof(couleurAlpha), 1, wptr);
            fwrite(&couleurR8, sizeof(couleurR8), 1, wptr);
            fwrite(&couleurV8, sizeof(couleurV8), 1, wptr);
            fwrite(&couleurB8, sizeof(couleurB8), 1, wptr);

            //fwrite(&couleurRVB, sizeof(couleurRVB), 1, wptr);
            //fwrite(&couleurRVB, sizeof(couleurRVB), 1, wptr);
        //}

        // on va de gauche a droite des U16
            mask_pixel = mask_pixel >> 1;

            // on va de droite a gauche des U16
            // mask_pixel = mask_pixel << 1;

        }
    }

    fclose(wptr);
    fclose(fptr);
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
