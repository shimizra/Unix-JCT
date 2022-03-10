//##############################
//###Shimon MIzrahi 203375563###
//##############################

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <wordexp.h>

#define MAX_USER_INPUT 70
#define MAX_STRTOC 20

void execCommand(char *arrFather[], char *arrSon[], int isPipe, int debug) //the function get 2 array arument and 2 int arguments.
{                                                                          //the execCommand function create pipe.
  if (isPipe == 0)  //if not pipe.                                                       //if user not write pipe.
  {
    if (debug == 1) //if user wants to print debug.
    {
      printf("INFO: Child started PID[%d] command: ''%s'' \n", getpid(), arrFather[0]);
    }
    execvp(arrFather[0], arrFather);    //implantation user command.
    printf("*** ERROR: exec failed\n"); //not shoud get here.
    exit(1);
  }

  int p[2]; //creat p array for sddin/out pipe.
  pipe(p);
  int pid = fork();

  if (pid < 0) //error.
  {
    printf("ERROR fork problem son\n");
  }
  else if (pid > 0) //father
  {
    if (debug == 1) //if user wants to print debug.
    {
      printf("INFO: Child started PID[%d] command: ''%s'' \n", getpid(), arrFather[0]);
    }
    dup2(p[1], 1); //Override stdout.
    close(p[0]);
    close(p[1]);
    execvp(arrFather[0], arrFather);
    printf("*** ERROR: exec failed\n");
    exit(1);
  }
  else //son
  {
    if (debug == 1) //if user wants to print debug.
    {
      printf("INFO: Child started PID[%d] command: ''%s'' \n", getpid(), arrSon[0]);
    }
    dup2(p[0], 0); //Override stdin.
    close(p[0]);
    close(p[1]);
    execvp(arrSon[0], arrSon);
    printf("*** ERROR: exec failed\n");
    exit(1);
  }
}

void MakeArr(char *str, char *result[]) //the function gets 2 arguments.
{                                       //the function MakeArr get array and string and buld array by string in referce way.
  char *token;                          //iteration, run on str.
  int i = 0;
  token = strtok(str, " ");
  while (token != NULL)
  {
    //printf("%s\n", token);
    result[i] = token;
    token = strtok(NULL, " "); //Separator=" " and  "\n".
    i++;
  }
  result[i] = NULL; //last cell must = NULL.
}

void printPropt() //print function, the function print Shimon prompt.
{
  printf("Shimon prompt :)>>");
}


int main(int argc, char *argv[]) //main function.
{
  int pipeExist = 0;              //pipeExist=1 when user send pipe command, pipeExist=0 if not.
  char userInput[MAX_USER_INPUT]; //userInput= propmt user input.
  //int i;                          //index of user input flag.
  //int j;                          //index of rest array.
  char *arrFather[MAX_STRTOC]; //arr save command and is flags.
  char *arrSon[MAX_STRTOC];    //arr save command and is flags.
  int pid;                     //save the pid of father and son.
  int status;                  //save execvp status.
  char *tokenFather;           //save word by word from userInput string.
  char *tokenSon;              //save word by word from userInput string.
  int debug = 0;               //debug=0 means user not send -debug flag. debug=1 means user send -debug flag.
  FILE *fp;                    //conten rejex.
  char path[MAX_USER_INPUT];   //phat result of rejex.
  wordexp_t p;                 //p save rejex.
  char **tokenFatherRejex;     //save word by word from userInput string.

  if (argc == 2 && !strcmp(argv[1], "-debug")) //means that user sent -debug flag.
  {
    debug = 1;
    printf("Welcome in my extended mini shell. Type ''exit'' to terminate.\n");
  }

  while (1)
  {
    //i = 0; //reset i for each itertion.
    //j=0; //reset j for each itertion.

    printPropt(); //print prompt.

    fgets(userInput, sizeof(userInput), stdin); //like order scanf("%s",userInput);

    if (!(strcmp(userInput, "exit\n"))) //finish when user press exit.
    {
      if (debug == 1) //if user wants to print debug.
      {
        printf("INFO: Father will terminate");
      }
      exit(0);
    }

    tokenFather = strtok(userInput, "\n"); //Separator=/n.
    tokenFather = strtok(userInput, "|");    //Separator=|.
    tokenSon = strtok(NULL, "|"); //gets the next command after pipe if there is.

    wordexp(tokenFather, &p, 0);
    tokenFatherRejex = p.we_wordv; //if user sent rejex tokenFatherRejex=the result of rejex.

    //MakeArr(tokenFatherRejex, arrFather); //call function MakeArr to fill arrFather[] array by refernce.

    pipeExist = tokenSon != NULL; //pipeExist=1 if user send pipe, else pipeExist=0.
    if (pipeExist)                //if user send pipe.
    {
      MakeArr(tokenSon, arrSon); //creat arrSon array.

      if (debug == 1) //if user wants to print debug.
      {
        printf("INFO: Pipe detected. Command 1: ''%s'' and Command 2: ''%s'' \n", arrFather[0], arrSon[0]);
        printf("INFO: Making pipe \n");
      }
    }
    else
    {
      if (debug == 1) //if user wants to print debug.
      {
        printf("INFO: No pipe detected, creating child for command: ''%s'' \n", arrFather[0]);
      }
    }

    pid = fork(); //create son process.

    if (pid < 0) //if error
    {
      printf("ERROR fork failed\n");
    }
    else if (pid > 0) //if father.
    {
      //waitpid(pid,1);
      waitpid(pid, &status, 0); //wait until pid son terminated.
      if (debug == 1)           //if user wants to print debug.
      {
        printf("Child with PID[%d]terminated, continue waiting commands\n", pid);
        wordfree(&p); //relese memo of p.
      }
    }
    else if (pid == 0) //if son.
    {
      execCommand(tokenFatherRejex, arrSon, pipeExist, debug); //call execCommand function.
    }
  }
  return 0;
}