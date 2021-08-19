// http://digitalsoundandmusic.com/5-3-8-algorithms-for-audio-companding-and-compression/


#include <stdio.h>
#include <math.h>

int main()
{
	int		nombre_de_valeurs = 0;
	for (float x = -1; x <= 1; x = x + (1.0f / 127.0f))
		{

		

		signed int signe;
		signe = 1;
		if (x < 0) signe = -1;

		float x_absolu = x * signe;

		float mux = signe * (( logf(1+(255* x_absolu)) / 5.5452)) ;
		mux = mux * 128;

		printf("x : %f / signe : %d / abs : %f / mux : %f\n", x,signe, x_absolu,mux);
		nombre_de_valeurs++;

		}
	printf("nombre de valeurs : %d \n", nombre_de_valeurs);
}

