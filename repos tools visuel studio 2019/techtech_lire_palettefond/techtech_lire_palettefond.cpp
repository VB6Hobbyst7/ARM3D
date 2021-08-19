// techtech_lire_palettefond.cpp : Ce fichier contient la fonction 'main'. L'exécution du programme commence et se termine à cet endroit.
//



#include <iostream>
#include <fstream>
#include <string>
using namespace std;

#ifdef _MSC_VER
#define _CRT_SECURE_NO_WARNINGS
#endif

#pragma warning(disable:4996)



int main()
{
	

	char nomfichier[] = "C:/Users/Eric/projects/tectech/dump code palette2.s";

	string line;
	ifstream myfile(nomfichier);
	int rouge, vert, bleu;
	int compteur = 0;
	char strbleu2[3];
	char strrouge2[3];
	char strvert2[3];

	if (myfile.is_open())
	{
		while (getline(myfile, line))
		{
			int pos = line.find("$8248");
			if (pos > 0)
			{
				int posdiese= line.find("#");
				int posvirgule = line.find(",");
				
				string couleur;
				int poscouleur = pos - 9;
				couleur = line.substr(posvirgule-3, 3);
				//cout << couleur << '\n';

				string  strrouge = couleur.substr(0, 1);
				rouge = stoi(strrouge);
				rouge = rouge << 5;
				
				
				//printf("\n%02x\n", rouge);
				snprintf(strrouge2, 3, "%02X", rouge);
				//printf("strrouge2 : %s\n\n", strrouge2);

				
				string  strvert = couleur.substr(1, 1);
				vert = stoi(strvert);
				vert = vert << 5;
				snprintf(strvert2, 3, "%02X", vert);
				//printf("strvert2 : %s\n\n", strvert2);

				string  strbleu = couleur.substr(2, 1);
				bleu = stoi(strbleu);
				bleu = bleu << 5;
				
				snprintf(strbleu2, 3, "%02X", bleu);
				//printf("strbleu2 : %s\n\n", strbleu2);

				printf(",0xFF%s%s%s", strbleu2, strvert2, strrouge2);

				compteur++;
				
				printf(",0xFF%s%s%s", strbleu2, strvert2, strrouge2);

				compteur++;
			}
		}
		myfile.close();
	}
	printf(",0xFF%s%s%s", strbleu2, strvert2, strrouge2);
	compteur++;
	printf(",0xFF%s%s%s", strbleu2, strvert2, strrouge2);
	compteur++;
	printf("\n");
	printf("compteur : %d\n", compteur);


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
