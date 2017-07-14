/**
* Title:            Calculadora
* Author:           Victor Cueva Llanos
* Email:            Ingvcueva@gmail.com
**/

#include <cstdio>
#include <cstring>

char s[100];
char opStack[100];
int numStack[100], lop = 0, lnum = 0;

void computeLastOperator() {
    int tmp;
    lop--; lnum--;
    switch (opStack[lop]) {
        case '^':
            tmp = numStack[lnum - 1];
            numStack[lnum - 1] = 1;
            while (numStack[lnum]--) {
                numStack[lnum - 1] *= tmp;
            }
            break;
        case '/':
            numStack[lnum-1] /= numStack[lnum];
            break;
        case '*':
            numStack[lnum-1] *= numStack[lnum];
            break;
        case '+':
            numStack[lnum-1] += numStack[lnum];
            break;
        case '-':
            numStack[lnum-1] -= numStack[lnum];
    }
}

void compress() {
    while (lop > 0 && opStack[lop-1] != '(') {
        computeLastOperator();
    }
}

void compress2() {
    while (lop > 0 && (opStack[lop-1] == '*' || opStack[lop-1] == '^')) {
        computeLastOperator();
    }
}

int main() {
    scanf("%s", s);

    bool isn = 0;
    int n = 0;
    for (int i = 0, l = strlen(s); i < l; i++) {
        if (s[i] >= '0' && s[i] <= '9') {
            n = n*10 + (s[i] - '0');
            isn = 1;
        } else {
            if (isn) {
                numStack[lnum++] = n;
                n = 0; 
                isn = 0;
            }

            if (s[i] == '(') {
                opStack[lop++] = '(';
            } else if (s[i] == ')') {
                compress();
                lop--;
            } else if (s[i] == '+' or s[i] == '-') {
                compress();
                opStack[lop++] = s[i];
            } else if (s[i] == '^') {
                opStack[lop++] = '^';
            }else {
                compress2();
                opStack[lop++] = s[i];
            }
        }
    }
    if (isn) {
        numStack[lnum++] = n;
    }
    compress();

    printf("%d\n", numStack[0]);
}
