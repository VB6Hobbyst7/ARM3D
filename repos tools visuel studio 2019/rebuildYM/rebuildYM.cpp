// rebuildYM.cpp : Ce fichier contient la fonction 'main'. L'exécution du programme commence et se termine à cet endroit.
//

#include <iostream>
#include <fstream>

int main()
{
    int taille_sample;
    int taille_fichier_source = 176172;
    taille_sample = 173202;
    // load binary file
    
    char* buffersource = (char*) malloc(taille_fichier_source);

    // std::ifstream fin("E:\\sampleoriginal.bin", std::ios::in | std::ios::binary);
    std::ifstream fin("E:\\grosboucleok2.wav", std::ios::in | std::ios::binary);

    fin.read(buffersource, taille_fichier_source);



  
    
   
    std::fstream myfile;

    myfile = std::fstream("E:/file.ym", std::ios::out | std::ios::binary);
    int16_t chaine[10];
    chaine[0] = 01;
    char mix1[] = "MIX1";
    char leonard[] = "LeOnArD!";

    

    myfile.write((char*)&mix1, 04);
    myfile.write((char*)&leonard, 8);

    unsigned short valshort[1];
    unsigned long signe[1];

    // signé ?
    signe[0] = 1;

    signe[0] = _byteswap_ulong(signe[0]);
    myfile.write((char*)&signe, 4);
    
    // sample size
    signe[0] = taille_sample;
    signe[0] = _byteswap_ulong(signe[0]);
    myfile.write((char*)&signe, 4);

    // nb mix bloc = 1
    signe[0] = 1;
    signe[0] = _byteswap_ulong(signe[0]);
    myfile.write((char*)&signe, 4);

    // sampleStart
    signe[0] = 0;
    signe[0] = _byteswap_ulong(signe[0]);
    myfile.write((char*)&signe, 4);

    // sampleLength
    signe[0] = taille_sample;
    signe[0] = _byteswap_ulong(signe[0]);
    myfile.write((char*)&signe, 4);

    // nbRepeat en .w
    valshort[0] = 0;
    valshort[0] = _byteswap_ushort(valshort[0]);
   myfile.write((char*)&valshort, 2);
   
   // replayFreq  en .w
   valshort[0] = 22050;
   valshort[0] = _byteswap_ushort(valshort[0]);
   myfile.write((char*)&valshort, 2);

   // songname
   char songname[] = "FullULM1";
   myfile.write((char*)&songname, 9);

   // songauthor
   myfile.write((char*)&songname, 9);

   // songcomment
   myfile.write((char*)&songname, 9);

   // les samples
   char* buffersample = (char*) malloc(taille_sample+500);
   memset(buffersample, 0x80, taille_sample+500);

   // .wav avec entete de 2e
   memcpy(buffersample, (char*)buffersource+0x2e, taille_sample);


   //memcpy(buffersample, (char*)buffersource , taille_sample);
   printf("buffersample[0] : %X\n", buffersample[0]);

   for (int i = 0; i < taille_sample; i++)
   {
       buffersample[i] =  buffersample[i]+0x80;
   }
   printf("buffersample[0] : %X\n", buffersample[0]);

   myfile.write( (char*)buffersample, taille_sample);


    // myfile.write((char*)&a, size * sizeof(unsigned long long));

    myfile.close();

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
