#include <SDL2/SDL.h>

#include <stdio.h>

int main(int argc, char** argv)
{
    /* Initialisation simple */
    if (SDL_Init(SDL_INIT_VIDEO) != 0)
    {
        fprintf(stdout, "�chec de l'initialisation de la SDL (%s)\n", SDL_GetError());
        return -1;
    }

    {
        /* Cr�ation de la fen�tre */
        SDL_Window* pWindow = NULL;
        pWindow = SDL_CreateWindow("Ma premi�re application SDL2", SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            640,
            480,
            SDL_WINDOW_SHOWN);

        SDL_Renderer* pRenderer = SDL_CreateRenderer(pWindow, -1, SDL_RENDERER_ACCELERATED); // Cr�ation d'un SDL_Renderer utilisant l'acc�l�ration mat�rielle
        
        SDL_SetRenderDrawColor(pRenderer, 255, 0, 0, 255);
        
        SDL_RenderClear(pRenderer);

        SDL_RenderPresent(pRenderer); // Affichage
        
        if (pWindow)
        {
            SDL_Delay(3000); /* Attendre trois secondes, que l'utilisateur voie la fen�tre */

            SDL_DestroyWindow(pWindow);
        }
        else
        {
            fprintf(stderr, "Erreur de cr�ation de la fen�tre: %s\n", SDL_GetError());
        }
    }

    SDL_Quit();

    return 0;
}