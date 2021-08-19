// conversion source Xavier vers Vasm.cpp : Ce fichier contient la fonction 'main'. L'exécution du programme commence et se termine à cet endroit.
//



#include <string>
#include <cstdio>

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <algorithm>    // std::min


#include <cstdio>
#include <string>

#include "exprtk.hpp"

using namespace std;





int main()
{
        std::ifstream input("C:/Archi/Arculator_V2.0_Windows/hostfs/pos3v2");
        std::string line, a_calculer;

        std::string expression_str;

        ofstream fileW;
        fileW.open("C:/Archi/Arculator_V2.0_Windows/hostfs/pos3v2.s");
 

        typedef exprtk::symbol_table<double> symbol_table_t;
        typedef exprtk::expression<double>     expression_t;
        typedef exprtk::parser<double>             parser_t;
expression_t expression;
        parser_t parser;
        
        int position_R0v, position_R1v, position_R2v, position_R3v, position_R4v;
        int position_R5v, position_R6v, position_R7v, position_R8v, position_R9v;
        int position_R10v, position_R11v, position_R12v, position_R13v, position_R14v;

        int position_diese, position_pointvirgule, position_crochet;
        int position_maxi;

        int longeurchaine;
        bool trouve = false;

        while (trouve != true)
        {
            std::getline(input, line);

            if (line == "CACA") trouve = true;



            std::cout << line << '\n';

            longeurchaine = size(line);
            // printf("taille : %d\n", longeurchaine);

            // ,R
            position_R10v = line.find(" 10,");
            if (position_R10v != -1) (line.insert(position_R10v + 1, "R"));
            position_R11v = line.find(" 11,");
            if (position_R11v != -1) (line.insert(position_R11v + 1, "R"));
            position_R12v = line.find(" 12,");
            if (position_R12v != -1) (line.insert(position_R12v + 1, "R"));
            position_R13v = line.find(" 13,");
            if (position_R13v != -1) (line.insert(position_R13v + 1, "R"));
            position_R14v = line.find(" 14,");
            if (position_R14v != -1) (line.insert(position_R14v + 1, "R"));
            position_R0v = line.find(" 0,");
            if (position_R0v != -1) (line.insert(position_R0v + 1, "R"));
            position_R1v = line.find(" 1,");
            if (position_R1v != -1) (line.insert(position_R1v + 1, "R"));
            position_R2v = line.find(" 2,");
            if (position_R2v != -1) (line.insert(position_R2v + 1, "R"));
            position_R3v = line.find(" 3,");
            if (position_R3v != -1) (line.insert(position_R3v + 1, "R"));
            position_R4v = line.find(" 4,");
            if (position_R4v != -1) (line.insert(position_R4v + 1, "R"));
            position_R5v = line.find(" 5,");
            if (position_R5v != -1) (line.insert(position_R5v + 1, "R"));
            position_R6v = line.find(" 6,");
            if (position_R6v != -1) (line.insert(position_R6v + 1, "R"));
            position_R7v = line.find(" 7,");
            if (position_R7v != -1) (line.insert(position_R7v + 1, "R"));
            position_R8v = line.find(" 8,");
            if (position_R8v != -1) (line.insert(position_R8v + 1, "R"));
            position_R9v = line.find(" 9,");
            if (position_R9v != -1) (line.insert(position_R9v + 1, "R"));


            // {R
            position_R0v = line.find("{0,");
            if (position_R0v != -1) (line.insert(position_R0v + 1, "R"));
            position_R1v = line.find("{1,");
            if (position_R1v != -1) (line.insert(position_R1v + 1, "R"));
            position_R2v = line.find("{2,");
            if (position_R2v != -1) (line.insert(position_R2v + 1, "R"));
            position_R3v = line.find("{3,");
            if (position_R3v != -1) (line.insert(position_R3v + 1, "R"));
            position_R4v = line.find("{4,");
            if (position_R4v != -1) (line.insert(position_R4v + 1, "R"));
            position_R5v = line.find("{5,");
            if (position_R5v != -1) (line.insert(position_R5v + 1, "R"));
            position_R6v = line.find("{6,");
            if (position_R6v != -1) (line.insert(position_R6v + 1, "R"));
            position_R7v = line.find("{7,");
            if (position_R7v != -1) (line.insert(position_R7v + 1, "R"));
            position_R8v = line.find("{8,");
            if (position_R8v != -1) (line.insert(position_R8v + 1, "R"));
            position_R9v = line.find("{9,");
            if (position_R9v != -1) (line.insert(position_R9v + 1, "R"));
            position_R10v = line.find("{10,");
            if (position_R10v != -1) (line.insert(position_R10v + 1, "R"));
            position_R11v = line.find("{11,");
            if (position_R11v != -1) (line.insert(position_R11v + 1, "R"));
            position_R12v = line.find("{12,");
            if (position_R12v != -1) (line.insert(position_R12v + 1, "R"));
            position_R13v = line.find("{13,");
            if (position_R13v != -1) (line.insert(position_R13v + 1, "R"));
            position_R14v = line.find("{14,");
            if (position_R14v != -1) (line.insert(position_R14v + 1, "R"));

            // -R
            position_R0v = line.find("-0}");
            if (position_R0v != -1) (line.insert(position_R0v + 1, "R"));
            position_R1v = line.find("-1}");
            if (position_R1v != -1) (line.insert(position_R1v + 1, "R"));
            position_R2v = line.find("-2}");
            if (position_R2v != -1) (line.insert(position_R2v + 1, "R"));
            position_R3v = line.find("-3}");
            if (position_R3v != -1) (line.insert(position_R3v + 1, "R"));
            position_R4v = line.find("-4}");
            if (position_R4v != -1) (line.insert(position_R4v + 1, "R"));
            position_R5v = line.find("-5}");
            if (position_R5v != -1) (line.insert(position_R5v + 1, "R"));
            position_R6v = line.find("-6}");
            if (position_R6v != -1) (line.insert(position_R6v + 1, "R"));
            position_R7v = line.find("-7}");
            if (position_R7v != -1) (line.insert(position_R7v + 1, "R"));
            position_R8v = line.find("-8}");
            if (position_R8v != -1) (line.insert(position_R8v + 1, "R"));
            position_R9v = line.find("-9}");
            if (position_R9v != -1) (line.insert(position_R9v + 1, "R"));
            position_R10v = line.find("-10}");
            if (position_R10v != -1) (line.insert(position_R10v + 1, "R"));
            position_R11v = line.find("-11}");
            if (position_R11v != -1) (line.insert(position_R11v + 1, "R"));
            position_R12v = line.find("-12}");
            if (position_R12v != -1) (line.insert(position_R12v + 1, "R"));
            position_R13v = line.find("-13}");
            if (position_R13v != -1) (line.insert(position_R13v + 1, "R"));
            position_R14v = line.find("-14}");
            if (position_R14v != -1) (line.insert(position_R14v + 1, "R"));

            // ,R-
            position_R10v = line.find(",10-");
            if (position_R10v != -1) (line.insert(position_R10v + 1, "R"));
            position_R11v = line.find(",11-");
            if (position_R11v != -1) (line.insert(position_R11v + 1, "R"));
            position_R12v = line.find(",12-");
            if (position_R12v != -1) (line.insert(position_R12v + 1, "R"));
            position_R13v = line.find(",13-");
            if (position_R13v != -1) (line.insert(position_R13v + 1, "R"));
            position_R14v = line.find(",14-");
            if (position_R14v != -1) (line.insert(position_R14v + 1, "R"));
            position_R0v = line.find(",0-");
            if (position_R0v != -1) (line.insert(position_R0v + 1, "R"));
            position_R1v = line.find(",1-");
            if (position_R1v != -1) (line.insert(position_R1v + 1, "R"));
            position_R2v = line.find(",2-");
            if (position_R2v != -1) (line.insert(position_R2v + 1, "R"));
            position_R3v = line.find(",3-");
            if (position_R3v != -1) (line.insert(position_R3v + 1, "R"));
            position_R4v = line.find(",4-");
            if (position_R4v != -1) (line.insert(position_R4v + 1, "R"));
            position_R5v = line.find(",5-");
            if (position_R5v != -1) (line.insert(position_R5v + 1, "R"));
            position_R6v = line.find(",6-");
            if (position_R6v != -1) (line.insert(position_R6v + 1, "R"));
            position_R7v = line.find(",7-");
            if (position_R7v != -1) (line.insert(position_R7v + 1, "R"));
            position_R8v = line.find(",8-");
            if (position_R8v != -1) (line.insert(position_R8v + 1, "R"));
            position_R9v = line.find(",9-");
            if (position_R9v != -1) (line.insert(position_R9v + 1, "R"));

            // [R,
            position_R10v = line.find("[10,");
            if (position_R10v != -1) (line.insert(position_R10v + 1, "R"));
            position_R11v = line.find("[11,");
            if (position_R11v != -1) (line.insert(position_R11v + 1, "R"));
            position_R12v = line.find("[12,");
            if (position_R12v != -1) (line.insert(position_R12v + 1, "R"));
            position_R13v = line.find("[13,");
            if (position_R13v != -1) (line.insert(position_R13v + 1, "R"));
            position_R14v = line.find("[14,");
            if (position_R14v != -1) (line.insert(position_R14v + 1, "R"));
            position_R0v = line.find("[0,");
            if (position_R0v != -1) (line.insert(position_R0v + 1, "R"));
            position_R1v = line.find("[1,");
            if (position_R1v != -1) (line.insert(position_R1v + 1, "R"));
            position_R2v = line.find("[2,");
            if (position_R2v != -1) (line.insert(position_R2v + 1, "R"));
            position_R3v = line.find("[3,");
            if (position_R3v != -1) (line.insert(position_R3v + 1, "R"));
            position_R4v = line.find("[4,");
            if (position_R4v != -1) (line.insert(position_R4v + 1, "R"));
            position_R5v = line.find("[5,");
            if (position_R5v != -1) (line.insert(position_R5v + 1, "R"));
            position_R6v = line.find("[6,");
            if (position_R6v != -1) (line.insert(position_R6v + 1, "R"));
            position_R7v = line.find("[7,");
            if (position_R7v != -1) (line.insert(position_R7v + 1, "R"));
            position_R8v = line.find("[8,");
            if (position_R8v != -1) (line.insert(position_R8v + 1, "R"));
            position_R9v = line.find("[9,");
            if (position_R9v != -1) (line.insert(position_R9v + 1, "R"));

            ///{ R,
            position_R10v = line.find(",10");
            if (position_R10v != -1) (line.insert(position_R10v + 1, "R"));
            position_R11v = line.find(",11");
            if (position_R11v != -1) (line.insert(position_R11v + 1, "R"));
            position_R12v = line.find(",12");
            if (position_R12v != -1) (line.insert(position_R12v + 1, "R"));
            position_R13v = line.find(",13");
            if (position_R13v != -1) (line.insert(position_R13v + 1, "R"));
            position_R14v = line.find(",14");
            if (position_R14v != -1) (line.insert(position_R14v + 1, "R"));
            position_R0v = line.find(",0");
            if (position_R0v != -1) (line.insert(position_R0v + 1, "R"));
            position_R1v = line.find(",1");
            if (position_R1v != -1) (line.insert(position_R1v + 1, "R"));
            position_R2v = line.find(",2");
            if (position_R2v != -1) (line.insert(position_R2v + 1, "R"));
            position_R3v = line.find(",3");
            if (position_R3v != -1) (line.insert(position_R3v + 1, "R"));
            position_R4v = line.find(",4");
            if (position_R4v != -1) (line.insert(position_R4v + 1, "R"));
            position_R5v = line.find(",5");
            if (position_R5v != -1) (line.insert(position_R5v + 1, "R"));
            position_R6v = line.find(",6");
            if (position_R6v != -1) (line.insert(position_R6v + 1, "R"));
            position_R7v = line.find(",7");
            if (position_R7v != -1) (line.insert(position_R7v + 1, "R"));
            position_R8v = line.find(",8");
            if (position_R8v != -1) (line.insert(position_R8v + 1, "R"));
            position_R9v = line.find(",9");
            if (position_R9v != -1) (line.insert(position_R9v + 1, "R"));

            //
            /// R!
            position_R10v = line.find(" 10!");
            if (position_R10v != -1) (line.insert(position_R10v + 1, "R"));
            position_R11v = line.find(" 11!");
            if (position_R11v != -1) (line.insert(position_R11v + 1, "R"));
            position_R12v = line.find(" 12!");
            if (position_R12v != -1) (line.insert(position_R12v + 1, "R"));
            position_R13v = line.find(" 13!");
            if (position_R13v != -1) (line.insert(position_R13v + 1, "R"));
            position_R14v = line.find(" 14!");
            if (position_R14v != -1) (line.insert(position_R14v + 1, "R"));
            position_R0v = line.find(" 0!");
            if (position_R0v != -1) (line.insert(position_R0v + 1, "R"));
            position_R1v = line.find(" 1!");
            if (position_R1v != -1) (line.insert(position_R1v + 1, "R"));
            position_R2v = line.find(" 2!");
            if (position_R2v != -1) (line.insert(position_R2v + 1, "R"));
            position_R3v = line.find(" 3!");
            if (position_R3v != -1) (line.insert(position_R3v + 1, "R"));
            position_R4v = line.find(" 4!");
            if (position_R4v != -1) (line.insert(position_R4v + 1, "R"));
            position_R5v = line.find(" 5!");
            if (position_R5v != -1) (line.insert(position_R5v + 1, "R"));
            position_R6v = line.find(" 6!");
            if (position_R6v != -1) (line.insert(position_R6v + 1, "R"));
            position_R7v = line.find(" 7!");
            if (position_R7v != -1) (line.insert(position_R7v + 1, "R"));
            position_R8v = line.find(" 8!");
            if (position_R8v != -1) (line.insert(position_R8v + 1, "R"));
            position_R9v = line.find(" 9!");
            if (position_R9v != -1) (line.insert(position_R9v + 1, "R"));

            /// {R-
            position_R10v = line.find("{10-");
            if (position_R10v != -1) (line.insert(position_R10v + 1, "R"));
            position_R11v = line.find("{11-");
            if (position_R11v != -1) (line.insert(position_R11v + 1, "R"));
            position_R12v = line.find("{12-");
            if (position_R12v != -1) (line.insert(position_R12v + 1, "R"));
            position_R13v = line.find("{13-");
            if (position_R13v != -1) (line.insert(position_R13v + 1, "R"));
            position_R14v = line.find("{14-");
            if (position_R14v != -1) (line.insert(position_R14v + 1, "R"));
            position_R0v = line.find("{0-");
            if (position_R0v != -1) (line.insert(position_R0v + 1, "R"));
            position_R1v = line.find("{1-");
            if (position_R1v != -1) (line.insert(position_R1v + 1, "R"));
            position_R2v = line.find("{2-");
            if (position_R2v != -1) (line.insert(position_R2v + 1, "R"));
            position_R3v = line.find("{3-");
            if (position_R3v != -1) (line.insert(position_R3v + 1, "R"));
            position_R4v = line.find("{4-");
            if (position_R4v != -1) (line.insert(position_R4v + 1, "R"));
            position_R5v = line.find("{5-");
            if (position_R5v != -1) (line.insert(position_R5v + 1, "R"));
            position_R6v = line.find("{6-");
            if (position_R6v != -1) (line.insert(position_R6v + 1, "R"));
            position_R7v = line.find("{7-");
            if (position_R7v != -1) (line.insert(position_R7v + 1, "R"));
            position_R8v = line.find("{8-");
            if (position_R8v != -1) (line.insert(position_R8v + 1, "R"));
            position_R9v = line.find("{9-");
            if (position_R9v != -1) (line.insert(position_R9v + 1, "R"));

            /// -R,
            position_R10v = line.find("-10,");
            if (position_R10v != -1) (line.insert(position_R10v + 1, "R"));
            position_R11v = line.find("-11,");
            if (position_R11v != -1) (line.insert(position_R11v + 1, "R"));
            position_R12v = line.find("-12,");
            if (position_R12v != -1) (line.insert(position_R12v + 1, "R"));
            position_R13v = line.find("-13,");
            if (position_R13v != -1) (line.insert(position_R13v + 1, "R"));
            position_R14v = line.find("-14,");
            if (position_R14v != -1) (line.insert(position_R14v + 1, "R"));
            position_R0v = line.find("-0,");
            if (position_R0v != -1) (line.insert(position_R0v + 1, "R"));
            position_R1v = line.find("-1,");
            if (position_R1v != -1) (line.insert(position_R1v + 1, "R"));
            position_R2v = line.find("-2,");
            if (position_R2v != -1) (line.insert(position_R2v + 1, "R"));
            position_R3v = line.find("-3,");
            if (position_R3v != -1) (line.insert(position_R3v + 1, "R"));
            position_R4v = line.find("-4,");
            if (position_R4v != -1) (line.insert(position_R4v + 1, "R"));
            position_R5v = line.find("-5,");
            if (position_R5v != -1) (line.insert(position_R5v + 1, "R"));
            position_R6v = line.find("-6,");
            if (position_R6v != -1) (line.insert(position_R6v + 1, "R"));
            position_R7v = line.find("-7,");
            if (position_R7v != -1) (line.insert(position_R7v + 1, "R"));
            position_R8v = line.find("-8,");
            if (position_R8v != -1) (line.insert(position_R8v + 1, "R"));
            position_R9v = line.find("-9,");
            if (position_R9v != -1) (line.insert(position_R9v + 1, "R"));



            // on check si il y a un diese
            position_diese = line.find("#");         // -1 si pas trouve
            if (position_diese != -1)
            {
                position_pointvirgule = line.find(";", position_diese);         // -1 si pas trouve
                position_crochet = line.find("]", position_diese);         // -1 si pas trouve


                if (position_pointvirgule != -1 && position_crochet != -1)
                {
                    position_maxi = std::min(position_pointvirgule, position_crochet);
                }
                else
                {
                    position_maxi = std::max(position_pointvirgule, position_crochet);
                }

                // printf("position_diese : %d,  position_maxi : %d\n", position_diese, position_maxi);

                if (position_maxi == -1)
                {
                    a_calculer = line.substr(position_diese+1);
                }
                else
                {
                    a_calculer = line.substr(position_diese+1, position_maxi- (position_diese+1));
                }

                expression_str = a_calculer;
                // std::cout << a_calculer << '\n';

                parser.compile(expression_str, expression);
                int result = 0.0;
                result = (int)expression.value();
                // printf("Result1: %d\n", result);
                std::string string_result = to_string(result);

                line.replace(position_diese + 1, position_maxi - (position_diese + 1), string_result);
            }


            // chercher : ] // ; // 
            // position_pointvirgule, position_crochet

            // sinon fin de ligne


            fileW << line << '\n';

        }

        fileW.close();
        input.close();

    // remplacer 0 à 14 par R0 à R15
    // remplacer les # calcul par le résultat
      

  
 
        //expression_str = "1+2";

   //     double x = 1.1;

        // Register x with the symbol_table
        // symbol_table_t symbol_table;
        // symbol_table.add_variable("x", x);

        // Instantiate expression and register symbol_table
        
        // expression.register_symbol_table(symbol_table);

        // Instantiate parser and compile the expression
       


        // Evaluate and print result for when x = 1.1

        



    
}
